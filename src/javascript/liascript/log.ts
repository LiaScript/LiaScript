import Lia from './types/lia.d'

const log = {
  info: function(...args: any) {
    if (window.debug__) console.log('LiaInfo: ', ...args)
  },

  warn: function(...args: any) {
    if (window.debug__) console.warn('LiaWarn: ', ...args)
  },

  error: function(...args: any) {
    console.error('LiaError: ', ...args)
  }
}

export default log
