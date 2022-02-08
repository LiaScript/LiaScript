import './types/globals'

const log = {
  info: function (...args: any) {
    if (window.LIA.debug) {
      console.info('⭐', ...args)

      if (window.LIA.log) {
        window.LIA.log('log', args)
      }
    }
  },

  warn: function (...args: any) {
    if (window.LIA.debug) {
      console.warn('⭐', ...args)

      if (window.LIA.log) {
        window.LIA.log('warn', args)
      }
    }
  },

  error: function (...args: any) {
    console.error('⭐', ...args)

    if (window.LIA.log) {
      window.LIA.log('error', args)
    }
  },
}

export default log
