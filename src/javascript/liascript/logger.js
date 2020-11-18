const lia = {
  log: function () {
    if (window.debug__) console.log('LiaLog: ', ...arguments)

    if (window.liaLog)
      window.liaLog(JSON.stringify(arguments))
  },

  warn: function () {
    if (window.debug__) console.warn('LiaWarn: ', ...arguments)

    if (window.liaLog)
      window.liaLog(JSON.stringify(arguments))
  },

  error: function () {
    console.error('LiaError: ', ...arguments)

    if (window.liaLog)
      window.liaLog(JSON.stringify(arguments))
  }
}

export {
  lia
}
