import * as Y from 'yjs'
import * as awarenessProtocol from 'y-protocols/awareness'
import * as State from './state'
import * as helper from '../../helper'
import * as peerCrypto from './peerCrypto'
import { getOrCreateKey } from './keyStore'

import { YKeyValue } from 'y-utility/y-keyvalue'

const QUIZ = 'q'
const SURVEY = 's'
const CODE = 'c'
const META = 'meta'
const IDENTITY = 'name'
const USER = 'user'
const OWNER_KEY = 'ownerKey'
const WRAPPED_KEYS = 'wrappedKeys'
const SIGNING_KEYS = 'signingKeys'

type SyncType = typeof QUIZ | typeof SURVEY

export class CRDT {
  protected callback: (event: any, origin: null | string) => void
  public doc: Y.Doc
  public sub: Y.Doc

  // Used by legacy manual-sync providers (Trystero, PubNub, P2PT) as a
  // rough causal tiebreaker. Not needed by the GenericProvider path.
  public timestamp: number = Date.now()

  protected awareness?: awarenessProtocol.Awareness
  protected codes: Y.Map<Y.Text>
  protected chat: YKeyValue<{
    message: String
    color: String
    user: String
    signature?: string
  }>
  protected metadata: Y.Array<string>
  // Durable peerID -> name map, persisted like `user`, so a
  // reconnecting/late-joining owner can still label rows for peers who
  // already left (Awareness alone is live-only and forgets them).
  protected identities: Y.Map<string>
  // peerID -> { q: Y.Map<sectionId, Y.Array<value>>, s: Y.Map<sectionId, Y.Array<value>> }
  // A peer only ever creates/writes inside its own top-level key — a
  // structural single-writer guarantee, no composite-key encoding needed.
  // sectionId is a Y.Map key (string) because it's either a small dense
  // course-section index or a chat timestamp (Date.now()) — genuinely
  // sparse/arbitrary. questionIdx is a Y.Array index because it's always
  // dense within a section, and single-writer-per-array means no
  // concurrent-edit reconciliation cost.
  protected user: Y.Map<Y.Map<any>>
  protected length: number
  protected peerID: string
  protected color?: string

  // 0 = Shared (see Lia/Sync/Types.elm ClassroomMode) - everyone can already
  // read everyone in that mode, so all per-peer encryption below is gated on
  // `classroomMode !== 0`.
  protected classroomMode: number = 0
  protected roomId?: string

  // peerID -> base64 ECDH public key of whoever is currently the owner.
  protected ownerKey: Y.Map<string>
  // peerID -> that peer's own AES content key, ECDH-wrapped for the current
  // owner (see peerCrypto.wrapContentKeyForOwner).
  protected wrappedKeys: Y.Map<string>

  // Own per-peer AES-GCM content key (session-lived, never persisted).
  protected contentKey?: CryptoKey
  protected contentKeyReady?: Promise<CryptoKey>

  // Only populated when this peer is the classroom owner.
  protected ownerKeyPair?: CryptoKeyPair

  // peerId -> unwrapped content key, invalidated whenever the peer's
  // `wrappedKeys` entry changes (see getPeerContentKey).
  protected peerKeyCache: Map<string, { wrapped: string; key: CryptoKey }> =
    new Map()

  // peerID -> base64 ECDSA public verify key. Chat authenticity only -
  // unrelated to classroomMode, published unconditionally by every peer.
  protected signingKeys: Y.Map<string>
  protected signingKeyReady: Promise<CryptoKeyPair>

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

    this.chat = new YKeyValue(this.doc.getArray('chat'))
    this.metadata = this.doc.getArray<string>(META)
    this.identities = this.doc.getMap<string>(IDENTITY)

    this.user = this.doc.getMap<Y.Map<any>>(USER)
    this.ownerKey = this.doc.getMap<string>(OWNER_KEY)
    this.wrappedKeys = this.doc.getMap<string>(WRAPPED_KEYS)

