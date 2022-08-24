import * as Lia from '../../typescript/liascript/index'

import('../../typescript/connectors/Base/index').then(function (Base) {
  let debug = false

  if (process.env.NODE_ENV === 'development') {
    debug = true
  }

  var app = new Lia.LiaScript(
    document.body,
    new Base.Connector(),
    false, // allowSync
    debug
  )

  window.addEventListener('message', (event) => {
    // IMPORTANT: check the origin of the data!
    switch (event.data.cmd) {
      case 'jit':
        if (window.LIA.jit) {
          window.LIA.jit(event.data.param)
        } else {
          console.warn('window.LIA.jit not defined')
        }
        break
      case 'goto':
        window.LIA.gotoLine(event.data.param)
        break
      case 'reload':
        window.location.reload()
        break
      case 'responsivevoice':
        window.LIA.injectResposivevoice(event.data.param)
        break
      default:
        console.warn('could not handle event: ', event)
    }
  })
})
