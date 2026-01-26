import './types/globals'
import packageJson from '../../../package.json'
import { allowedProtocol } from '../helper'

export function initGlobals() {
  if (!window.LIA) {
    // @ts-ignore
    window.LIA = {}
  }

  if (!window.LIA.fetch) {
    injectFetch()
  }

  if (!window.LIA.version) {
    window.LIA.version = packageJson.version
  }

  if (!window.LIA.eventSemaphore) {
    window.LIA.eventSemaphore = 0
  }

  if (!window.LIA.img) {
    window.LIA.img = img
  }

  if (window.LIA.focusOnMain == undefined) {
    window.LIA.focusOnMain = true
  }

  if (window.LIA.scrollUpOnMain == undefined) {
    window.LIA.scrollUpOnMain = true
  }

  if (window.LIA.debug === undefined) {
    window.LIA.debug = false
  }

  if (window.LIA.onReady === undefined) {
    window.LIA.onReady = (param: any) => {
      if (parent) {
        parent.postMessage(
          {
            cmd: 'lia-ready',
            param: param,
          },
          '*'
        )
      }
    }
  }

  init('send')
  init('playback')
  init('showFootnote')
  init('goto')
  init('gotoNext')
  init('gotoPrevious')
  init('gotoLine')
  init('lineGoto')
  init('fetchError')

  init('fileUpload')

  init('injectResposivevoice')
}

function init(name: string) {
  // @ts-ignore
  if (!window.LIA[name]) {
    // @ts-ignore
    window.LIA[name] = (_: any) => notDefined(name)
  }
}

function notDefined(name: string) {
  console.log('LIA.' + name + ' not defined')
}

const img = {
  load: function (_url: string, _width: number, _height: number) {
    notDefined('img.load')
  },
  click: function (_url: string) {
    notDefined('img.click')
  },
  zoom: function (e: MouseEvent | TouchEvent) {
    const target = e.target as HTMLImageElement

    if (target) {
      const zooming = e.currentTarget as HTMLImageElement

      if (zooming) {
        if (target.width < target.naturalWidth) {
          var offsetX = e instanceof MouseEvent ? e.offsetX : e.touches[0].pageX
          var offsetY = e instanceof MouseEvent ? e.offsetY : e.touches[0].pageY
          var x = (offsetX / zooming.offsetWidth) * 100
          var y = (offsetY / zooming.offsetHeight) * 100
          zooming.style.backgroundPosition = x + '% ' + y + '%'
          zooming.style.cursor = 'zoom-in'
        } else {
          zooming.style.cursor = ''
        }
      }
    }
  },
}

function injectFetch() {
  // 1) Query contains a direct URL ?http://... or ipfs://... data:
  const rawQuery = window.location.search.slice(1)
  let queryURL = null

  // Accept any protocol (ipfs, https, http, ...)
  if (
    allowedProtocol(rawQuery) &&
    !rawQuery.startsWith('data:') &&
    !rawQuery.startsWith('blob:')
  ) {
    queryURL = rawQuery
  }

  try {
    // 2) Base for "relative to the last path" (directory of the query URL)
    const queryBaseDir = queryURL ? new URL('.', queryURL) : null

    // 3) Base for "/foo" => Root of the current page (any protocol)
    // new URL("/x", location.href) automatically uses the current scheme/authority
    const pageRootBase = new URL('/', window.location.href)

    const isAbsoluteUrl = (s: string) => /^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(s)
    window.LIA.fetch = function (resource, options) {
      try {
        // String-URL
        if (typeof resource === 'string') {
          // a) "/..." => Root of the current page (same protocol/host/port as page)
          if (resource.startsWith('/')) {
            const resolved = new URL(resource, pageRootBase).toString()
            return window.fetch(resolved, options)
          }

          // b) "images/..." => relative to the query URL (if present)
          // (But do not touch absolute URLs like "ipfs://...")
          if (queryBaseDir && !isAbsoluteUrl(resource)) {
            const resolved = new URL(resource, queryBaseDir).toString()
            return window.fetch(resolved, options)
          }

          // c) otherwise normal
          return window.fetch(resource, options)
        }
      } catch (err: any) {
        console.error('window.LIA.fetch =>', (err as Error).message)
      }
      // Request object
      // Note: Request("images/x") is already resolved by the browser relative to the page,
      // i.e., we can no longer reliably reconstruct the original relative form.
      // Therefore, we let Requests pass through unchanged.
      return window.fetch(resource, options)
    }
  } catch (err: any) {
    console.error('Error in URL resolution bases', err.message)

    window.LIA.fetch = window.fetch
  }
}
