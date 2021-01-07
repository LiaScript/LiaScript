import './types/globals'

const log = {
  info: function(...args: any) {
    if (window.debug__) console.log('⭐', ...args)
  },

  warn: function(...args: any) {
    if (window.debug__) console.warn('⭐', ...args)
  },

  error: function(...args: any) {
    console.error('⭐', ...args)
  }
}

export default log
