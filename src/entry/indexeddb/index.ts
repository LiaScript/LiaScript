import * as Lia from '../../typescript/liascript/index'

import('../../typescript/connectors/Browser/index').then(function (Browser) {
  class Connector extends Browser.Connector {
    hasIndex(): boolean {
      return false
    }
  }

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

    const app = new Lia.LiaScript(
      document.body,
      new Connector(),
      false, // allowSync
      debug
    )
  }
})
