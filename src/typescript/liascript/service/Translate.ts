import log from '../log'

var googleTranslate = false

function changeGoogleStyles() {
  let goog = document.getElementById(':1.container')

  if (goog) {
    goog.style.visibility = 'hidden'
    document.body.style.top = ''
  }
}

function injectGoogleTranslate() {
  // inject the google translator
  if (!googleTranslate) {
    let tag = document.createElement('script')
    tag.src =
      '//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit'
    tag.type = 'text/javascript'
    document.head.appendChild(tag)

    window.googleTranslateElementInit = function () {
      // @ts-ignore: will be injected by google
      new google.translate.TranslateElement(
        {
          pageLanguage: document.documentElement.lang,
          // includedLanguages: 'ar,en,es,jv,ko,pa,pt,ru,zh-CN',
          // layout: google.translate.TranslateElement.InlineLayout.HORIZONTAL,
          autoDisplay: false,
        },
        'google_translate_element'
      )
    }
    googleTranslate = true
  }
}

const Service = {
  PORT: 'translate',

  init: function (elmSend: Lia.Send) {
    var observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        changeGoogleStyles()

        elmSend({
          reply: true,
          track: [],
          service: 'translate',
          message: { cmd: 'lang', param: document.documentElement.lang },
        })
      })
    })

    observer.observe(document.documentElement, {
      attributes: true,
      childList: false,
      characterData: false,
      attributeFilter: ['lang'],
    })

    googleTranslate = false
  },

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'google':
        injectGoogleTranslate()
        break

      default:
        log.warn('(Service Translate) unknown message =>', event.message)
    }
  },
}

export default Service
