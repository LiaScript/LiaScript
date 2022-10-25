import log from '../log'

/**
 * Service module for dynamically loading/injecting external resources into
 * the HTML header. Currently supported are JavaScript and CSS files.
 */
export const Service = {
  /**
   * Service identifier 'resource', that is used to while service routing.
   */
  PORT: 'resource',

  /**
   * Generic handler for dynamically external resources. Currently supported
   * commands are:
   *
   * * `script`: referring to external javascript resources (*.js)
   * * `link`: referring to external style-sheets (*.css)
   *
   * @param event
   */
  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'script':
        loadScript(event.message.param, true)
        break

      case 'link':
        loadLink(event.message.param)
        break

      default:
        log.warn('(Service ', this.PORT, ') unknown message =>', event.message)
    }
  },
}

/**
 * Load a external JavaScript resource dynamically and attach it to the
 * HTML-head.
 *
 * @param url - A valid URL string
 * @param withSemaphore - indicates it the global semaphore should be applied.
 */
export function loadScript(url: string, withSemaphore = false) {
  try {
    let tag = document.createElement('script')

    tag.src = url
    tag.async = false // load all scripts in order
    tag.defer = true // load the scripts after the main HTML content
    tag.type = 'text/javascript'

    if (withSemaphore) {
      // this semaphore is used by the system to block the evaluation of scripts
      // originating from a course until all javascript resources are loaded
      window.LIA.eventSemaphore++

      // Decrease the semaphore counter in both cases
      tag.onload = function () {
        window.LIA.eventSemaphore--
        log.info('successfully loaded =>', url)
      }
      tag.onerror = function (e: any) {
        if (url.startsWith('blob:')) {
          window.LIA.eventSemaphore--
          log.warn('could not load blob =>', url, e)
          return
        }

        log.warn('could not load =>', url, e)
        log.warn('will try to import as blob')

        fetch(url)
          .then((response) => response.text())
          .then((script: string) => {
            const blob = new Blob([script], { type: 'text/javascript' })
            const blobUrl = window.URL.createObjectURL(blob)
            loadScript(blobUrl, withSemaphore)
          })
          .catch((e) => {
            window.LIA.eventSemaphore--
            log.warn('could not load as blob =>', url, e)
          })
      }
    }

    document.head.appendChild(tag)
  } catch (e) {
    log.warn('failed loading script => ', e)
  }
}

/**
 * Load a external CSS resource dynamically and attach it to the HTML-head.
 *
 * @param url - A valid URL string
 */
function loadLink(url: string) {
  try {
    let tag = document.createElement('link')
    tag.href = url
    tag.rel = 'stylesheet'

    document.head.appendChild(tag)
  } catch (e: any) {
    if (url.startsWith('blob:')) {
      log.warn('failed loading style => ', url, e.message)

      log.warn('failed loading style as blob =>', url, e)
      return
    }

    log.warn('could not load =>', url, e)
    log.warn('will try to import as blob')

    fetch(url)
      .then((response) => response.text())
      .then((script: string) => {
        const blob = new Blob([script], { type: 'text/css' })
        const blobUrl = window.URL.createObjectURL(blob)
        loadLink(blobUrl)
      })
      .catch((e) => {
        log.warn('could not load as blob =>', url, e)
      })
  }
}
