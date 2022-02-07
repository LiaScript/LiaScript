import './types/globals'

const log = {
  info: function (...args: any) {
    if (window.LIA.debug) console.info('⭐', ...args)
  },

  warn: function (...args: any) {
    if (window.LIA.debug) console.warn('⭐', ...args)
  },

  error: function (...args: any) {
    console.error('⭐', ...args)
  },
}

export default log
