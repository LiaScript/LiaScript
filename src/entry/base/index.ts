import * as Lia from '../../typescript/liascript/index'

import('../../typescript/connectors/Base/index').then(function (Base) {
  let debug = false

  if (process.env.NODE_ENV === 'development') {
    debug = true
  }

  var app = new Lia.LiaScript(new Base.Connector(), { allowSync: false, debug })

  window.addEventListener('message', (event) => {
    // IMPORTANT: check the origin of the data!
    switch (event.data.cmd) {
      case 'jit':
        if (window.LIA.jit) {
          window.LIA.scrollUpOnMain = false
          window.LIA.focusOnMain = false
          window.LIA.jit(event.data.param)
        } else {
          console.warn('window.LIA.jit not defined')
        }
        break
      case 'compile':
        if (window.LIA.compile) {
          window.LIA.scrollUpOnMain = false
          window.LIA.focusOnMain = false
          window.LIA.compile(event.data.param)
        } else {
          console.warn('window.LIA.compile not defined')
        }
      case 'goto':
        window.LIA.gotoLine(event.data.param)
        break
      case 'reload':
        window.location.reload()
        break
      case 'responsivevoice':
        window.LIA.injectResposivevoice(event.data.param)
        break
      case 'base':
        const base = document.createElement('base')
        base.href = event.data.param
        document.head.appendChild(base)
        break
      case 'inject':
        if (window.injectHandler) {
          window.injectHandler(event.data.param)
        } else {
          console.warn('no injectHandler defined')
        }

        break
      case 'eval':
        try {
          eval(event.data.param)
        } catch (e) {
          console.warn('liascript error: ', event.data.param, e)
        }
        break
      default:
        console.warn('could not handle event: ', event)
    }
  })
})
