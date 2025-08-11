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

    // Try to load saved config from localStorage first
    let xAPIConfig
    try {
      const storedConfig = localStorage.getItem('xapi-config')
      if (storedConfig) {
        xAPIConfig = JSON.parse(storedConfig)
      } else {
        // Fall back to window config
        xAPIConfig = window['xAPIConfig'] || {
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
      }
    } catch (e) {
      console.error('Error loading xAPI config:', e)
      // Use default config if there's an error
      xAPIConfig = window['xAPIConfig'] || {
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
    }

    // Enable debug mode if in development
    if (debug) {
      xAPIConfig.debug = true
    }

    const app = new Lia.LiaScript(new xAPI.Connector(xAPIConfig), {
      allowSync: false,
      debug,
      courseUrl: null,
      script: window['liascript_course'] || null,
    })
  }
})
