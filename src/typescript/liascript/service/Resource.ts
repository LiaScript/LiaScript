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

      case 'style':
        let tag = document.createElement('style')
        tag.innerHTML = event.message.param
        document.head.appendChild(tag)
        break

      default:
        log.warn('(Service ', this.PORT, ') unknown message =>', event.message)
    }
  },
}

/**
 * This is a custom origin matcher that works also with
 * @param url
 * @returns
 */
function origin(url: string) {
  const match = url.match(/.*?:\/\/[^\/]*/)

  if (match && match.length > 0) return match[0]

  return null
}

/**
 * Load a external JavaScript resource dynamically and attach it to the
 * HTML-head.
 *
 * @param url - A valid URL string
 * @param withSemaphore - indicates it the global semaphore should be applied.
 */
export function loadScript(
  url: string,
  withSemaphore = false,
  callback?: (ok: boolean) => void
) {
  // try to load all local scripts as blobs
  if (!url.startsWith('blob:') && origin(url) === window.location.origin) {
    loadScriptAsBlob(url, withSemaphore)
    return
  }

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
        if (callback) callback(true)
      }
      tag.onerror = function (_e: any) {
        window.LIA.eventSemaphore--
        console.warn('could not load =>', url)

        // try to load all local scripts as blobs
        if (!url.startsWith('blob:')) {
          loadScriptAsBlob(url, withSemaphore, callback)
        } else if (callback) {
          callback(false)
        }
      }
    }

    document.head.appendChild(tag)
  } catch (e) {
    log.warn('failed loading script => ', e)
    loadScriptAsBlob(url, withSemaphore)
  }
}

function loadScriptAsBlob(
  url: string,
  withSemaphore: boolean,
  callback?: (ok: boolean) => void
) {
  if (!url.startsWith('blob:')) {
    loadAsBlob(
      'script',
      url,
      (blobUrl: string) => {
        loadScript(blobUrl, withSemaphore, callback)
      },
      withSemaphore
        ? (_url, _error) => {
            window.LIA.eventSemaphore--
          }
        : undefined
    )
  }
}

function loadAsBlob(
  tag: string,
  url: string,
  onOk: (blobUrl: string) => void,
  onError?: (url: string, e: any) => void
) {
  if (url.startsWith('blob:')) {
    console.warn('failed to load blob', url)
    return
  }

  let type = 'text/'
  switch (tag) {
    case 'script':
      type += 'javascript'
      break
    case 'link':
      type += 'css'
      break
    default:
      type += 'plain'
  }

  fetch(url)
    .then((response) => {
      const header = response.headers.get('Content-Disposition')

      let match = header?.match('filename="([^"]+)"')
      let filename = ''

      if (match && match.length > 0) {
        filename = match[1]
      }

      const src = new URL(url)

      if (filename && filename !== src.pathname.split('/').slice(-1)[0]) {
        throw new Error(
          `false redirect received "${filename}" instead of "${src.pathname}"`
        )
      }

      return response.text()
    })
    .then((text: string) => {
      const blob = new Blob([text], { type })
      const blobUrl = window.URL.createObjectURL(blob)
      onOk(blobUrl)
    })
    .catch((e) => {
      log.warn('could not load', url, 'as blob =>', e.message)
      if (onError) {
        onError(url, e)
      }
    })
}

/**
 * Load a external CSS resource dynamically and attach it to the HTML-head.
 *
 * @param url - A valid URL string
 */
function loadLink(url: string) {
  try {
    // Chrome will CORB block this request, therefor it can only be loaded as blob
    if (!!window['chrome'] && !url.startsWith('blob:')) {
      throw new Error('Chrome does not support CORS for CSS files')
    }

    let tag = document.createElement('link')
    tag.href = url
    tag.rel = 'stylesheet'
    tag.type = 'text/css'

    tag.onerror = (_event) => {
      console.warn('could not load =>', url)
      loadAsBlob('link', url, (blobUrl: string) => {
        loadLink(blobUrl)
      })
    }

    document.head.appendChild(tag)
  } catch (e: any) {
    if (url.startsWith('blob:')) {
      log.warn('failed loading style => ', url, e.message)
    } else {
      log.warn('could not load =>', url, e)
      log.warn('will try to import as blob')
      loadAsBlob('link', url, (blobUrl: string) => {
        loadLink(blobUrl)
      })
    }
  }
}
