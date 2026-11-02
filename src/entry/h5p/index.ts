import * as Lia from '../../typescript/liascript/index'

import('../../typescript/connectors/H5P/index').then(function (H5P) {
  const ua = window.navigator.userAgent

  if (ua.indexOf('Trident/') > 0 || ua.indexOf('MSIE ') > 0) {
    console.warn('unsupported browser')

    const elem = document.getElementById('IE-message')

    if (elem) elem.hidden = false
  } else {
    let debug = false

    if (process.env.NODE_ENV === 'development') {
      debug = true
    }

    const app = new Lia.LiaScript(new H5P.Connector(), {
      allowSync: false,
      debug,
      courseUrl: null,
      script: window['liascript_course'] || null,
    })
  }
})
