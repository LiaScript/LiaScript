// @ts-ignore
import * as EMBED from '../embed/index'
import * as PREVIEW from '../preview-lia'
import * as helper from '../../helper'
import * as HTML from './html'

/**
 * Tooltips are presented in one single div that is attached to the very end of
 * the DOM. This ID is used as the main unit to identify this element.
 */
const TOOLTIP_ID = 'lia-tooltip'

/**
 * Currently links pointing to LiaScript-courses are identified by this regular
 * expression, whereby only the part after "/course/?..." is extracted and only
 * if it ends with ".md".
 *
 * TODO: URL-substitution as it is done internally by LiaScript has to be added
 */
const LIASCRIPT_PATTERN =
  /(?:https?:)(?:\/\/)liascript\.github\.io\/course\/\?(.+\.md)/i

/**
 * All retrieved links are stored within this global variable. The key is
 * defined by the URL, whereby the body is a string that should replace the
 * innerHTML of the tooltip-container.
 */
var backup = Object()

/**
 * Main implementation of the Tooltip-webcomponent. Currently with support for
 * three types of pages:
 *
 * 1. pages with an oEmbed service
 * 2. LiaScript courses, pointing to the LiaScript-course website
 * 3. everything else requires to load and interpret the content by using the
 *    `iframe.ts` module
 *
 * It is added to the HTML-DOM by:
 *
 * ```html
 * <preview-link src="url" light="false">
 *    <a href="url">...</a>
 * </preview-link>
 * ```
 *
 * In most cases, the internal element will contain a link, however, the
 * doubling of `src` and `href` is required, since the internal element can
 * als be something else.
 * With the second attribute is it possible to change the light mode of this
 * web component.
 */
class PreviewLink extends HTMLElement {
  /**
   * URL of the page to be previewed
   */
  public sourceUrl: string = ''

  /**
   * once a tooltip has been created, it is locally preserved within this
   * member variable
   */
  public cache: string | null = null

  /**
   * to prevent a site from being fetched multiple times accidentally, which
   * might happen on multiple hover actions
   */
  public isFetching = false

  /**
   * This variable is used to prevent a tooltip from being loaded, if the user
   * clicks or long-presses on a tablet. Such that the link should be clicked.
   */
  public isClicked = false

  /**
   * this marker is used to prevent a tooltip from loading, if the mouse has
   * left the link, but the loading/parsing is still in progress
   */
  public isActive = false

  /**
   * the tooltip container, which has to be initialized with the `initTooltip`
   * function and which identified by `TOOLTIP_ID`
   */
  public container?: HTMLElement

  /**
   * defines weather the tooltip should be displayed in dark or in light-mode
   */
  public lightMode: boolean = true

  constructor() {
    super()
  }

  /**
   * called when the webcomponent is attached to the DOM and becomes visible
   */
  connectedCallback() {
    // the main URL, for which a tooltip has to be created
    this.sourceUrl = this.getAttribute('src') || ''

    // if such an URL exists
    if (this.sourceUrl) {
      // this makes urls more equal
      if (this.sourceUrl.endsWith('/')) {
        this.sourceUrl = this.sourceUrl.slice(0, -1)
      }

      // get the tooltip container
      this.container = document.getElementById(TOOLTIP_ID) || undefined

      // the tooltip-container is required
      // to the first child additional events have to be associated
      if (this.container && this.firstChild) {
        // basic mouse events to cover hovering
        this.firstChild.addEventListener('mouseenter', this._onmouseenter)
        this.firstChild.addEventListener('mouseout', this._onmouseout)
        this.firstChild.addEventListener('click', this._onclick)

        // Accessibility events which are required for keyboard navigation
        this.firstChild.addEventListener('focus', this._onfocus)
        this.firstChild.addEventListener('focusout', this._onfocusout)
        this.firstChild.addEventListener('keyup', this._onescape)
      }
    }
  }

  /**
   * called when the element gets released from the DOM
   */
  disconnectedCallback() {
    if (this.firstChild) {
      // delete all mouse hovering event-listeners
      this.firstChild.removeEventListener('mouseenter', this._onmouseenter)
      this.firstChild.removeEventListener('mouseout', this._onmouseout)
      this.firstChild.removeEventListener('click', this._onclick)

      // delete all keyboard related event-listeners
      this.firstChild.removeEventListener('focus', this._onfocus)
      this.firstChild.removeEventListener('focusout', this._onfocusout)
      this.firstChild.removeEventListener('keyup', this._onescape)
    }
  }

