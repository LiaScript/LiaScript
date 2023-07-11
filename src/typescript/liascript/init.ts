import './types/globals'

export function initGlobals() {
  if (!window.LIA) {
    // @ts-ignore
    window.LIA = {}
  }

  if (!window.LIA.version) {
    window.LIA.version = '0.12.4'
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
