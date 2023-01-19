import * as Y from 'yjs'

import * as State from './state'

import { encode, decode } from 'uint8-to-base64'

const PEERS = 'peers'

const QUIZ = 'q'
const SURVEY = 's'
const CODE = 'c'

function sanitize(data: object, whitelist: string[]) {
  return whitelist.reduce(
    (result, key) =>
      data[key] !== undefined
        ? Object.assign(result, { [key]: data[key] })
        : result,
    {}
  )
}
export class CRDT {
  protected doc: Y.Doc
  protected peers: Y.Map<any>
  protected length: number
  protected peerID: string

  constructor(peerID: string, callback: (event: any) => void) {
    this.doc = new Y.Doc()

    this.doc.on('afterTransaction', callback)

    this.length = 0
    this.peers = this.doc.getMap(PEERS)
    this.peers.set(peerID, true)
    this.peerID = peerID
  }

  init(data: State.Vector) {
    this.length = Math.max(this.length, data.length)

    for (let i = 0; i < data.length; i++) {
      this.initMap(QUIZ, i, data[i][QUIZ])
      this.initMap(SURVEY, i, data[i][SURVEY])
    }
  }

  encode() {
    return encode(Y.encodeStateAsUpdate(this.doc))
  }

  destroy() {
    console.warn('TODO: destroy')
  }

  apply(update: string): boolean {
    const before = Y.encodeStateAsUpdate(this.doc)

    Y.applyUpdate(this.doc, decode(update))

    const after = Y.encodeStateAsUpdate(this.doc)

    return JSON.stringify(before) != JSON.stringify(after)
  }

  log() {
    console.warn('*********** PEERS ***********')
    console.warn(this.peers.toJSON())
    console.warn('*********** STATE ***********')
    console.warn(this.doc.toJSON())
    console.warn('*********** DATA ************')
    console.warn(this.doc)
  }

  protected initMap(key: string, id: number, data: State.Data[]) {
    if (data.length === 0) {
      // this.getMap(key, id, 0)
      return
    }

    let state
    for (let i = 0; i < data.length; i++) {
      state = this.getMap(key, id, i)

      for (const identifier in data[i]) {
        state.set(identifier, data[i][key])
      }
    }
  }

  toJSON(): State.Vector {
    let vector: State.Vector = []

    for (let i = 0; i < this.length; i++) {
      vector.push({
        s: this.getAllObjects(SURVEY, i),
        q: this.getAllObjects(QUIZ, i),
        c: [],
      })
    }

    return vector
  }

  getPeers() {
    const peers = this.peers.toJSON()

    if (peers) {
      return Object.entries(peers)
        .filter(([_, value]) => value)
        .map(([key, _]) => key)
    }

    return []
  }

  removePeer(peerID: string) {
    this.peers.set(peerID, false)
  }

  id(key: string, id1: number, id2: number) {
    return key + ':' + id1 + ',' + id2
  }

  has(key: string, id: number, i: number) {
    return this.doc.share.has[this.id(key, id, i)] !== undefined
  }

  getMap(key: string, id: number, i: number): Y.Map<any> {
    return this.doc.getMap(this.id(key, id, i))
  }

  getAllObjects(key: string, id: number): any {
    let vector: any[] = []
    let obj: any

    for (let i = 0; this.has(key, id, i); i++) {
      obj = this.getMap(key, id, i)
      vector.push(obj.toJSON())
    }

    return vector
  }

  addQuiz(id: number, i: number, value: any) {
    this.addRecord(QUIZ, id, i, value)
  }

  addSurvey(id: number, i: number, value: any) {
    this.addRecord(SURVEY, id, i, value)
  }

  addRecord(key: string, id: number, i: number, value: any) {
    let record = this.getMap(key, id, i)
    record.set(this.peerID, value)
  }
}