  /**
   * Handler for click-events is used to prevent a tooltip from being loaded,
   * if the user clicks onto the link.
   */
  _onclick() {
    const parent = this.parentElement as PreviewLink

    parent.isActive = false
    parent.isClicked = true
  }

  /**
   * for web-accessibility reasons, handles the keyboard escape, which becomes
   * handy if tab is used for navigation
   *
   * @param event
   */
  _onescape(event: any) {
    if (event.code === 'Escape') {
      const parent = this.parentElement as PreviewLink

      // this is required to enforce closing the tooltip even if the mouse is
      // still hovering this element, such that it is hold alive by the main
      // hover-events instantiated within `initTooltip()`
      parent.setAttribute('data-active', 'false')
      parent.deactivate()
    }
  }

  /**
   * handler for basic mouse hovering
   */
  _onmouseenter() {
    // show, that there is some progress going on
    this.style.cursor = 'progress'

    // activate the tooltip at the current mouse-position
    const boundingBox = this.getBoundingClientRect()
    ;(this.parentElement as PreviewLink).activate(
      boundingBox.left + boundingBox.width / 2,
      boundingBox.top + boundingBox.height / 2
    )
  }

  /**
   * this event handler is called, if the mouse is not hovering anymore.
   */
  _onmouseout() {
    ;(this.parentElement as PreviewLink).deactivate()
  }

  /**
   * activate the tooltip if the current link received the focus
   *
   * @param _event - not required
   */
  _onfocus(_event: any) {
    // in this case the center of the bounding box of the element in focus is
    // used as the marker for the activation
    const boundingBox = this.getBoundingClientRect()
    ;(this.parentElement as PreviewLink).activate(
      boundingBox.left + boundingBox.width / 2,
      boundingBox.top + boundingBox.height / 2
    )
  }

  /**
   * as the opposite to onfocus, this closed the tooltip, when the link looses
   * its focus
   */
  _onfocusout() {
    const parent = this.parentElement as PreviewLink

    // without this, the deactivate function might not trigger on tablets
    // the "data-active" is only required for mouse manipulation
    if (parent.container) {
      parent.container.setAttribute('data-active', 'false')
    }
    parent.deactivate()
  }

