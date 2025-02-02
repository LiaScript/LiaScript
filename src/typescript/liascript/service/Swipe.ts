import Lia from '../../liascript/types/lia.d'

declare global {
  interface Window {
    onmsgesturechange?: any
  }
}

/**
 * Touch directions used for internal communication
 */
enum Dir {
  none = 'none',
  left = 'left',
  right = 'right',
  up = 'up',
  down = 'down',
}

/**
 * **Helper:** Simple Swipe detection function.
 *
 * @param el - HTML to look for touch events
 * @param callback - send swipe directions
 */
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

// Used multiple times, that is why it is defined as a constant here
const Port = 'swipe'

/**
 * This 'swipe' Service for key navigation via the left-right arrow-keys or via
 * touch events (swipe left/right), sends navigation events to LiaScript.
 */
const Service = {
  /**
   * Service identifier 'swipe', that is used to while service routing.
   */
  PORT: Port,

  /**
   * Attach an event listener for key pressed and swipe event to the DOM-`element`
   * @param element - DOM element to be observed for key
   * @param elmSend - callback for sending back to Lia
   */
  init: function initNavigation(element: HTMLElement, elmSend: Lia.Send) {
    detect(element, function (swipeDir) {
      sendReply(elmSend, swipeDir)
    })

    element.addEventListener(
      'keydown',
      (e) => {
        if (
          e.key === 'ArrowRight' ||
          (e.altKey && e.shiftKey && (e.key === 'P' || e.key === 'p'))
        ) {
          sendReply(elmSend, Dir.right)
          return
        }

        if (
          e.key === 'ArrowLeft' ||
          (e.altKey && e.shiftKey && (e.key === 'N' || e.key === 'n'))
        ) {
          sendReply(elmSend, Dir.left)
          return
        }
      },
      false
    )
  },
}

/**
 * Helper function for sending, which also test for the necessity to send
 * messages to LiaScript.
 * @param elmSend - callback function
 * @param swipeDir - Direction parameter to be send
 */
function sendReply(elmSend: Lia.Send, swipeDir: Dir) {
  // navigation messages are only send, if and only if, there is no element of
  // class 'lia-modal'. To all LiaScript modals this class is added to prevent
  // a slide change in background...
  if (document.getElementsByClassName('lia-modal').length === 0) {
    elmSend({
      reply: true,
      track: [[Port, -1]],
      service: Port,
      message: {
        cmd: Port,
        param: swipeDir,
      },
    })
  }
  // TODO: Navigation could also be useful for galleries and might another track!
}

export default Service
