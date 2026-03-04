import * as Y from 'yjs'
import * as awarenessProtocol from 'y-protocols/awareness'
import * as State from './state'
import * as helper from '../../helper'

import { YKeyValue } from 'y-utility/y-keyvalue'

const QUIZ = 'q'
const SURVEY = 's'
const CODE = 'c'

export class CRDT {
  protected callback: (event: any, origin: null | string) => void
  public doc: Y.Doc

  // Used by legacy manual-sync providers (Trystero, PubNub, P2PT) as a
  // rough causal tiebreaker. Not needed by the GenericProvider path.
  public timestamp: number = Date.now()

  protected awareness?: awarenessProtocol.Awareness
  protected codes: Y.Map<Y.Text>
  // Flat Y.Map with composite key = JSON.stringify([sectionId, questionIdx, peerID]).
  // Each peer owns exactly one key per question — no two peers ever write the
  // same key, so there is no last-writer-wins collision whatsoever.
  protected quizzes: Y.Map<any>
  protected surveys: Y.Map<any>
  protected chat: YKeyValue<{ message: String; color: String; user: String }>

  protected length: number
  protected peerID: string
  protected color?: string

  constructor(
    peerID: string,
    callback?: (event: any, origin: null | string) => void,
  ) {
    this.doc = new Y.Doc()
    this.callback =
      callback ||
      ((e, origin) => {
        console.warn('SyncDB: no callback provided')
      })

    this.length = 0
    this.peerID = peerID

    this.codes = this.doc.getMap(CODE)

    this.quizzes = this.doc.getMap<any>(QUIZ)
    this.surveys = this.doc.getMap<any>(SURVEY)
    this.chat = new YKeyValue(this.doc.getArray('chat'))
  }

  init(data: State.Vector) {
    this.length = Math.max(this.length, data.length)

    this.doc.transact(() => {
      for (let i = 0; i < data.length; i++) {
        this.initMap(this.quizzes, i, data[i][QUIZ])
        this.initMap(this.surveys, i, data[i][SURVEY])
        this.initText(i, data[i][CODE])
      }
    }, this.peerID)

    this.registerCallbacks()

    // Observers are registered AFTER the transact above, so they never fire
    // for data that was just written (own answers) or data that already existed
    // in the CRDT from a sync that completed before init() was called.
    // Explicitly dispatch the current CRDT state to LiaScript once.
    this.fireInitialState()
  }

  protected fireInitialState() {
    // Peers
    const peers = this.getPeers()
    if (peers.length > 0) {
      this.callback(peers, 'peer')
    }

    // Cursors (awareness-based, fire alongside peers)
    const cursors = this.getCursors()
    if (cursors.length > 0) {
      this.callback(cursors, 'cursor')
    }

    // Quizzes — collect all section IDs that have any entries
    const quizIds = new Set<number>()
    for (const key of this.quizzes.keys()) {
      try {
        const [id] = JSON.parse(key)
        quizIds.add(id)
      } catch {}
    }
    if (quizIds.size > 0) {
      this.callback(
        [...quizIds].map((id) => ({
          id,
          data: this.getMaps(id, this.quizzes),
        })),
        'quiz',
      )
    }

    // Surveys
    const surveyIds = new Set<number>()
    for (const key of this.surveys.keys()) {
      try {
        const [id] = JSON.parse(key)
        surveyIds.add(id)
      } catch {}
    }
    if (surveyIds.size > 0) {
      this.callback(
        [...surveyIds].map((id) => ({
          id,
          data: this.getMaps(id, this.surveys),
        })),
        'survey',
      )
    }

    // Code editors
    const codeIds = new Set<number>()
    for (const key of this.codes.keys()) {
      try {
        const [id] = JSON.parse(key)
        codeIds.add(id)
      } catch {}
    }
    if (codeIds.size > 0) {
      this.callback(this.getCode(codeIds), 'code')
    }

    // Chat — iterate YKeyValue's internal map (sorted by timestamp key)
    const chatMessages: any[] = []
    for (const [key, entry] of (this.chat as any).map as Map<
      string,
      { key: string; val: any }
    >) {
      const obj = { ...entry.val, id: parseInt(key) }
      chatMessages.push(obj)
    }
    if (chatMessages.length > 0) {
      chatMessages.sort((a, b) => a.id - b.id)
      this.callback(chatMessages, 'chat')
    }
  }