  /**
   * Helper method to calculate the ideal positioning of the tooltip on the
   * screen
   *
   * @param positionX
   * @param positionY
   */
  activate(positionX: number, positionY: number) {
    if (this.container) {
      // mark the tooltip as activated
      this.isActive = true

      if (this.isClicked) {
        this.isClicked = false
        return
      }

      // Calculate the tooltip positioning
      this.container.style.left = `${
        positionX - (425 * positionX) / window.innerWidth
      }px`
      if (positionY * 1.5 > window.innerHeight) {
        this.container.style.top = ''
        this.container.style.bottom = `${window.innerHeight - positionY + 10}px`
      } else {
        this.container.style.top = `${positionY + 10}px`
        this.container.style.bottom = ''
      }

      // Check if we already have cached tooltip data
      if (this.cache) {
        this.show()
      } else if (backup[this.sourceUrl]) {
        this.cache = backup[this.sourceUrl]
        this.show()
      } else if (!this.isFetching) {
        this.isFetching = true
        let self = this

        // Check if this is a link to a LiaScript course
        let liascript_url = this.sourceUrl.match(LIASCRIPT_PATTERN)
        if (liascript_url) {
          PREVIEW.fetch(
            liascript_url[1],
            function (
              url: string,
              meta: {
                title?: string
                description?: string
                logo?: string
                logo_alt?: string
              }
            ) {
              self.cache = toCard(
                self.sourceUrl,
                meta.title,
                meta.description,
                meta.logo,
                meta.logo_alt
              )
              self.show()
            }
          )
        } else {
          // Generalize to detect Wikimedia project links (Wikipedia, Wiktionary, Wikibooks, etc.)
          const wikimediaRegex =
            /\/\/([a-z]+)\.(wikipedia|wiktionary|wikibooks|wikinews|wikiquote|wikisource|wikiversity|wikivoyage|wikimedia|wikidata)\.org\/wiki\/([^#?\s]+(?:\([^#?\s]*\)[^#?\s]*)*)/i
          const wikimediaMatch = this.sourceUrl.match(wikimediaRegex)
          if (wikimediaMatch) {
            let lang = wikimediaMatch[1]
            let project = wikimediaMatch[2]
            let title = wikimediaMatch[3]
            // Decode first to avoid double encoding (e.g. '%28' becomes '(')
            try {
              title = decodeURIComponent(title)
            } catch (e) {
              console.error('Error decoding title:', e)
            }
            // Re-encode the title for a proper API request
            let apiUrl = `https://${lang}.${project}.org/api/rest_v1/page/summary/${encodeURIComponent(
              title
            )}`

            window
              .fetch(apiUrl, {
                headers: {
                  Accept: 'application/json',
                },
              })
              .then((response) => {
                if (!response.ok) {
                  throw new Error(`HTTP error! status: ${response.status}`)
                }
                return response.json()
              })
              .then((data) => {
                this.cache = toCard(
                  this.sourceUrl,
                  data.title,
                  data.extract,
                  data.thumbnail?.source,
                  data.thumbnail?.caption
                )
                this.show()
              })
              .catch((error) => {
                console.error('Wikimedia API error:', error)
                // Fallback: try using oEmbed or direct HTML parsing if the API fails
                EMBED.extract(this.sourceUrl, {})
                  .then((data) => {
                    this.cache = toCard(
                      this.sourceUrl,
                      data.title,
                      undefined,
                      data.thumbnail_url
                    )
                    this.show()
                  })
                  .catch((_) => {
                    fetch(
                      this.sourceUrl,
                      function (doc: string) {
                        this.parse(doc)
                      }.bind(this)
                    )
                  })
              })
          } else {
            // For all other links, try the oEmbed service first
            try {
              EMBED.extract(this.sourceUrl, {})
                .then((data) => {
                  this.cache = toCard(
                    this.sourceUrl,
                    data.title,
                    undefined,
                    data.thumbnail_url
                  )
                  this.show()
                })
                .catch((_) => {
                  // If no oEmbed service exists, fetch and parse the full HTML
                  fetch(
                    this.sourceUrl,
                    function (doc: string) {
                      this.parse(doc)
                    }.bind(this)
                  )
                })
            } catch (e) {}
          }
        }
      }
    }
  }

  /**
   * Helper for deactivating the tooltip
   */
  deactivate() {
    if (
      this.container &&
      // this is false, when the mouse is above the tooltip
      this.container.getAttribute('data-active') === 'false'
    ) {
      // this has to be set to false in order to prevent a later displayed
      // tooltip, due to some loading delay
      this.isActive = false
      this.container.style.display = 'none'
      this.container.style.zIndex = '-1000'
    }
  }

  /**
   * Load the doc-string into an iframe-sandbox and query it for the main
   * information.
   *
   * @param doc
   */
  parse(html: string) {
    // if for some reason, there has already been a tooltip cached
    if (this.cache !== null) {
      this.show()
      return
    }

    // run a local extractor to get all required values
    let data = HTML.parse(this.sourceUrl, html)

    // for some reason this might be required to get images from the proxy
    // version, which might change the url
    if (typeof data.image == 'string') {
      // this cleans up the image url, if it is behind the proxy, which
      // looks like this `https://proxy.../"realImageURL"`
      const url = data.image.match(/.*?%22(.*)\/%22/)
      if (url && url.length == 2) {
        data.image = url[1]
      }
    }

    // create a new tooltip
    this.cache = toCard(
      data.url,
      data.title,
      data.description,
      data.image,
      data.image_alt
    )

    // if there is no tooltip, the reference to the tooltip container gets
    // deleted to prevent it from loading an empty div
    if (this.cache === '') {
      this.container = undefined
    }

    this.show() // show the tooltip

    // remove the iframe from the DOM, since it is not needed anymore
  }

  /**
   * display the tooltip
   */
  show() {
    if (
      this.container && // tooltip container
      this.cache && // HTML string
      this.isActive // has not been deactivated so far
    ) {
      if (this.lightMode) {
        this.container.style.background = 'white'
        this.container.style.boxShadow = '0 30px 90px -20px rgba(0, 0, 0, 0.3)'
      } else {
        this.container.style.background = '#202020'
        this.container.style.boxShadow =
          '0 30px 90px -20px rgba(120, 120, 120, 0.3)'
      }

      this.container.style.zIndex = '20000'
      this.container.style.display = 'inline-block'
      this.container.innerHTML = this.cache
    }

    // remove the progress cursor from the internal link and set it to default
    if (this.firstChild) (this.firstChild as HTMLElement).style.cursor = ''
  }

  // via this attribute it is possible to use the tooltip either in dark or
  // light-mode
  set light(value) {
    // redraw only if the light mode has changed
    if (this.lightMode !== value) {
      this.lightMode = value
      this.show()
    }
  }
  get light() {
    return this.lightMode
  }
}

/**
 * Generate and return an HTML-string for a tooltip, which is stored within the
 * `backup` variable:
 *
 * ```
 * +-------------+
 * |    image    |
 * |-------------|
 * | title       |
 * | description |
 * | url         |
 * +-------------+
 * ```
 *
 * @param url - link to be opened
 * @param title - of the page
 * @param description - excerpt of the content
 * @param image - associated with the page
 * @returns a HTML-string representation on success, otherwise an empty string
 */
function toCard(
  url?: string,
  title?: string,
  description?: string,
  image?: string,
  image_alt?: string
) {
  if (!url) return ''

  // if the starts with the internal proxy that is used, when CORS errors occur
  url = url.replace(helper.PROXY, '')

  let card = ''

  if (image) {
    try {
      if (!helper.allowedProtocol(image)) {
        // redefine the image url from relative to absolute
        image = new URL(image, url).toString()
      }

      // add a possible alt attribute if exists
      image_alt = image_alt ? `alt="${image_alt}"` : ''

      // the light background is required for transparent images in dark mode
      card += `<img src="${image}" ${image_alt} style="background-color:white; margin-bottom: 1.5rem;">`
    } catch (e) {}
  }
  if (title) card += `<h4>${title}</h4>`
  if (description) card += description

  if (card != '') {
    card += `<hr style="border: 0px; height:1px; background:#888;"/><a style="font-size:x-small; display:block" href="${url}" target="_blank">${url}</a>`
  }

  // backup the result globally, so that a second parsing will not be necessary
  backup[url] = card

  return card
}

/**
 * This has to be called after the DOM has been created. It appends two
 * div-container to the end of the DOM:
 *
 * 1. for putting and showing tooltips
 * 2. for injecting sandbox iframes if the tooltips has to be parsed
 */
export function initTooltip() {
  // create the Tooltip element
  if (!document.getElementById(TOOLTIP_ID)) {
    setTimeout(function () {
      const div = document.createElement('div')

      div.id = TOOLTIP_ID

      // since LiaScript modals can have a z-Index larger than 10000
      div.style.zIndex = '-1000'

      div.style.width = '425px'
      //div.style.height = '400px '
      div.style.padding = '15px'
      div.style.background = 'white'
      div.style.boxShadow = '0 30px 90px -20px rgba(0, 0, 0, 0.3)'
      div.style.position = 'fixed'
      div.style.display = 'none'
      div.style.maxHeight = '480px'
      div.style.overflow = 'auto'

      // this additional marker is used to not close the tooltip, if the user
      // moves the mouse onto the tooltip, this way, the original link triggers
      // a closing, but this is prevented by this second marker
      div.setAttribute('data-active', 'true')

      // these two listeners are required when the mouse hovers the tooltip
      // to stay visible or close it ...
      div.addEventListener('mouseenter', () => {
        div.style.display = 'inline-block'
        div.style.zIndex = '20000'
        div.setAttribute('data-active', 'true')
      })
      div.addEventListener('mouseleave', () => {
        div.style.display = 'none'
        div.style.zIndex = '-1000'
        div.setAttribute('data-active', 'false')
      })

      document.body.appendChild(div)
    }, 0)
  }
}

/**
 * Fetch the HTML-text for a certain website. This might happen two times,
 * if the target website has CORS disabled. The first try is the normal
 * fetch, the second one uses a proxy to get the HTML-string
 *
 * @param url - of the website
 * @param callback - to be called on success
 * @param trial - by default 0, the proxy-trial is 1
 */
function fetch(url: string, callback: (doc: string) => void, trial = 0) {
  // shortcut for directly use the proxy
  if (trial == 0 && proxy(url)) {
    fetch(helper.PROXY + url, callback, 1)
    return
  }

  let http = new XMLHttpRequest()
  http.open('GET', url, true) // async fetch

  http.onload = function (_e) {
    // everything went fine
    if (http.readyState === 4 && http.status === 200) {
      try {
        let html = http.responseText
        try {
          // get the real HTML file
          html = JSON.parse(html).contents
        } catch (e) {}
        callback(html)
      } catch (e) {
        console.warn('fetching', e)
      }
    }
  }

  http.onerror = function (_e) {
    if (trial === 0) {
      // try to fetch the website with a proxy url
      fetch(helper.PROXY + url, callback, 1)
    }
  }

  // start fetching
  http.send()
}

/**
 * helper which checks the url against different servers, which require a
 * proxy and do not allow direct calling.
 *
 * - wikipedia
 */
function proxy(url: string): boolean {
  if (url.search(/wikipedia\.org/gi)) {
    return true
  }

  return false
}

customElements.define('preview-link', PreviewLink)
