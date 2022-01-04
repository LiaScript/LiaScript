declare global {
  interface Window {
    onmsgesturechange?: any
  }
}

enum Dir {
  none = 'none',
  left = 'left',
  right = 'right',
  up = 'up',
  down = 'down',
}

function detect(el: HTMLElement, callback: (_: Dir) => void) {
  let touchSurface = el
  let swipeDir: Dir
  let startX: number
  let startY: number
  let distX: number
  let distY: number
  let threshold = 150
  let restraint = 100
  let allowedTime = 300
  let elapsedTime: number
  let startTime: number
  let isMousedown = false
  let detectTouch =
    !!('ontouchstart' in window) ||
    !!('ontouchstart' in document.documentElement) ||
    !!window.ontouchstart ||
    !!window.Touch ||
    !!window.onmsgesturechange
  //  || (window.DocumentTouch && window.document instanceof window.DocumentTouch)

  let handleSwipe = callback || function (_: Dir) {}

  function isContained(m: HTMLElement, e: any) {
    if (!e) {
      e = window.event
    }

    if (typeof e === 'undefined') return false

    let c = /(click)|(mousedown)|(mouseup)/i.test(e.type)
      ? e.target
      : e.relatedTarget ||
        (e.type === 'mouseover' ? e.fromElement : e.toElement)

    while (c && c !== m) {
      try {
        c = c.parentNode
      } catch (_) {
        c = m
      }
    }

    return c === m
  }

  touchSurface.addEventListener(
    'touchstart',
    function (e: TouchEvent) {
      let touchObj = e.changedTouches[0]
      swipeDir = Dir.none
      startX = touchObj.pageX
      startY = touchObj.pageY
      startTime = new Date().getTime() // record time when finger first makes contact with surface
      // e.preventDefault()
    },
    { passive: true }
  )

  touchSurface.addEventListener(
    'touchmove',
    function (_: TouchEvent) {
      // e.preventDefault() // prevent scrolling when inside DIV
    },
    { passive: true }
  )

  touchSurface.addEventListener(
    'touchend',
    function (e: TouchEvent) {
      let touchObj = e.changedTouches[0]
      distX = touchObj.pageX - startX // get horizontal dist traveled by finger while in contact with surface
      distY = touchObj.pageY - startY // get vertical dist traveled by finger while in contact with surface
      elapsedTime = new Date().getTime() - startTime // get time elapsed
      if (elapsedTime <= allowedTime) {
        // first condition for a swipe met
        if (Math.abs(distX) >= threshold && Math.abs(distY) <= restraint) {
          // 2nd condition for horizontal swipe met
          swipeDir = distX < 0 ? Dir.left : Dir.right
        } else if (
          Math.abs(distY) >= threshold &&
          Math.abs(distX) <= restraint
        ) {
          // 2nd condition for vertical swipe met
          swipeDir = distY < 0 ? Dir.up : Dir.down
        }
      }
      // check that elapsed time is within specified, horizontal dist traveled >= threshold, and vertical dist traveled <= 100
      if (swipeDir !== Dir.none) handleSwipe(swipeDir)
      // e.preventDefault()
    },
    { passive: true }
  )

  if (!detectTouch) {
    document.body.addEventListener(
      'mousedown',
      function (e) {
        if (isContained(touchSurface, e)) {
          let touchObj = e
          swipeDir = Dir.none
          startX = touchObj.pageX
          startY = touchObj.pageY
          startTime = new Date().getTime() // record time when finger first makes contact with surface
          isMousedown = true
          // e.preventDefault()
        }
      },
      { passive: true }
    )

    document.body.addEventListener(
      'mousemove',
      function (_e: MouseEvent) {
        // e.preventDefault() // prevent scrolling when inside DIV
      },
      { passive: true }
    )

    document.body.addEventListener(
      'mouseup',
      function (e: MouseEvent) {
        if (isMousedown) {
          let touchObj = e
          distX = touchObj.pageX - startX // get horizontal dist traveled by finger while in contact with surface
          distY = touchObj.pageY - startY // get vertical dist traveled by finger while in contact with surface
          elapsedTime = new Date().getTime() - startTime // get time elapsed
          if (elapsedTime <= allowedTime) {
            // first condition for a swipe met
            if (Math.abs(distX) >= threshold && Math.abs(distY) <= restraint) {
              // 2nd condition for horizontal swipe met
              swipeDir = distX < 0 ? Dir.left : Dir.right
            } else if (
              Math.abs(distY) >= threshold &&
              Math.abs(distX) <= restraint
            ) {
              // 2nd condition for vertical swipe met
              swipeDir = distY < 0 ? Dir.up : Dir.down
            }
          }
          // check that elapsed time is within specified, horizontal dist traveled >= threshold, and vertical dist traveled <= 100
          if (swipeDir !== Dir.none) handleSwipe(swipeDir)
          isMousedown = false

          // e.preventDefault()
        }
      },
      { passive: true }
    )
  }
}

const Port = 'swipe'

const Service = {
  PORT: Port,

  init: function initNavigation(elem: HTMLElement, elmSend: Lia.Send) {
    detect(elem, function (swipeDir) {
      if (document.getElementsByClassName('lia-modal').length === 0) {
        elmSend({
          reply: true,
          track: [[Port, -1]],
          service: null,
          message: swipeDir,
        })
      }
    })

    elem.addEventListener(
      'keydown',
      (e) => {
        switch (e.key) {
          case 'ArrowRight': {
            if (document.getElementsByClassName('lia-modal').length === 0) {
              elmSend({
                reply: true,
                track: [[Port, -1]],
                service: null,
                message: Dir.left,
              })
            }
            break
          }
          case 'ArrowLeft': {
            if (document.getElementsByClassName('lia-modal').length === 0) {
              elmSend({
                reply: true,
                track: [[Port, -1]],
                service: null,
                message: Dir.right,
              })
            }
            break
          }
        }
      },
      false
    )
  },
}

export default Service
