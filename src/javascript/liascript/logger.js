var lia = {
  log: function () {
    if (window.debug__) console.log('LiaLog: ', ...arguments)

    window.liaLog(JSON.stringify(arguments))
  },

  warn: function () {
    if (window.debug__) console.warn('LiaWarn: ', ...arguments)

    window.liaLog(JSON.stringify(arguments))
  },

  error: function () {
    console.error('LiaError: ', ...arguments)

    window.liaLog(JSON.stringify(arguments))
  }
}

export { lia }
