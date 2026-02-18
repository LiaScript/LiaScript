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

    // Try to load config from multiple sources
    let h5pConfig: any = null

    // Method 1: Check URL parameters for xAPI/LRS launch data
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
        if (parsedActor.account && parsedActor.account.accountServiceHomePage) {
          parsedActor.account.homePage =
            parsedActor.account.accountServiceHomePage
          delete parsedActor.account.accountServiceHomePage
        }
        if (parsedActor.account && parsedActor.account.accountName) {
          parsedActor.account.name = parsedActor.account.accountName
          delete parsedActor.account.accountName
        }

        h5pConfig = {
          endpoint: endpoint,
          auth: urlParams.get('auth') || '',
          actor: parsedActor,
          courseId: activity_id || '',
          courseTitle: '',
          registration: registration || '',
          debug: false,
        }

        console.log('H5P xAPI launch parameters detected:', {
          endpoint: h5pConfig.endpoint,
          actor: h5pConfig.actor,
          registration: h5pConfig.registration,
          courseId: h5pConfig.courseId,
        })
      } catch (e) {
        console.warn('Failed to parse H5P launch parameters:', e)
      }
    }

    // Method 2: Try localStorage for standalone testing
    if (!h5pConfig) {
      try {
        const storedConfig = localStorage.getItem('h5p-config')
        if (storedConfig) {
          h5pConfig = JSON.parse(storedConfig)
        }
      } catch (e) {
        console.error('Error loading H5P config from localStorage:', e)
      }
    }

    // Method 3: Fall back to window.h5pConfig
    if (!h5pConfig) {
      h5pConfig = (window as any)['h5pConfig'] || {
        endpoint: '',
        auth: '',
        actor: {
          objectType: 'Agent',
          name: 'Anonymous',
          mbox: 'mailto:anonymous@example.com',
        },
        courseId: '',
        courseTitle: '',
        registration: '',
        debug: false,
      }
    }

    // Enable debug mode if in development
    if (debug) {
      h5pConfig.debug = true
    }

    // Log final configuration for debugging
    if (debug || !h5pConfig.endpoint) {
      console.log('H5P Configuration:', {
        endpoint: h5pConfig.endpoint || '(not set - H5P events only)',
        hasAuth: !!h5pConfig.auth,
        actor: h5pConfig.actor,
        courseId: h5pConfig.courseId || '(not set)',
        registration: h5pConfig.registration || '(not set)',
      })
    }

    // Show info if no endpoint configured
    if (!h5pConfig.endpoint && debug) {
      console.info(
        'No LRS endpoint configured. H5P will capture xAPI events but not send to LRS. ' +
          'To enable LRS tracking, provide endpoint via URL params or window.h5pConfig.'
      )
    }

    const app = new Lia.LiaScript(new H5P.Connector(h5pConfig), {
      allowSync: false,
      debug,
      courseUrl: null,
      script: (window as any)['liascript_course'] || null,
    })
  }
})
