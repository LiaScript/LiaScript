import log from '../log'

/**
 * Service for **'slide'** used to put change the focus and for scrolling.
 */
const Service = {
  /**
   * Service identifier 'slide', that is used to while service routing.
   */
  PORT: 'slide',

  /**
   * Event handler for all events related to slide events. Currently supported
   * `cmd`s are:
   *
   * * __init__: called on every new slide initialization
   * * __scroll_up__: move the slide to the top
   * * __scroll_into_view__: scroll an element with a particular id and after
   * * __scroll_down__: scroll an element with a particular id down
   *   a particular delay into the viewport
   *
   * @param event - LiaScript event
   */
  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'init': {
        document.title = event.message.param.title

        scrollUp()

        // this the active link within the table of contents
        const link = document.getElementById('focusedToc')

        // if it exists and is not in the viewport it is moved into it
        if (link && !link.getAttribute('aria-hidden') && !isInViewport(link)) {
          scrollIntoView('focusedToc', 500)
        }

        break
      }

      case 'scroll_up':
        scrollUp()
        break

      case 'scroll_into_view': {
        scrollIntoView(
          event.message.param.id,
          event.message.param.delay,
          event.message.param.block
        )
        break
      }

      case 'scroll_down': {
        setTimeout(function () {
          const elem = document.getElementById(event.message.param.id)

          if (elem && elem.scrollTo) {
            elem.scrollTo({
              top: elem.scrollHeight,
              behavior: 'smooth',
            })
          }
        }, event.message.param.delay)
        break
      }

      case 'fullscreen': {
        if (!document.fullscreenElement) {
          document.documentElement.requestFullscreen().catch(err => {
            console.warn(
              `Error attempting to enable fullscreen mode: ${err.message}`
            )
          })
        } else {
          document.exitFullscreen().catch(err => {
            console.error(
              `Error attempting to exit fullscreen mode: ${err.message}`
            )
          })
        }

        break
      }

      default: {
        log.warn('(Service ', this.PORT, ') unknown message =>', event.message)
      }
    }
  },
}

/**
 * Scroll a slide to the start and put the first header element within in focus.
 */
export function scrollUp() {
  // every LiaScript slide consists of a main tag
  const main = document.querySelector('main:not([hidden=""])')

  if (main && main.scrollTo) {
    if (window.LIA.scrollUpOnMain) main?.scrollTo(0, 0)

    // The first element within a slide is in LiaScript the header, in order to
    // improve accessibility this element is put in focus to offer a general
    // starting point for keyboard navigation.
    /*
    if (window.LIA.focusOnMain && main.children.length > 0)
      (main.children[0] as HTMLElement).focus()
    */
  }
}

/**
 * Check if a given element is in the visible viewport. This is mainly used at
 * slide changes to check if the active link within the table of contents is
 * visible.
 *
 * @param element - HTML element to be checked
 * @returns `true` if the element is visible
 */
function isInViewport(element: HTMLElement) {
  const bounding = element.getBoundingClientRect()
  return (
    bounding.top >= 85 &&
    bounding.left >= 0 &&
    bounding.bottom <=
      (window.innerHeight - 40 || document.documentElement.clientHeight - 40) &&
    bounding.right <=
      (window.innerWidth || document.documentElement.clientWidth)
  )
}

/**
 * Move the element with the `id` that was passed smoothly into the view after
 * a `delay` of milliseconds. The delay is mostly required, since it might
 * require a certain time if new elements become visible, maybe they need to
 * be calculated, etc.
 *
 * https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollIntoView
 *
 * @param id - id of the DOM element
 * @param delay - in milliseconds
 * @param block - vertical alignment, defaults to 'start'
 */
export function scrollIntoView(
  id: string,
  delay: number,
  block?: ScrollLogicalPosition
) {
  setTimeout(function () {
    const elem = nearest(
      [...document.querySelectorAll<HTMLElement>('#' + CSS.escape(id))].filter(
        // skip only hidden persistent slides, notes and toc live outside of main
        (el) => !el.closest('main[hidden]')
      )
    )

    if (elem) {
      // Double rAF ensures the browser has completed layout after dynamic
      // content is inserted before attempting to scroll. A single rAF fires
      // before the browser has recalculated positions; the second one fires
      // after the next paint cycle when dimensions are finalised.
      requestAnimationFrame(() => {
        requestAnimationFrame(() => {
          // `behavior: 'smooth'` is ignored on Safari < 15.4 and IE, falling
          // back to an instant scroll. Add `scroll-behavior: smooth` on the
          // <main> container via CSS to cover those browsers.
          scrollTo(elem, block)
        })
      })
    }
  }, delay)
}

// the element the user clicked last, a quiz check or a code run
let lastClick: Node | null = null

// The chat renders every message on its own, so the same id (quiz, survey,
// code) appears once per message: take the one nearest the last click.
function nearest(elems: HTMLElement[]): HTMLElement | null {
  for (let node = lastClick; node; node = node.parentNode) {
    const hit = elems.find((el) => node!.contains(el))
    if (hit) return hit
  }
  return elems[0] ?? null
}

function scrollTo(elem: HTMLElement, block?: ScrollLogicalPosition) {
  try {
    elem.scrollIntoView({ behavior: 'smooth', block })
  } catch (e) {
    // Gecko < 58 (KaiOS) knows neither 'nearest' nor 'center' and throws,
    // align to the bottom then, but only if it is not visible already
    if (!isInViewport(elem)) elem.scrollIntoView(false)
  }
}

// Opening a `<details>` at the bottom of the screen would hide its new content,
// so it is moved into view. Clicks only, `<details open>` on load stays put.
document.addEventListener('click', (event) => {
  lastClick = event.target as Node

  const details = (event.target as HTMLElement)?.closest?.('summary')
    ?.parentElement

  // no `instanceof HTMLDetailsElement`, it is missing on KaiOS (Gecko 48)
  if (details?.tagName === 'DETAILS') {
    // the element toggles after the click handlers have run
    setTimeout(() => {
      if ((details as HTMLDetailsElement).open)
        scrollTo(details, 'nearest')
    }, 0)
  }
})

export default Service
