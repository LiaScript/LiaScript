var lia = {
  log: function() {
    if (window.debug__) console.log('LiaLog: ', ...arguments)
  },

  warn: function() {
    if (window.debug__) console.warn('LiaWarn: ', ...arguments)
  },

  error: function() {
    console.error('LiaError: ', ...arguments)
  }
}


export {
  lia
}