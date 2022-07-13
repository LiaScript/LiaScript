import * as Y from 'yjs'

import * as State from './state'

export class CRDT {
  protected doc: Y.Doc
  protected db: Y.Map<any>
  protected length: number

  constructor(peerID: string) {
    this.doc = new Y.Doc()
    this.db = this.doc.getMap('DB')
    this.length = 0

    const peers = new Y.Map()
    peers.set(peerID, true)
    this.db.set('peers', peers)
  }

  init(data: State.Vector) {
    this.length = Math.max(this.length, data.length)

    for (let i = 0; i < data.length; i++) {
      this.initMap('q', i, data[i]['q'])
      this.initMap('s', i, data[i]['s'])
    }
  }

  encode() {
    return Y.encodeStateAsUpdate(this.doc)
  }

  protected initMap(key: string, id: number, data: State.Data[]) {
    for (let i = 0; i < data.length; i++) {
      const newID = this.id(key, id, i)
      const state = this.db.has(newID) ? this.db.get(newID) : new Y.Map()

      for (const key in data[i]) {
        state.set(key, data[i][key])
      }
      this.db.set(newID, state)
    }
  }

  toJSON(): State.Vector {
    let data = this.db.toJSON()
    let vector = []

    for (let i = 0; i < this.length; i++) {
      vector.push({
        s: this.getAllObjects('s', i),
        q: this.getAllObjects('q', i),
      })
    }

    return vector
  }

  id(key: string, id1: number, id2: number) {
    return key + ':' + id1 + ',' + id2
  }

  has(key: string, id: number, i: number) {
    return this.db.has(this.id(key, id, i))
  }

  get(key: string, id: number, i: number) {
    return this.db.get(this.id(key, id, i))
  }

  getAllObjects(key: string, id: number) {
    let vector = []

    for (let i = 0; this.has(key, id, i); i++) {
      const obj = this.get(key, id, i)

      vector.push(obj.toJSON())
    }

    return vector
  }
}
