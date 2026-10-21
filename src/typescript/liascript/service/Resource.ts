import log from '../log'

var elmSend: Lia.Send | null = null

// sessionStorage key, the course card opens a course to be stored offline
const OFFLINE = 'lia-offline'

/**
 * Service module for dynamically loading/injecting external resources into
 * the HTML header. Currently supported are JavaScript and CSS files.
 */
export const Service = {
  /**
   * Service identifier 'resource', that is used to while service routing.
   */
  PORT: 'resource',

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_
  },

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
      case 'module': {
        const url = event.message.param
        report('js', url)
        loadScript(url, true, event.message.cmd === 'module', ok =>
          report('js', url, ok)
        )
        break
      }

      case 'link': {
        const url = event.message.param
        report('css', url)
        loadLink(url, ok => report('css', url, ok))
        break
      }

      case 'style':
        let tag = document.createElement('style')
        tag.innerHTML = event.message.param
        document.head.appendChild(tag)
        break

      case 'offline':
        saveOffline(event)
        break

      case 'offline_open':
        try {
          sessionStorage.setItem(OFFLINE, event.message.param.url)
        } catch (e) {}
        window.location.href = event.message.param.href
        break

      default:
        log.warn('(Service ', this.PORT, ') unknown message =>', event.message)
    }
  },
}

/**
 * Show the loading state of a resource on the loading screen, see `Update.elm`
 * (`resource_log`), `ok` is undefined while it is still loading.
 */
function report(kind: string, url: string, ok?: boolean) {
  elmSend?.({
    reply: true,
    track: [],
    service: 'resource',
    message: { cmd: 'resource_log', param: { kind, url, ok: ok ?? null } },
  })
}

/**
 * Called by `Database.ts` when a course got loaded and stored. If it was opened
 * via "save offline" on its course card, Elm is asked to start `saveOffline`.
 */
export function offlineOpened(readme: string) {
  try {
    if (sessionStorage.getItem(OFFLINE) !== readme) return
    sessionStorage.removeItem(OFFLINE)
  } catch (e) {
    return
  }

  // reply: true, otherwise the sender in index.ts drops the event
  elmSend?.({
    reply: true,
    track: [['offline', -1]],
    service: 'resource',
    message: { cmd: 'offline', param: null },
  })
}

/**
 * Store all media of a course in the cache 'offline', `sw.js` falls back to it
 * if the network fails. The param contains the parsed sections, see
 * `Lia.Update.saveOffline`, the progress is replied as `{slides, total, failed}`
 * (stored and all sections, failed media files).
 */
async function saveOffline(event: Lia.Event) {
  // the media urls per section, the logo belongs to the first one, data: and
  // blob: urls need no cache
  const sections: string[][] = event.message.param.sections.map(
    (section: any, i: number) => {
      const urls = new Set<string>()
      if (i === 0 && event.message.param.logo) {
        urls.add(event.message.param.logo)
      }
      collectMedia(section.body, urls)
      // recordings of the comments (narrator), see `Lia.Update.commentMedia`
      section.media.forEach((url: string) => urls.add(url))
      return [...urls].filter(url => /^https?:/.test(url))
    }
  )

  const list = [...new Set(sections.flat())]
  const finished = new Set<string>()

  let failed = 0
  let next = 0
  let lastReply = 0

  // a section counts as stored, if all of its media are processed
  const reply = () => {
    lastReply = Date.now()
    event.message.param = {
      slides: sections.filter(urls => urls.every(url => finished.has(url)))
        .length,
      total: sections.length,
      failed,
    }
    elmSend?.(event)
  }

  reply()

  // otherwise the browser may evict the cache if storage gets low
  navigator.storage?.persist?.().catch(() => {})

  const cache = await caches.open('offline')

  const work = async () => {
    while (next < list.length) {
      const url = list[next++]

      try {
        if (!(await cache.match(url))) {
          // without CORS the response is opaque, still fine for <img>.
          // no-store: a playing video leaves a partial (206) response in the
          // HTTP cache, which the Cache API rejects
          const response = await fetch(url, { cache: 'no-store' }).catch(() =>
            fetch(url, { mode: 'no-cors', cache: 'no-store' })
          )

          if (!response.ok && response.type !== 'opaque') {
            throw new Error('HTTP ' + response.status)
          }

          await cache.put(url, response)
        }
      } catch (e: any) {
        failed++
        log.warn('offline: could not store', url, e)

        if (e?.name === 'QuotaExceededError') {
          while (next < list.length) {
            finished.add(list[next++])
            failed++
          }
        }
      }

      finished.add(url)

      if (Date.now() - lastReply > 500) reply()
    }
  }

  // ponytail: 4 parallel downloads, keeps rate limits of hosters in mind
  await Promise.all([work(), work(), work(), work()])
  reply()
}

/**
 * Collect all media urls from parsed sections (`Lia.Markdown.Json.Encode`):
 * images, audio and video files (streams like YouTube cannot be stored) and
 * the `src`/`poster` of HTML media elements.
 */
