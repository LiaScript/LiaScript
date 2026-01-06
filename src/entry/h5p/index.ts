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

    // Get H5P configuration from window object
    const h5pConfig = window['h5pConfig'] || {
      courseId: '',
      courseTitle: '',
      debug: false,
    }

    // Enable debug mode if in development
    if (debug) {
      h5pConfig.debug = true
    }

    const app = new Lia.LiaScript(
      new H5P.Connector(h5pConfig),
      false, // allowSync
      debug,
      null,
      window['liascript_course'] || null
    )
  }
})
