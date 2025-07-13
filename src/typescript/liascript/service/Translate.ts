import log from '../log'

import * as RESOURCE from './Resource'

// Checks if there has been a code injection jet
var googleTranslate = false

/**
 * List of RTL (right-to-left) language codes
 */
const RTL_LANGUAGES = [
  'ar', // Arabic
  'fa', // Persian/Farsi
  'he', // Hebrew
  'ur', // Urdu
  'ps', // Pashto
  'sd', // Sindhi
  'yi', // Yiddish
  'ku', // Kurdish
  'dv', // Divehi
  'ckb', // Central Kurdish
]

/**
 * Check if a language code represents an RTL language
 * @param langCode - The language code to check
 * @returns true if the language is RTL, false otherwise
 */
function isRTLLanguage(langCode: string): boolean {
  if (!langCode) return false

  // Convert to lowercase and get the base language code (before any region suffix)
  const baseLang = langCode.toLowerCase().split('-')[0]
  return RTL_LANGUAGES.includes(baseLang)
}

/**
 * Update the dir attribute on the HTML element based on the current language
 * @param langCode - The current language code
 */
function updateDocumentDirection(langCode: string): void {
  try {
    const isRTL = isRTLLanguage(langCode)
    const dirValue = isRTL ? 'rtl' : 'ltr'

    // Set the dir attribute on the document element
    document.documentElement.setAttribute('dir', dirValue)

    // Also update the settings if available
    if (window.LIA?.settings) {
      window.LIA.settings.dir = dirValue
    }

    if (window.LIA?.debug) {
      log.info(
        `Updated document direction to: ${dirValue} for language: ${langCode}`
      )
    }
  } catch (err: any) {
    console.warn('Failed to update document direction:', err.message)
  }
}

/**
 * Check for Google Translate direction classes and update accordingly
 * Google Translate adds "translated-rtl" or "translated-ltr" classes to the HTML element
 */
function checkGoogleTranslateDirection(): void {
  try {
    const htmlElement = document.documentElement
    const classList = htmlElement.classList

    if (classList.contains('translated-rtl')) {
      htmlElement.setAttribute('dir', 'rtl')
      if (window.LIA?.settings) {
        window.LIA.settings.dir = 'rtl'
      }
      if (window.LIA?.debug) {
        log.info(
          'Updated document direction to: rtl (from Google Translate class)'
        )
      }
    } else if (classList.contains('translated-ltr')) {
      htmlElement.setAttribute('dir', 'ltr')
      if (window.LIA?.settings) {
        window.LIA.settings.dir = 'ltr'
      }
      if (window.LIA?.debug) {
        log.info(
          'Updated document direction to: ltr (from Google Translate class)'
        )
      }
    }
  } catch (err: any) {
    console.warn('Failed to check Google Translate direction:', err.message)
  }
}

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

  // this has to be added in order to make the element not loosing the focus,
  // caused by the elm-settings in translations, which will automatically
  // close the menu, if the focus is lost
  let select = document.getElementsByClassName('goog-te-combo')
  if (select.length > 0) {
    select[0].setAttribute('data-group-id', 'translation')
  }

  const removePopup = document.getElementById('goog-gt-tt')
  if (removePopup && removePopup.parentNode) {
    removePopup.parentNode.removeChild(removePopup)
  }

  const style = document.createElement('style')
  style.innerHTML = `font {
    background-color: transparent !important;
    box-shadow: none !important;
  }`
  document.head.appendChild(style)
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
      'https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit',
      false,
      false
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
    // Set initial direction based on current language
    updateDocumentDirection(document.documentElement.lang)

    // Check for existing Google Translate direction classes
    checkGoogleTranslateDirection()

    var observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        changeGoogleStyles()

        // Check for Google Translate direction classes
        checkGoogleTranslateDirection()

        // Update document direction based on the new language
        updateDocumentDirection(document.documentElement.lang)

        let displayNames = new Intl.DisplayNames(['en'], { type: 'language' })

        elmSend({
          reply: true,
          track: [],
          service: Port,
          message: {
            cmd: 'lang',
            param: [
              document.documentElement.lang,
              displayNames.of(document.documentElement.lang),
            ],
          },
        })
      })
    })

    observer.observe(document.documentElement, {
      attributes: true,
      childList: false,
      characterData: false,
      // observe changes of lang attribute and classList for Google Translate classes
      attributeFilter: ['lang', 'class'],
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