function collectMedia(json: any, urls: Set<string>) {
  if (Array.isArray(json)) {
    json.forEach(item => collectMedia(item, urls))
    return
  }

  if (!json || typeof json !== 'object') return

  if (
    typeof json.url === 'string' &&
    ('Image' in json ||
      (('Audio' in json || 'Movie' in json) && json.stream === false))
  ) {
    urls.add(json.url)
  }

  if (
    json.Node &&
    ['img', 'video', 'audio', 'source', 'track'].includes(
      String(json.Node.tag).toLowerCase()
    )
  ) {
    for (const [key, value] of json.Node.a || []) {
      if (['src', 'poster'].includes(String(key).toLowerCase())) {
        urls.add(value)
      }
    }
  }

  for (const key in json) collectMedia(json[key], urls)
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
  asModule = false,
  callback?: (ok: boolean) => void
) {
  // try to load all local scripts as blobs
  if (!url.startsWith('blob:') && origin(url) === window.location.origin) {
    loadScriptAsBlob(url, withSemaphore, asModule, callback)
    return
  }

  // raw.githubusercontent.com always fails via normal script tag — load as blob directly
  if (url.startsWith('https://raw.githubusercontent.com/')) {
    if (withSemaphore) window.LIA.eventSemaphore++
    loadScriptAsBlob(url, withSemaphore, asModule, callback)
    return
  }

  try {
    let tag = document.createElement('script')

    tag.src = url
    tag.async = false // load all scripts in order
    tag.defer = true // load the scripts after the main HTML content
    tag.type = 'text/javascript'

    if (asModule) {
      tag.type = 'module'
    }

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
        console.warn('could not load =>', url)

        if (window.LIA.fetchError) {
          window.LIA.fetchError('script', url)
          window.LIA.eventSemaphore--
          // if (callback) callback(false)
        } else if (!url.startsWith('blob:')) {
          // Semaphore stays elevated — loadScriptAsBlob will decrement when the blob
          // script finishes loading (or fails), keeping LIA blocked until then.
          loadScriptAsBlob(url, withSemaphore, asModule, callback)
        } else {
          // Blob script itself failed — now release the semaphore slot.
          window.LIA.eventSemaphore--
          if (callback) callback(false)
        }
      }
    }

    document.head.appendChild(tag)
  } catch (e) {
    log.warn('failed loading script => ', e)
    loadScriptAsBlob(url, withSemaphore, asModule)
  }
}

function loadScriptAsBlob(
  url: string,
  withSemaphore: boolean,
  asModule: boolean,
  callback?: (ok: boolean) => void
) {
  if (url.startsWith('blob:')) return

  loadAsBlob(
    'script',
    url,
    (blobUrl: string) => {
      // Create the blob script tag directly — do NOT go back through loadScript(),
      // which would unconditionally re-increment the semaphore.
      try {
        const blobTag = document.createElement('script')
        blobTag.src = blobUrl
        blobTag.async = false
        blobTag.defer = true
        blobTag.type = asModule ? 'module' : 'text/javascript'

        if (withSemaphore) {
          blobTag.onload = () => {
            window.LIA.eventSemaphore--
            log.info('successfully loaded blob =>', url)
            if (callback) callback(true)
          }
          blobTag.onerror = () => {
            window.LIA.eventSemaphore--
            console.warn('could not execute blob =>', url)
            if (callback) callback(false)
          }
        } else if (callback) {
          blobTag.onload = () => callback(true)
          blobTag.onerror = () => callback(false)
        }

        document.head.appendChild(blobTag)
      } catch (e) {
        log.warn('failed inserting blob script =>', e)
        if (withSemaphore) window.LIA.eventSemaphore--
        if (callback) callback(false)
      }
    },
    (_url, _error) => {
      if (withSemaphore) window.LIA.eventSemaphore--
      if (callback) callback(false)
    }
  )
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
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP ${response.status} loading ${url}`)
      }

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
    .catch(e => {
      window.LIA.fetchError(tag, url)
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
function loadLink(url: string, callback?: (ok: boolean) => void) {
  const asBlob = () =>
    loadAsBlob(
      'link',
      url,
      (blobUrl: string) => loadLink(blobUrl, callback),
      () => callback?.(false)
    )

  try {
    // Chrome will CORB block this request, therefor it can only be loaded as blob
    if (!!window['chrome'] && !url.startsWith('blob:')) {
      throw new Error('Chrome does not support CORS for CSS files')
    }

    let tag = document.createElement('link')
    tag.href = url
    tag.rel = 'stylesheet'
    tag.type = 'text/css'

    tag.onload = () => callback?.(true)
    tag.onerror = _event => {
      console.warn('could not load =>', url)
      if (url.startsWith('blob:')) callback?.(false)
      else asBlob()
    }

    document.head.appendChild(tag)
  } catch (e: any) {
    if (url.startsWith('blob:')) {
      log.warn('failed loading style => ', url, e.message)
      callback?.(false)
    } else {
      log.warn('could not load =>', url, e)
      log.warn('will try to import as blob')
      asBlob()
    }
  }
}
