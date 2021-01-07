export class LiaStorage {
  constructor() {
  }

  getItems(key: string | string[] = []) {
    if (typeof key === 'string') key = [key]

    let rslt: { [key: string]: any } = {}

    for (let i = 0; i < key.length; i++) {
      let value = localStorage.getItem(key[i])

      rslt[key[i]] = value ? JSON.parse(value) : value
    }

    return rslt
  }

  setItems(dict: object) {
    this._setLocal(dict)
  }

  _setLocal(dict: object) {
    if (typeof dict === 'object') {
      for (const [key, value] of Object.entries(dict)) {
        localStorage.setItem(key, JSON.stringify(value))
      }
    }
  }
};
