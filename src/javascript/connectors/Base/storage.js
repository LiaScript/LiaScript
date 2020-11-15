class LiaStorage {
  constructor() {
    this._init()
  }

  _init() {
    let store = this._setLocal
  }

  getItems(key = []) {
    if (typeof key === 'string') key = [key]

    let rslt = {}
    for (let i = 0; i < key.length; i++) {
      let value = localStorage.getItem(key[i])

      rslt[key[i]] = value ? JSON.parse(value) : value
    }

    return rslt
  }

  setItems(dict) {
    this._setLocal(dict)
  }

  _setLocal(dict) {
    if (typeof dict === 'object') {
      for (const [key, value] of Object.entries(dict)) {
        localStorage.setItem(key, JSON.stringify(value))
      }
    }
  }
};

export {
  LiaStorage
}