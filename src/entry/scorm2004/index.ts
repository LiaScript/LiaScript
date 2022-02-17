import LiaScript from '../../typescript/liascript/index'

import('../../typescript/connectors/SCORM2004/index').then(function (
  SCORM2004
) {
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

    const app = new LiaScript(
      document.body,
      new SCORM2004.Connector(),
      false, // allowSync
      debug
    )
  }
})
