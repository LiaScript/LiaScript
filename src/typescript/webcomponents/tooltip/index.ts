// @ts-ignore
import { extract } from '../embed/index'
import { getTitle, getDescription, getImage } from './iframe'
import { fetch as fetch_LiaScript } from '../preview-lia'
import { PROXY } from '../../helper'

/**
 * Tooltips are presented in one single div that is attached to the very end of
 * the DOM. This ID is used as the main unit to identify this element.
 */
const TOOLTIP_ID = 'lia-tooltip'

/**
 * IFrames are used to load content dynamically if, oEmbed fails and it is also
 * no LiaScript course. To not change the DOM, all iframes are loaded within a
 * div at the end, which is identified by this container ID.
 */
const IFRAME_ID = 'lia-iframe-container'

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
      // get the tooltip container
      this.container = document.getElementById(TOOLTIP_ID) || undefined

      // the tooltip-container is required
      // to the first child additional events have to be associated
      if (this.container && this.firstChild) {
        // basic mouse events to cover hovering
        this.firstChild.addEventListener('mouseenter', this._mouseenter)
        this.firstChild.addEventListener('mouseout', this._out)

        // Accessibility events which are required for keyboard navigation
        this.firstChild.addEventListener('focus', this._onfocus)
        this.firstChild.addEventListener('blur', this._out)
        this.firstChild.addEventListener('keyup', this._escape)
      }
    }
  }

  /**
   * called when the element gets released from the DOM
   */
  disconnectedCallback() {
    if (this.firstChild) {
      // delete all mouse hovering event-listeners
      this.firstChild.removeEventListener('mouseenter', this._mouseenter)
      this.firstChild.removeEventListener('mouseout', this._out)

      // delete all keyboard related event-listeners
      this.firstChild.removeEventListener('focus', this._onfocus)
      this.firstChild.removeEventListener('blur', this._out)
      this.firstChild.removeEventListener('keyup', this._escape)
    }
  }

  /**
   * for web-accessibility reasons, handles the keyboard escape, which becomes
   * handy if tab is used for navigation
   *
   * @param event
   */
  _escape(event: any) {
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
   *
   * @param event
   */
  _mouseenter(event: any) {
    // show, that there is some progress going on
    this.style.cursor = 'progress'

    // activate the tooltip at the current mouse-position
    const parent = this.parentElement as PreviewLink
    parent.activate(event.clientX, event.clientY)
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
   * this event handler is multiple times used to, when the element looses the
   * focus or if the mouse is not hovering anymore
   */
  _out() {
    ;(this.parentElement as PreviewLink).deactivate()
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
      // of course, mark the tooltip as activated
      this.isActive = true

      // This adds some space to the vertical position of the tooltip,
      // which places the tooltip more to the right or to the left, depending
      // on the position and on window width.
      this.container.style.left = `${
        positionX - (425 * positionX) / window.innerWidth
      }px`

      // Similar as above, but the tooltip is either placed above or below the
      // current position.
      if (positionY * 1.5 > window.innerHeight) {
        // placed below if the position is on the upper part of the screen
        this.container.style.top = ''
        this.container.style.bottom = `${window.innerHeight - positionY + 10}px`
      } else {
        // placed above, on the lower part of the screen
        this.container.style.top = `${positionY + 10}px`
        this.container.style.bottom = ''
      }

      // if the tooltip has already been watched
      if (this.cache) {
        this.show()
      }
      // has it been previously stored by another link
      else if (backup[this.sourceUrl]) {
        this.cache = backup[this.sourceUrl]
        this.show()
      }
      // if the fetching process has not started yet
      else if (!this.isFetching) {
        // set this once and for all
        this.isFetching = true

        let self = this

        // check if this is a link to a LiaScript course
        let liascript_url = this.sourceUrl.match(LIASCRIPT_PATTERN)
        if (liascript_url) {
          // apply the fetching function from module `preview-lia.ts`
          fetch_LiaScript(
            liascript_url[1], // extracted markdown url
            function (
              url?: string,
              title?: string,
              description?: string,
              image?: string
            ) {
              self.cache = toCard(self.sourceUrl, title, description, image)
              self.show()
            }
          )
        } else {
          try {
            // try to get the oEmbed resource, this is much cheaper than to
            // parse the entire HTML document
            extract(this.sourceUrl, {})
              .then((data) => {
                self.cache = toCard(
                  self.sourceUrl,
                  data.title,
                  undefined,
                  data.thumbnail_url
                )

                self.show()
              })
              .catch((_) => {
                // if there is no oEmbed-service defined for this URL, then
                // fetch the content from the website and parse it
                fetch(this.sourceUrl, function (doc: string) {
                  self.parseIframe(doc)
                })
              })
          } catch (e) {}
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
  parseIframe(doc: string) {
    // if for some reason, there has already been a tooltip cached
    if (this.cache !== null) {
      this.show()
      return
    }

    // this is the main iframe-container where all iframes are put into
    // see `initTooltip`
    const iframeContainer = document.getElementById(IFRAME_ID)

    if (iframeContainer) {
      // create a secure sandbox
      const iframe = document.createElement('iframe')
      iframe.sandbox.add('allow-same-origin')

      let self = this

      // make it as invisible as possible
      iframe.style.width = '0px'
      iframe.style.height = '0px'
      iframe.style.border = '0'
      iframe.style.display = 'inline'
      iframe.ariaHidden = 'true'

      // add it to the main
      iframeContainer.appendChild(iframe)

      // parse the iframe document after it has been loaded successfully
      iframe.onload = function () {
        let title = getTitle(iframe.contentDocument)
        let description = getDescription(iframe.contentDocument)
        let image = getImage(iframe.contentDocument)

        // if this is set before, the iframe might not be loaded, still
        // removes some more visibility
        iframe.style.display = 'none'

        // getting images from iframes might be tricky, since the proxy might
        // be involved
        if (typeof image == 'string') {
          // this cleans up the image url, if it is behind the proxy, which
          // looks like this `https://proxy.../"realImageURL"`
          const url = image.match(/.*?%22(.*)\/%22/)
          if (url && url.length == 2) {
            image = url[1]
          }
        }

        // create a new tooltip
        self.cache = toCard(self.sourceUrl, title, description, image)

        // if there is no tooltip, the reference to the tooltip container gets
        // deleted to prevent it from loading an empty div
        if (self.cache === '') {
          self.container = undefined
        }

        self.show() // show the tooltip

        // remove the iframe from the DOM, since it is not needed anymore
        iframe.remove()
      }

      // also remove the iframe, if there is an error
      iframe.onabort = function () {
        self.container = undefined
        iframe.remove()
      }

      try {
        // get the real HTML file
        doc = JSON.parse(doc).contents
      } catch (e) {}

      // load the iframe
      iframe.srcdoc = doc
    }
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
      this.container.style.display = 'block'
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
  image?: string
) {
  if (!url) return ''

  // if the starts with the internal proxy that is used, when CORS errors occur
  url = url.replace(PROXY, '')

  let card = ''

  if (image) {
    // TODO: relative images are ignored at the moment
    if (!image.startsWith('./')) {
      // the light background is required for transparent images in dark mode
      card += `<img src="${image}" style="background-color:white; margin-bottom: 1.5rem;">`
    }
  }
  if (title) card += `<h4>${title}</h4>`
  if (description) card += description

  if (card != '') {
    card += `<a style="font-size:x-small; display:block" href="${url}" target="_blank">${url}</a>`
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
      div.style.position = 'absolute'
      div.style.display = 'none'

      // this additional marker is used to not close the tooltip, if the user
      // moves the mouse onto the tooltip, this way, the original link triggers
      // a closing, but this is prevented by this second marker
      div.setAttribute('data-active', 'true')

      // these two listeners are required when the mouse hovers the tooltip
      // to stay visible or close it ...
      div.addEventListener('mouseenter', () => {
        div.style.display = 'block'
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

  // create the Iframe-container
  if (!document.getElementById(IFRAME_ID)) {
    setTimeout(function () {
      const div = document.createElement('div')

      div.id = IFRAME_ID
      // as small as possible
      div.style.width = '0px'
      div.style.height = '0px'
      div.style.display = 'inline'
      div.ariaHidden = 'true'

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
  let http = new XMLHttpRequest()
  http.open('GET', url, true) // async fetch

  http.onload = function (_e) {
    // everything went fine
    if (http.readyState === 4 && http.status === 200) {
      try {
        callback(http.responseText)
      } catch (e) {
        console.warn('fetching', e)
      }
    }
  }

  http.onerror = function (_e) {
    if (trial === 0) {
      // try to fetch the website with a proxy url
      fetch(PROXY + url, callback, 1)
    }
  }

  // start fetching
  http.send()
}

customElements.define('preview-link', PreviewLink)
