import * as Lia from '../../typescript/liascript/index'

import('../../typescript/connectors/XAPI/index').then(function (xAPI) {
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

    // Get xAPI configuration from window object
    const xAPIConfig = window['xAPIConfig'] || {
      endpoint: '',
      auth: '',
      actor: {
        objectType: 'Agent',
        name: 'Anonymous',
        mbox: 'mailto:anonymous@example.com',
      },
      courseId: '',
      courseTitle: '',
      debug: false,
    }

    // Enable debug mode if in development
    if (debug) {
      xAPIConfig.debug = true
    }

    const app = new Lia.LiaScript(
      new xAPI.Connector(xAPIConfig),
      false, // allowSync
      debug,
      null,
      window['liascript_course'] || null
    )
  }
})