  setAwareness(awareness: awarenessProtocol.Awareness) {
    this.awareness = awareness
    // Announce own presence
    awareness.setLocalState({ peerID: this.peerID, color: this.getColor() })

    awareness.on(
      'change',
      (_: { added: number[]; updated: number[]; removed: number[] }) => {
        const peers = this.getPeers()
        this.callback(peers, 'peer')
        const cursors = this.getCursors()
        if (cursors.length > 0) this.callback(cursors, 'cursor')
      },
    )
  }

  registerCallbacks() {
    // The map is flat so a shallow observe is sufficient — no nesting.
    this.quizzes.observe((event: Y.YMapEvent<any>) => {
      const ids = new Set<number>()
      event.keysChanged.forEach((key) => {
        try {
          const [id] = JSON.parse(key)
          ids.add(id)
        } catch {}
      })
      if (ids.size > 0) {
        this.callback(
          [...ids].map((id) => ({ id, data: this.getMaps(id, this.quizzes) })),
          'quiz',
        )
      }
    })

    this.surveys.observe((event: Y.YMapEvent<any>) => {
      const ids = new Set<number>()
      event.keysChanged.forEach((key) => {
        try {
          const [id] = JSON.parse(key)
          ids.add(id)
        } catch {}
      })
      if (ids.size > 0) {
        this.callback(
          [...ids].map((id) => ({ id, data: this.getMaps(id, this.surveys) })),
          'survey',
        )
      }
    })

    this.chat.on(
      'change',
      (
        changes: Map<
          string,
          | { action: 'add'; newValue: any }
          | { action: 'update'; newValue: any; oldValue: any }
          | { action: 'delete'; oldValue: any }
        >,
      ) => {
        const vector: any[] = []

        let obj
        for (let [id, op] of changes) {
          if (op.action === 'add') {
            obj = op.newValue
            obj['id'] = parseInt(id)
            vector.push(obj)
          }
        }

        if (vector.length > 0) this.callback(vector, 'chat')
      },
    )

    this.codes.observeDeep((events: Y.YEvent<any>[]) => {
      const ids: Set<number> = new Set()

      for (const event of events) {
        if (event.target === this.codes) {
          // A Y.Text was added/removed from the codes map.
          ;(event as Y.YMapEvent<any>).keysChanged.forEach((key) => {
            try {
              const [id] = JSON.parse(key)
              ids.add(id)
            } catch {}
          })
        } else {
          // A Y.Text content changed.
          // event.path is relative to `codes`, so path[0] is the key of the
          // Y.Text in the map: '[id, i, j]'.
          try {
            const [id] = JSON.parse(event.path[0] as string)
            ids.add(id)
          } catch {}
        }
      }

      if (ids.size > 0) {
        this.callback(this.getCode(ids), 'code')
      }
    })
  }

  encode() {
    return Y.encodeStateAsUpdate(this.doc)
  }

  destroy() {
    this.doc.destroy()
  }

  log() {
    console.warn('*********** PEERS ***********')
    console.warn(this.getPeers())
    console.warn('*********** CURSORS ***********')
    console.warn(this.getCursors())
    console.warn('*********** STATE ***********')
    console.warn(this.doc.toJSON())
    /*console.warn('*********** DATA ************')
    console.warn(this.doc)
    */
  }

  protected initMap(map: Y.Map<any>, id: number, data: State.Data[]) {
    if (data.length === 0) return

    for (let i = 0; i < data.length; i++) {
      // Only write our own answer. LiaScript's join payload includes other
      // peers' answers from its local cache — we must never write those, as
      // each peer is the sole owner of their composite key.
      const ownValue = data[i][this.peerID]
      if (ownValue === undefined) continue

      // Composite key = [sectionId, questionIdx, peerID] — globally unique per peer.
      const key = JSON.stringify([id, i, this.peerID])

      // Skip if we already have a live answer in the CRDT (e.g. rejoining).
      if (!map.has(key)) {
        map.set(key, ownValue)
      }
    }
  }

  protected initText(id: number, data: State.Data[]) {
    if (data.length === 0) return

    for (let i = 0; i < data.length; i++) {
      for (let j = 0; j < data[i].length; j++) {
        this.initCode(id, i, j, data[i][j])
      }
    }
  }

  getCode(ids: Set<number>): { id: number; data: string[][] }[] {
    let vector: { id: number; data: string[][] }[] = []

    for (const id of ids) {
      vector.push({ id: id, data: this.getAllTexts(id) })
    }

    return vector
  }

