import log from '../log'

const Service = {
  PORT: 'slide',

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'init': {
        scrollUp()

        const elem = document.getElementById('focusedToc')

        if (elem) {
          if (!isInViewport(elem)) {
            elem.scrollIntoView({
              behavior: 'smooth',
            })
          }
        }

        break
      }

      case 'scrollUp':
        scrollUp()
        break

      case 'scrollIntoView': {
        scrollIntoView(event.message.param.id, event.message.param.delay)
        break
      }

      default: {
        log.warn('(Service Slide) unknown message =>', event.message)
      }
    }
  },
}

function scrollUp() {
  const sec = document.getElementsByTagName('main')[0]

  if (sec) {
    sec.scrollTo(0, 0)

    if (sec.children.length > 0) (sec.children[0] as HTMLElement).focus()
  }
}

function isInViewport(elem: HTMLElement) {
  const bounding = elem.getBoundingClientRect()
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
 * a `delay` of milliseconds.
 *
 * https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollIntoView
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
