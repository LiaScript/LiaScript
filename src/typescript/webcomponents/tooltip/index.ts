// @ts-ignore
import { extract } from '../embed/index'
import { getTitle, getDescription, getImage } from './iframe'
import { fetch as fetch_LiaScript } from '../preview-lia'
import { PROXY } from '../../helper'

const TOOLTIP_ID = 'lia-tooltip'
const IFRAME_ID = 'lia-iframe-container'
const LIASCRIPT_PATTERN =
  /(?:https?:)(?:\/\/)liascript\.github\.io\/course\/\?(.*\.md)/i

var backup = Object()

class PreviewLink extends HTMLElement {
  public sourceUrl?: string

  public cache: string | null = null
  public isFetching = false
  public isActive = false

  public container?: HTMLElement
  private iframe: HTMLIFrameElement

  constructor() {
    super()
    this.iframe = document.createElement('iframe')
    this.iframe.sandbox.add('allow-same-origin')
  }

  connectedCallback() {
    this.sourceUrl = this.getAttribute('src') || undefined

    this.container = document.getElementById(TOOLTIP_ID) || undefined

    if (this.container && this.firstChild) {
      this.firstChild.addEventListener('mouseenter', this._mouseenter)
      this.firstChild.addEventListener('mouseout', this._out)

      this.firstChild.addEventListener('focus', this._onfocus)
      this.firstChild.addEventListener('blur', this._out)
      this.firstChild.addEventListener('keyup', this._escape)
    }
  }

  disconnectedCallback() {
    if (this.firstChild) {
      this.firstChild.removeEventListener('mouseenter', this._mouseenter)
      this.firstChild.removeEventListener('mouseout', this._out)

      this.firstChild.removeEventListener('focus', this._onfocus)
      this.firstChild.removeEventListener('blur', this._out)
      this.firstChild.removeEventListener('keyup', this._escape)
    }
  }

  _escape(e: any) {
    if (e.keyCode === 27) {
      ;(this.parentElement as PreviewLink).deactivate()
    }
  }

  _mouseenter(e: any) {
    this.style.cursor = 'progress'

    const parent = this.parentElement as PreviewLink
    parent.activate(e.clientX, e.clientY)
  }

  _onfocus(e: any) {
    const boundingBox = this.getBoundingClientRect()
    ;(this.parentElement as PreviewLink).activate(
      boundingBox.left + boundingBox.width / 2,
      boundingBox.top + boundingBox.height / 2
    )
  }

  _out() {
    ;(this.parentElement as PreviewLink).deactivate()
  }

  activate(positionX: number, positionY: number) {
    if (this.container) {
      this.isActive = true

      this.container.style.left = `${
        positionX - (425 * positionX) / window.innerWidth
      }px`

      if (positionY * 1.5 > window.innerHeight) {
        this.container.style.top = ''
        this.container.style.bottom = `${window.innerHeight - positionY + 10}px`
      } else {
        this.container.style.top = `${positionY + 20}px`
        this.container.style.bottom = ''
      }

      if (this.cache) {
        this.show()
      } else if (this.sourceUrl) {
        if (backup[this.sourceUrl]) {
          this.cache = backup[this.sourceUrl]
          this.show()
        } else if (!this.isFetching) {
          this.isFetching = true

          let self = this
          let liascript_url = this.sourceUrl.match(LIASCRIPT_PATTERN)
          if (liascript_url) {
            fetch_LiaScript(
              liascript_url[1],
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
                  fetch(this)
                })
            } catch (e) {}
          }
        }
      }
    }
  }

  deactivate() {
    this.isActive = false

    if (this.container) {
      this.container.style.display = 'none'
    }
  }

  parse(index: string) {
    if (this.cache !== null) {
      this.show()
    } else if (this.iframe) {
      const iframeContainer = document.getElementById(IFRAME_ID)

      if (iframeContainer) {
        let self = this
        let iframe = this.iframe

        iframe.style.width = '0px'
        iframe.style.height = '0px'
        iframe.style.border = '0'
        iframe.style.display = 'inline'
        iframe.ariaHidden = 'true'

        iframeContainer.appendChild(iframe)

        this.iframe.onload = function () {
          let title = getTitle(iframe.contentDocument)
          let description = getDescription(iframe.contentDocument)
          let image = getImage(iframe.contentDocument)

          iframe.style.display = 'none'

          if (typeof image == 'string') {
            const url = image.match(/.*?%22(.*)\/%22/)

            if (url && url.length == 2) {
              image = url[1]
            }
          }

          self.cache = toCard(self.sourceUrl, title, description, image)

          if (self.cache === '') {
            self.container = undefined
          }

          self.show()

          iframe.remove()
        }

        try {
          index = JSON.parse(index).contents
        } catch (e) {}

        iframe.srcdoc = index
      }
    }
  }

  show() {
    if (this.container && this.cache && this.isActive) {
      this.container.style.display = 'block'
      this.container.innerHTML = this.cache
    }

    if (this.firstChild) (this.firstChild as HTMLElement).style.cursor = ''
  }
}

function toCard(
  url?: string,
  title?: string,
  description?: string,
  image?: string
) {
  if (!url) return ''

  url = url.replace(PROXY, '')

  let card = ''

  if (image) {
    if (!image.startsWith('./')) {
      card += `<img src="${image}">`
    }
  }
  if (title) card += `<h4>${title}</h4>`
  if (description) card += description

  if (card != '') {
    card += `<div style="font-size:x-small">${url}</div>`
  }

  backup[url] = card

  return card
}

export function initTooltip() {
  if (!document.getElementById(TOOLTIP_ID)) {
    setTimeout(function () {
      const div = document.createElement('div')

      div.id = TOOLTIP_ID

      div.style.zIndex = '20000'
      div.style.width = '425px'
      div.style.height = 'auto'
      div.style.padding = '15px'
      div.style.background = 'white'
      div.style.boxShadow = '0 30px 90px -20px rgba(0, 0, 0, 0.3)'
      div.style.position = 'absolute'
      div.style.display = 'none'

      /*
      div.addEventListener('mouseenter', () => {
        div.style.display = 'block'
      })
      div.addEventListener('mouseout', () => {
        div.style.display = 'none'
      })
      */

      document.body.appendChild(div)
    }, 0)
  }

  if (!document.getElementById(IFRAME_ID)) {
    setTimeout(function () {
      const div = document.createElement('div')

      div.id = IFRAME_ID
      div.style.width = '0px'
      div.style.height = '0px'
      div.style.display = 'inline'
      div.ariaHidden = 'true'

      document.body.appendChild(div)
    }, 0)
  }
}

function fetch(self: PreviewLink, trial = 0) {
  if (self.sourceUrl) {
    let http = new XMLHttpRequest()
    http.open('GET', self.sourceUrl, true)
    //http.setRequestHeader('User-Agent', 'bla')

    http.onload = function (_e) {
      if (http.readyState === 4 && http.status === 200) {
        try {
          self.parse(http.responseText)
        } catch (e) {
          console.warn('fetching', e)
        }
      }
    }

    http.onerror = function (_e) {
      if (self.sourceUrl && trial === 0) {
        self.sourceUrl = PROXY + self.sourceUrl
        fetch(self, 1)
      }
    }
    http.send()
  }
}

customElements.define('preview-link', PreviewLink)