    this.signingKeys = this.doc.getMap<string>(SIGNING_KEYS)
    this.signingKeyReady = peerCrypto.generateSigningKeyPair().then(async (pair) => {
      const pub = await peerCrypto.exportPublicKey(pair.publicKey)
      this.signingKeys.set(this.peerID, pub)
      return pair
    })
  }

  /** Must be called before init(), so classroomMode is known once ownership
   * and quiz/survey writes start happening. roomId only needs to be stable
   * per classroom (course+room+password) - it's just the local key under
   * which this browser's owner keypair is cached in IndexedDB.
   */
  setMode(mode: number, roomId: string) {
    this.classroomMode = mode
    this.roomId = roomId
  }

  async init(data: State.Vector) {
    this.length = Math.max(this.length, data.length)

    // Web Crypto is async, but a Yjs transact callback must be synchronous -
    // so encrypt everything up front, then apply the plain Y-doc writes in
    // one synchronous transact.
    const writes: { type: SyncType; id: number; i: number; value: any }[] = []
    for (let i = 0; i < data.length; i++) {
      await this.collectInitWrites(QUIZ, i, data[i][QUIZ], writes)
      await this.collectInitWrites(SURVEY, i, data[i][SURVEY], writes)
    }

    this.doc.transact(() => {
      for (const w of writes) {
        const section = this.getOwnSectionArray(w.type, w.id)
        // Skip if we already have a live answer in the CRDT (e.g. rejoining).
        if (section.length <= w.i || section.get(w.i) === undefined) {
          this.setArrayValue(section, w.i, w.value)
        }
      }

      for (let i = 0; i < data.length; i++) {
        this.initText(i, data[i][CODE])
      }
    }, this.peerID)

    this.registerCallbacks()

    // Observers are registered AFTER the transact above, so they never fire
    // for data that was just written (own answers) or data that already existed
    // in the CRDT from a sync that completed before init() was called.
    // Explicitly dispatch the current CRDT state to LiaScript once.
    await this.fireInitialState()
  }

  // Only writes our own answer. LiaScript's join payload includes other
  // peers' answers from its local cache - we must never write those, as
  // each peer is the sole owner of their own subtree.
  protected async collectInitWrites(
    type: SyncType,
    id: number,
    data: State.Data[],
    writes: { type: SyncType; id: number; i: number; value: any }[],
  ) {
    if (!data || data.length === 0) return

    for (let i = 0; i < data.length; i++) {
      const ownValue = data[i][this.peerID]
      if (ownValue === undefined) continue

      const value =
        this.classroomMode !== 0
          ? await peerCrypto.encryptValue(
              await this.ensureContentKey(),
              ownValue,
            )
          : ownValue

      writes.push({ type, id, i, value })
    }
  }

  protected async fireInitialState() {
    // Peers
    const peers = this.getPeers()
    if (Object.keys(peers).length > 0) {
      this.callback(peers, 'peer')
    }

    // Identities — everyone ever seen, including peers now offline.
    const identities = this.getIdentities()
    if (Object.keys(identities).length > 0) {
      this.callback(identities, 'identity')
    }

    // Cursors (awareness-based, fire alongside peers)
    const cursors = this.getCursors()
    if (cursors.length > 0) {
      this.callback(cursors, 'cursor')
    }

    // Quizzes — collect all section IDs that have any entries
    const quizIds = this.collectSectionIds(QUIZ)
    if (quizIds.size > 0) {
      this.callback(
        await Promise.all(
          [...quizIds].map(async (id) => ({
            id,
            data: await this.getSection(id, QUIZ),
          })),
        ),
        'quiz',
      )
    }

    // Surveys
    const surveyIds = this.collectSectionIds(SURVEY)
    if (surveyIds.size > 0) {
      this.callback(
        await Promise.all(
          [...surveyIds].map(async (id) => ({
            id,
            data: await this.getSection(id, SURVEY),
          })),
        ),
        'survey',
      )
    }

    // Code editors
    const codeIds = new Set<number>()
    for (const key of this.codes.keys()) {
      try {
        const [id] = JSON.parse(key)
        codeIds.add(id)
      } catch { }
    }
    if (codeIds.size > 0) {
      this.callback(this.getCode(codeIds), 'code')
    }

    // Chat
    const chatMessages = await this.buildChatVector()
    if (chatMessages.length > 0) {
      this.callback(chatMessages, 'chat')
    }
  }

  // Iterates YKeyValue's internal map, verifying every entry's signature.
  // Used for the full initial dump and for a signingKeys-arrival re-check -
  // resending everything is cheap (this is a local port call, not a network
  // send), same philosophy as the quiz/survey observers above.
  protected async buildChatVector(): Promise<any[]> {
    const entries: any[] = []
    for (const [key, entry] of (this.chat as any).map as Map<
      string,
      { key: string; val: any }
    >) {
      entries.push({ ...entry.val, id: parseInt(key) })
    }

    const verified = await Promise.all(
      entries.map((entry) => this.verifyChatEntry(entry)),
    )
    verified.sort((a, b) => a.id - b.id)
    return verified
  }

  // Chat is meant to stay readable by everyone in the room (unlike
  // quiz/survey) - this only authenticates the claimed sender, it never
  // withholds the message.
  protected async verifyChatEntry(entry: {
    color: String
    message: String
    user: String
    signature?: string
    id: number
  }): Promise<any> {
    if (!entry.signature) return { ...entry, verified: false }

    const pub = this.signingKeys.get(String(entry.user))
    if (!pub) return { ...entry, verified: false }

    const ok = await peerCrypto.verifyChatMessage(
      pub,
      { message: String(entry.message), user: String(entry.user), ts: entry.id },
      entry.signature,
    )

    return { ...entry, verified: ok }
  }

  setAwareness(awareness: awarenessProtocol.Awareness, name?: string) {
    this.awareness = awareness
    // Announce own presence
    awareness.setLocalState({ peerID: this.peerID, color: this.getColor(), name })
    // Persist own identity so it survives after this peer goes offline again.
    if (name && this.identities.get(this.peerID) !== name) {
      this.identities.set(this.peerID, name)
    }

    awareness.on(
      'change',
      (_: { added: number[]; updated: number[]; removed: number[] }) => {
        const peers = this.getPeers()
        this.callback(peers, 'peer')
        const cursors = this.getCursors()
        if (cursors.length > 0) this.callback(cursors, 'cursor')
      },
    )

    // A remote peer's state can already be sitting in `awareness` by the
    // time this listener attaches — e.g. their broadcast arrived and was
    // applied while we were still mid-connect, before setAwareness() ran.
    // That doesn't re-fire 'change' for a listener that wasn't there yet, so
    // without this we'd silently show only ourselves until something else
    // happens to change awareness again.
    this.callback(this.getPeers(), 'peer')
  }

  registerCallbacks() {
    // Ownership is decided by the CRDT, not by wall-clock timing — re-derive
    // it every time metadata converges with a remote peer, so a slow initial
    // sync (see claimOwnership's setTimeout) can never leave two peers each
    // permanently believing they're the owner.
    this.metadata.observe(() => {
      this.callback(this.getOwner() === this.peerID, 'ownership')
      this.maybeBecomeOwner().catch((e: any) =>
        console.warn('maybeBecomeOwner failed ->', e),
      )
    })

    // Fires whenever the owner announces (or changes) their public key -
    // every peer re-wraps its own content key against it. Cheap (key-only),
    // and only actually needed again on a genuine owner handover, since the
    // owner's keypair itself is persisted across ordinary reconnects.
    this.ownerKey.observe(() => {
      this.rewrapForCurrentOwner().catch((e: any) =>
        console.warn('rewrapForCurrentOwner failed ->', e),
      )
    })

    // Nested structure (peer -> type -> section -> Y.Array), so a deep
    // observer is required. Yjs does not fire deep events for a nested type
    // that was itself created within the same transaction (see
    // addChangedTypeToTransaction in yjs's transaction.js) — a peer's first
    // answer for a section creates its whole peer/type/section chain lazily,
    // so `event.path` alone can't reliably tell us which section changed.
    // The callback is a local event2elm port call, not a network send, so
    // recomputing full current state on any change is cheap — just resend
    // everything instead of trying to diff precisely.
    this.user.observeDeep((events: Y.YEvent<any>[]) => {
      if (events.length === 0) return

      const quizIds = this.collectSectionIds(QUIZ)
      if (quizIds.size > 0) {
        Promise.all(
          [...quizIds].map(async (id) => ({
            id,
            data: await this.getSection(id, QUIZ),
          })),
        )
          .then((vec) => this.callback(vec, 'quiz'))
          .catch((e: any) => console.warn('quiz decrypt failed ->', e))
      }

      const surveyIds = this.collectSectionIds(SURVEY)
      if (surveyIds.size > 0) {
        Promise.all(
          [...surveyIds].map(async (id) => ({
            id,
            data: await this.getSection(id, SURVEY),
          })),
        )
          .then((vec) => this.callback(vec, 'survey'))
          .catch((e: any) => console.warn('survey decrypt failed ->', e))
      }
    })

    this.identities.observe(() => {
      this.callback(this.getIdentities(), 'identity')
    })

    // Re-verify (and re-send, cheap) the whole chat history whenever a
    // signingKeys entry arrives/changes - covers the case where a chat
    // message synced before its sender's public key did (CRDT convergence
    // race), which would otherwise stay marked unverified forever.
    this.signingKeys.observe(() => {
      this.buildChatVector()
        .then((vector) => {
          if (vector.length > 0) this.callback(vector, 'chat')
        })
        .catch((e: any) => console.warn('chat re-verify failed ->', e))
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
        const additions: { id: number; entry: any }[] = []
        for (let [id, op] of changes) {
          if (op.action === 'add') {
            additions.push({ id: parseInt(id), entry: op.newValue })
          }
        }

        if (additions.length === 0) return

        Promise.all(
          additions.map(({ id, entry }) =>
            this.verifyChatEntry({ ...entry, id }),
          ),
        )
          .then((vector) => this.callback(vector, 'chat'))
          .catch((e: any) => console.warn('chat verify failed ->', e))
      },
    )

    this.codes.observeDeep((events: Y.YEvent<any>[]) => {
      const ids: Set<number> = new Set()

      for (const event of events) {
        if (event.target === this.codes) {
          // A Y.Text was added/removed from the codes map.
          ; (event as Y.YMapEvent<any>).keysChanged.forEach((key) => {
            try {
              const [id] = JSON.parse(key)
              ids.add(id)
            } catch { }
          })
        } else {
          // A Y.Text content changed.
          // event.path is relative to `codes`, so path[0] is the key of the
          // Y.Text in the map: '[id, i, j]'.
          try {
            const [id] = JSON.parse(event.path[0] as string)
            ids.add(id)
          } catch { }
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

  getPeers(): State.Peer {
    if (!this.awareness) return {}

    const peers: State.Peer = {}
    for (const [, state] of this.awareness.getStates()) {
      if (state?.peerID) peers[state.peerID] = state.name
    }

    return peers
  }

  removePeer() {
    // Remove own presence from awareness so remote peers see us leave.
    this.awareness?.setLocalState(null)
  }

  getIdentities(): State.Peer {
    const identities: State.Peer = {}
    for (const [id, name] of this.identities) {
      identities[id] = name
    }
    return identities
  }

  id(id1: number, id2: number, id3?: number) {
    if (id3 === undefined) {
      return JSON.stringify([id1, id2])
    }

    return JSON.stringify([id1, id2, id3])
  }

  // Collect every section id (course index or chat timestamp) that has at
  // least one entry from any peer, for the given sync type.
  protected collectSectionIds(type: SyncType): Set<number> {
    const ids = new Set<number>()
    for (const [, own] of this.user) {
      const typeMap = own.get(type) as Y.Map<any> | undefined
      if (!typeMap) continue
      for (const id of typeMap.keys()) {
        ids.add(Number(id))
      }
    }
    return ids
  }

  // Reassemble one section's data across all peers into the shape Elm's
  // Container.decoder expects: an array indexed by question index, each
  // entry a {peerId: value} map.
  async getSection(id: number, type: SyncType): Promise<State.Data[]> {
    const result: State.Data[] = []

    for (const [peerId, own] of this.user) {
      const typeMap = own.get(type) as Y.Map<any> | undefined
      const section = typeMap?.get(String(id)) as Y.Array<any> | undefined
      if (!section) continue

      for (let qi = 0; qi < section.length; qi++) {
        const raw = section.get(qi)
        if (raw === undefined) continue

        const value = await this.decryptSectionValue(peerId, raw)
        // undefined means "not authorized to read this peer's answer" -
        // omit it entirely, same outcome the Elm-side filter gave before,
        // now actually enforced at the data layer.
        if (value === undefined) continue

        if (!result[qi]) result[qi] = {}
        result[qi][peerId] = value
      }
    }

    // Fill sparse holes (questions with no answers yet) with empty objects.
    for (let i = 0; i < result.length; i++) {
      if (!result[i]) result[i] = {}
    }

    return result
  }

  // classroomMode === 0 (Shared) or a legacy/plaintext value: use as-is.
  // Otherwise: own values decrypt with our own content key; other peers'
  // values only decrypt if we're the current owner (and only really do, if
  // our wrapped-key unwrap succeeds) - anyone else gets `undefined`.
  protected async decryptSectionValue(peerId: string, raw: any): Promise<any> {
    if (this.classroomMode === 0 || !peerCrypto.isEncryptedValue(raw)) {
      return raw
    }

    try {
      if (peerId === this.peerID) {
        return await peerCrypto.decryptValue(await this.ensureContentKey(), raw)
      }

      if (this.getOwner() === this.peerID && this.ownerKeyPair) {
        const key = await this.getPeerContentKey(peerId)
        if (!key) return undefined
        return await peerCrypto.decryptValue(key, raw)
      }
    } catch (e) {
      // Stale/mismatched key (e.g. owner handover mid-flight, or IndexedDB
      // was unavailable when the content key was first generated) - fail
      // soft for this one entry rather than reject the whole section's
      // Promise.all, which would silently drop every other peer's update too.
      return undefined
    }

    return undefined
  }

  protected async getPeerContentKey(
    peerId: string,
  ): Promise<CryptoKey | undefined> {
    const wrapped = this.wrappedKeys.get(peerId)
    if (!wrapped) return undefined

    const cached = this.peerKeyCache.get(peerId)
    if (cached && cached.wrapped === wrapped) return cached.key

    const key = await peerCrypto.unwrapContentKey(
      wrapped,
      this.ownerKeyPair!.privateKey,
    )
    this.peerKeyCache.set(peerId, { wrapped, key })
    return key
  }

  // Persisted (not just session-lived) - a reconnect is already required
  // today to apply any classroom config change (including switching mode),
  // and answers encrypted under a discarded key would become permanently
  // unreadable, including to their own author, without this.
  protected ensureContentKey(): Promise<CryptoKey> {
    if (!this.contentKeyReady) {
      this.contentKeyReady = getOrCreateKey(
        `${this.roomId ?? 'default'}:content:${this.peerID}`,
        () => peerCrypto.generateContentKey(),
      ).then((key) => {
        this.contentKey = key
        return key
      })
    }
    return this.contentKeyReady
  }

  // Called whenever `metadata` converges - becomes a no-op once this peer
  // already has an owner keypair set up, or if it isn't (or is no longer)
  // the owner.
  protected async maybeBecomeOwner() {
    if (this.classroomMode === 0) return
    if (this.getOwner() !== this.peerID) return
    if (this.ownerKeyPair) return

    this.ownerKeyPair = await getOrCreateKey(this.roomId ?? 'default', () =>
      peerCrypto.generateECDHKeyPair(),
    )
    const pub = await peerCrypto.exportPublicKey(this.ownerKeyPair.publicKey)

    if (this.ownerKey.get(this.peerID) !== pub) {
      this.ownerKey.set(this.peerID, pub)
    }
  }

  // Every peer (owner included) re-wraps its own content key whenever the
  // current owner's public key is announced or changes.
  protected async rewrapForCurrentOwner() {
    if (this.classroomMode === 0) return

    const ownerId = this.getOwner()
    if (!ownerId) return

    const ownerPub = this.ownerKey.get(ownerId)
    if (!ownerPub) return

    const contentKey = await this.ensureContentKey()
    const wrapped = await peerCrypto.wrapContentKeyForOwner(
      contentKey,
      ownerPub,
    )

    this.wrappedKeys.set(this.peerID, wrapped)
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
    this.addRecord(QUIZ, id, i, value).catch((e: any) =>
      console.warn('addQuiz failed ->', e),
    )
  }

  addSurvey(id: number, i: number, value: any) {
    this.addRecord(SURVEY, id, i, value).catch((e: any) =>
      console.warn('addSurvey failed ->', e),
    )
  }

  protected async addRecord(
    type: SyncType,
    id: number,
    i: number,
    value: any,
  ) {
    // Encrypt (async) before the transact, which must stay synchronous.
    const finalValue =
      this.classroomMode !== 0
        ? await peerCrypto.encryptValue(await this.ensureContentKey(), value)
        : value

    this.doc.transact(() => {
      const section = this.getOwnSectionArray(type, id)
      this.setArrayValue(section, i, finalValue)
    }, this.peerID)
  }

  // Get-or-create this peer's own { type -> { sectionId -> Y.Array } }
  // subtree. A peer only ever writes inside its own top-level `user` key —
  // pure CRDT, no cross-peer collision possible.
  protected getOwnSectionArray(type: SyncType, id: number): Y.Array<any> {
    let own = this.user.get(this.peerID)
    if (!own) {
      own = new Y.Map()
      this.user.set(this.peerID, own)
    }

    let typeMap = own.get(type) as Y.Map<any> | undefined
    if (!typeMap) {
      typeMap = new Y.Map()
      own.set(type, typeMap)
    }

    let section = typeMap.get(String(id)) as Y.Array<any> | undefined
    if (!section) {
      section = new Y.Array()
      typeMap.set(String(id), section)
    }

    return section
  }

  // Single-writer per array (each peer only ever writes its own path), so a
  // plain delete+insert replace is safe — no concurrent-edit races to
  // reconcile, unlike a collaboratively-edited Y.Array.
  protected setArrayValue(section: Y.Array<any>, i: number, value: any) {
    if (section.length > i) {
      section.delete(i, 1)
    } else {
      while (section.length < i) section.push([undefined])
    }
    section.insert(i, [value])
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

  async addChatMessage(msg: string) {
    const ts = Date.now()
    const keyPair = await this.signingKeyReady
    const signature = await peerCrypto.signChatMessage(keyPair.privateKey, {
      message: msg,
      user: this.peerID,
      ts,
    })

    this.chat.set('' + ts, {
      color: this.getColor(),
      message: msg,
      user: this.peerID,
      signature,
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
    }, name: string
  ) {
    this.awareness?.setLocalStateField('cursor', {
      id: this.peerID,
      section,
      project: cursor.project,
      file: cursor.file,
      state: cursor.state,
      color: this.getColor(),
      name: name,
    })
  }

  removeCursor() {
    this.awareness?.setLocalStateField('cursor', null)
  }

  /** Parse one `metadata` entry. Entries are `"<peerID>@<claimedAt>"`; a bare
   * peerID (written before this format existed) is treated as claimed at
   * time 0, so a pre-existing owner always outranks a fresh claim.
   */
  private parseClaim(raw: string): { id: string; ts: number } {
    const at = raw.lastIndexOf('@')
    return at === -1
      ? { id: raw, ts: 0 }
      : { id: raw.slice(0, at), ts: Number(raw.slice(at + 1)) || 0 }
  }

  claimOwnership() {
    const claims = this.metadata.toArray().map((raw) => this.parseClaim(raw))

    if (!claims.some((c) => c.id === this.peerID)) {
      this.metadata.push([`${this.peerID}@${Date.now()}`])
    }

    this.callback(this.getOwner() === this.peerID, 'ownership')
  }

  /** The owner is whoever claimed earliest, not whoever ended up at array
   * index 0 - two peers can push a claim concurrently (neither has seen the
   * other's claim yet), and Yjs then orders the conflicting inserts by
   * comparing internal per-doc client IDs, which are random per session and
   * have nothing to do with who actually claimed first. Comparing the
   * `claimedAt` timestamp carried in the entry itself is a real, replica-
   * independent ordering instead of leaning on that arbitrary tie-break.
   */
  getOwner(): string | null {
    const claims = this.metadata.toArray().map((raw) => this.parseClaim(raw))

    if (claims.length === 0) return null

    return claims.reduce((min, c) => (c.ts < min.ts ? c : min)).id
  }
}
