declare global {
  interface Window {
    debug__?: boolean;
  }
}

const log = {
  info: function () {
    if (window.debug__) console.log('LiaInfo: ', ...arguments)
  },

  warn: function () {
    if (window.debug__) console.warn('LiaWarn: ', ...arguments)
  },

  error: function () {
    console.error('LiaError: ', ...arguments)
  }
}

export default log
