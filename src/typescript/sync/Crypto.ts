export const Crypto = {
  url: 'https://cdn.jsdelivr.net/npm/simple-crypto-js@2.5.0/dist/SimpleCrypto.min.js',

  crypt: null,

  check: function (): boolean {
    // @ts-ignore
    return window.SimpleCrypto ? true : false
  },

  init: function (password?: string) {
    try {
      if (typeof password === 'string' && password.length > 0) {
        // @ts-ignore
        this.crypt = new SimpleCrypto(password)
      } else {
        this.crypt = null
      }
    } catch (e) {
      console.warn('Crypto: ', e)
      this.crypt = null
    }
  },

  encode: function (msg: any): string {
    return this.crypt
      ? this.crypt.encrypt(btoa(encodeURIComponent(JSON.stringify(msg))))
      : JSON.stringify(msg)
  },

  decode: function (msg: string): any {
    return this.crypt
      ? JSON.parse(decodeURIComponent(atob(this.crypt.decrypt(msg))))
      : JSON.parse(msg)
  },
}
