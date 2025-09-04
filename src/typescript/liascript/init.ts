import './types/globals'

export function initGlobals() {
  if (!window.LIA) {
    // @ts-ignore
    window.LIA = {}
  }

  if (!window.LIA.version) {
    window.LIA.version = '0.17.4'
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

if ('serviceWorker' in navigator) {
  let sw = './fetch-worker.js'
  navigator.serviceWorker.register(sw).then(console.log).catch(console.error)
} else {
  const fetching = window.fetch
  const CACHE_NAME = 'fetch-cache'
  const MAX_CACHE_ITEMS = 500

  async function trimCache(cacheName: string, maxItems: number) {
    const cache = await caches.open(cacheName)
    const keys = await cache.keys()
    if (keys.length > maxItems) {
      for (let i = 0; i < keys.length - maxItems; i++) {
        await cache.delete(keys[i])
      }
    }
  }

  window.fetch = async function (...args) {
    const request = new Request(args[0], args[1])
    const url = new URL(request.url, window.location.origin)

    // Only cache if not same origin
    if (url.origin !== window.location.origin) {
      const cache = await caches.open(CACHE_NAME)
      try {
        const response = await fetching(...args)
        if (response.ok) {
          await cache.put(request, response.clone())
          await trimCache(CACHE_NAME, MAX_CACHE_ITEMS)
        }
        return response
      } catch (error) {
        // Network failed, try cache
        const cachedResponse = await cache.match(request)
        if (cachedResponse) {
          return cachedResponse.clone()
        }
        throw error // No cache available, rethrow error
      }
    } else {
      // Same origin: just fetch, no caching
      return fetching(...args)
    }
  }
}
