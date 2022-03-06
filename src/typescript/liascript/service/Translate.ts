import log from '../log'

import * as RESOURCE from './Resource'

// Checks if there has been a code injection jet
var googleTranslate = false

/**
 * This is required to hide the DOM elements that are injected by the
 * Google-translation API.
 */
function changeGoogleStyles() {
  let goog = document.getElementById(':1.container')

  if (goog) {
    goog.style.visibility = 'hidden'
    document.body.style.top = ''
  }
}

/**
 * Bootstrap for the google-translation API, defines the main configurations.
 *
 * @see <https://www.w3schools.com/howto/howto_google_translate.asp>
 */
function googleTranslateElementInit() {
  // @ts-ignore: will be injected by google
  new google.translate.TranslateElement(
    {
      // use the course lang definition as default
      pageLanguage: document.documentElement.lang,
      // includedLanguages: 'ar,en,es,jv,ko,pa,pt,ru,zh-CN',
      // layout: google.translate.TranslateElement.InlineLayout.HORIZONTAL,
      // multilanguagePage: true,
      // gaTrack: true,
      // gaId: 'todo'
      autoDisplay: false,
    },
    // this defines the `id` of the HTML element that will be replaced by
    // the google-drop-down field for selection languages
    'google_translate_element'
  )
}

/**
 * Inject the Google translation API into the head of the document.
 */
function injectGoogleTranslate() {
  // inject the google translator
  if (!googleTranslate) {
    // TODO:
    // the general URL without protocol needs to be checked with other
    // protocols IPFS, Hyper, etc.
    RESOURCE.loadScript(
      'https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit'
    )

    // Setup the global init function, this function is called by google as a
    // bootstrap and the name has to mach the `cp` parameter of the upper
    // resource.
    window.googleTranslateElementInit = googleTranslateElementInit

    // from now on there won't be ne translations
    googleTranslate = true
  }
}

const Port = 'translate'

/**
 * Service handler for **translations**, currently only google is supported.
 */
const Service = {
  /**
   * Service identifier 'translate', that is used to while service routing.
   */
  PORT: Port,

  /**
   * This adds a special mutation observer for the `lang` attribute within the
   * `<html>` tag. Whenever there is an external system that translates the
   * website, then the change of the `lang` attribute is send back to LiaScript
   * via the `elmSend` function.
   * @param elmSend - callback function for reaching out LiaScript
   */
  init: function (elmSend: Lia.Send) {
    var observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        changeGoogleStyles()

        elmSend({
          reply: true,
          track: [],
          service: Port,
          message: { cmd: 'lang', param: document.documentElement.lang },
        })
      })
    })

    observer.observe(document.documentElement, {
      attributes: true,
      childList: false,
      characterData: false,
      // only observe changes of this specific attribute
      attributeFilter: ['lang'],
    })
  },

  /**
   * Generic handler for event-routing.
   * @param event
   */
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
