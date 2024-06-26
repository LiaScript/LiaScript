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
        scrollUp()

        // this the active link within the table of contents
        const link = document.getElementById('focusedToc')

        // if it exists and is not in the viewport it is moved into it
        if (link && !link.getAttribute('aria-hidden') && !isInViewport(link)) {
          scrollIntoView('focusedToc', 0)
        }

        break
      }

      case 'scroll_up':
        scrollUp()
        break

      case 'scroll_into_view': {
        scrollIntoView(event.message.param.id, event.message.param.delay)
        break
      }

      case 'scroll_down': {
        setTimeout(function () {
          const elem = document.getElementById(event.message.param.id)

          if (elem) {
            elem.scrollTo({
              top: elem.scrollHeight,
              behavior: 'smooth',
            })
          }
        }, event.message.param.delay)
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
function scrollUp() {
  // every LiaScript slide consists of a main tag
  const main = document.querySelector('main:not([hidden=""])')

  if (main) {
    if (window.LIA.scrollUpOnMain) main.scrollTo(0, 0)

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
 */
function scrollIntoView(id: string, delay: number) {
  setTimeout(function () {
    const elem = document.getElementById(id)

    if (elem) {
      elem.scrollIntoView({ behavior: 'smooth' })
    }
  }, delay)
}

export default Service
