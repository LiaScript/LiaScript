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

    // Try to load config from URL parameters or localStorage
    let xAPIConfig: any = null

    // Method 1: Check URL parameters for SCORM Cloud launch data
    const urlParams = new URLSearchParams(window.location.search)
    const endpoint = urlParams.get('endpoint')
    const actor = urlParams.get('actor')
    const registration = urlParams.get('registration')
    const activity_id = urlParams.get('activity_id')

    if (endpoint) {
      try {
        let parsedActor = actor
          ? JSON.parse(decodeURIComponent(actor))
          : {
              objectType: 'Agent',
              name: 'Anonymous',
              mbox: 'mailto:anonymous@example.com',
            }

        // Fix SCORM Cloud's array format - convert arrays to single values
        if (parsedActor.name && Array.isArray(parsedActor.name)) {
          parsedActor.name = parsedActor.name[0]
        }
        if (parsedActor.account && Array.isArray(parsedActor.account)) {
          parsedActor.account = parsedActor.account[0]
        }
        if (parsedActor.mbox && Array.isArray(parsedActor.mbox)) {
          parsedActor.mbox = parsedActor.mbox[0]
        }
        if (
          parsedActor.mbox_sha1sum &&
          Array.isArray(parsedActor.mbox_sha1sum)
        ) {
          parsedActor.mbox_sha1sum = parsedActor.mbox_sha1sum[0]
        }
        if (parsedActor.openid && Array.isArray(parsedActor.openid)) {
          parsedActor.openid = parsedActor.openid[0]
        }

        // Fix SCORM Cloud's non-standard account field name
        // xAPI spec uses "homePage" but SCORM Cloud passes "accountServiceHomePage"
        if (parsedActor.account && parsedActor.account.accountServiceHomePage) {
          parsedActor.account.homePage =
            parsedActor.account.accountServiceHomePage
          delete parsedActor.account.accountServiceHomePage
        }
        // Also normalize "accountName" to "name" for the account object
        if (parsedActor.account && parsedActor.account.accountName) {
          parsedActor.account.name = parsedActor.account.accountName
          delete parsedActor.account.accountName
        }

        xAPIConfig = {
          endpoint: endpoint,
          auth: urlParams.get('auth') || '',
          actor: parsedActor,
          courseId: activity_id || '',
          courseTitle: '',
          registration: registration || '',
          debug: true, // Enable debug to see what's happening
        }

        console.log('xAPI launch parameters detected:', {
          endpoint: xAPIConfig.endpoint,
          actor: xAPIConfig.actor,
          registration: xAPIConfig.registration,
          courseId: xAPIConfig.courseId,
        })
      } catch (e) {
        console.warn('Failed to parse launch parameters:', e)
      }
    }

    // Method 2: Try localStorage for standalone testing
    if (!xAPIConfig) {
      try {
        const storedConfig = localStorage.getItem('xapi-config')
        if (storedConfig) {
          xAPIConfig = JSON.parse(storedConfig)
        }
      } catch (e) {
        console.error('Error loading xAPI config from localStorage:', e)
      }
    }

    // Fall back to window config or defaults
    if (!xAPIConfig) {
      xAPIConfig = (window as any)['xAPIConfig'] || {
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

    // Log final configuration for debugging
    if (debug || !xAPIConfig.endpoint) {
      console.log('xAPI Configuration:', {
        endpoint: xAPIConfig.endpoint || '(not set)',
        hasAuth: !!xAPIConfig.auth,
        actor: xAPIConfig.actor,
        courseId: xAPIConfig.courseId || '(not set)',
        registration: xAPIConfig.registration || '(not set)',
      })
    }

    // Show warning if no endpoint configured
    if (!xAPIConfig.endpoint) {
      console.warn(
        'No LRS endpoint configured. xAPI statements will not be tracked. ' +
          'Launch parameters: ' +
          window.location.search
      )
    }

    const app = new Lia.LiaScript(new xAPI.Connector(xAPIConfig), {
      allowSync: false,
      debug,
      courseUrl: null,
      script: (window as any)['liascript_course'] || null,
    })
  }
})