  getCursors(): State.Cursor[] {
    if (!this.awareness) return []
    const cursors: State.Cursor[] = []
    for (const [, state] of this.awareness.getStates()) {
      if (state?.cursor && state?.peerID && state.peerID !== this.peerID) {
        cursors.push(state.cursor)
      }
    }
    return cursors
  }

  getPeers(): string[] {
    if (!this.awareness) return []
    const peers: string[] = []
    for (const [, state] of this.awareness.getStates()) {
      if (state?.peerID) peers.push(state.peerID)
    }
    return peers
  }

  removePeer(peerID?: string) {
    if (peerID === undefined) {
      // Remove own presence from awareness so remote peers see us leave.
      this.awareness?.setLocalState(null)
      this.callback(this.encode(), 'exit')
    }
    // Removing a specific remote peer is not needed — awareness automatically
    // clears their state when they disconnect from the transport.
  }

  id(id1: number, id2: number, id3?: number) {
    if (id3 === undefined) {
      return JSON.stringify([id1, id2])
    }

    return JSON.stringify([id1, id2, id3])
  }

  getMaps(id: number, map: Y.Map<any>): State.Data[] {
    // Prefix check avoids JSON.parse for keys belonging to other sections.
    const prefix = `[${id},`
    const result: State.Data[] = []

    for (const [key, value] of map) {
      if (!key.startsWith(prefix)) continue
      try {
        const parsed = JSON.parse(key)
        if (parsed.length !== 3) continue
        const qi: number = parsed[1]
        const peer: string = parsed[2]
        if (!result[qi]) result[qi] = {}
        result[qi][peer] = value
      } catch {}
    }

    // Fill sparse holes (questions with no answers yet) with empty objects.
    for (let i = 0; i < result.length; i++) {
      if (!result[i]) result[i] = {}
    }

    return result
  }

  getAllTexts(id: number): string[][] {
    let vector: string[][] = []
    let obj: undefined | Y.Text

    for (let i = 0; this.codes.has(this.id(id, i, 0)); i++) {
      let subVector: string[] = []

      for (let j = 0; this.codes.has(this.id(id, i, j)); j++) {
        obj = this.codes.get(this.id(id, i, j))

        subVector.push(obj?.toString() || '')
      }

      vector.push(subVector)
    }

    return vector
  }

  addQuiz(id: number, i: number, value: any) {
    this.addRecord(this.quizzes, id, i, value)
  }

  addSurvey(id: number, i: number, value: any) {
    this.addRecord(this.surveys, id, i, value)
  }

  addRecord(map: Y.Map<any>, id: number, i: number, value: any) {
    // Composite key guarantees each peer owns a unique slot — pure CRDT.
    map.set(JSON.stringify([id, i, this.peerID]), value)
  }

  initCode(id: number, i: number, j: number, value: string) {
    if (!this.codes.has(this.id(id, i, j))) {
      const backup = this.doc.clientID

      this.doc.clientID = 0

      const code = new Y.Text()
      code.insert(0, value)
      this.codes.set(this.id(id, i, j), code)

      this.doc.clientID = backup
    }
  }

  addChatMessage(msg: string) {
    this.chat.set('' + Date.now(), {
      color: this.getColor(),
      message: msg,
      user: this.peerID,
    })
  }

  updateCode(
    id: number,
    i: number,
    j: number,
    messages: Array<{
      action: 'insert' | 'remove'
      index: number
      content: string
    }>,
  ) {
    if (this.codes.has(this.id(id, i, j))) {
      this.doc.transact(() => {
        const code = this.codes.get(this.id(id, i, j))

        if (code === undefined) return

        for (let msg of messages) {
          switch (msg.action) {
            case 'insert': {
              code.insert(msg.index, msg.content)
              break
            }
            case 'remove': {
              code.delete(msg.index, msg.content.length)
              break
            }
            default: {
              console.warn('Sync code, unknown action ->', msg)
            }
          }
        }
      }, 'code')
    }
  }

  getColor(): string {
    if (!this.color) {
      this.color = helper.getColorFor(this.peerID)
    }
    return this.color
  }

  setCursor(
    section: number,
    cursor: {
      project: number
      file: number
      state: {
        position: { row: number; column: number }
        selection: [] | [number, number, number, number]
      }
    },
  ) {
    this.awareness?.setLocalStateField('cursor', {
      id: this.peerID,
      section,
      project: cursor.project,
      file: cursor.file,
      state: cursor.state,
      color: this.getColor(),
    })
  }

  removeCursor() {
    this.awareness?.setLocalStateField('cursor', null)
  }
}
