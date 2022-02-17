export const Crypto = {
  url: '//cdn.jsdelivr.net/npm/simple-crypto-js@2.5.0/dist/SimpleCrypto.min.js',

  crypt: null,

  check: function (): boolean {
    return window.SimpleCrypto ? true : false
  },

  init: function (password: string) {
    try {
      this.crypt = password.length > 0 ? new SimpleCrypto(password) : null
    } catch (e) {
      console.warn('cypher: ', e)
      this.crypt = null
    }
  },

  encode: function (msg: any): string {
    return this.cypher
      ? this.cypher.encrypt(btoa(encodeURIComponent(JSON.stringify(msg))))
      : JSON.stringify(msg)
  },

  decode: function (msg: string): any {
    return this.cypher
      ? JSON.parse(decodeURIComponent(atob(this.cypher.decrypt(msg))))
      : JSON.parse(msg)
  },
}
