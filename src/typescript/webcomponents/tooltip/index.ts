import { extract } from '../embed/index'
import { getTitle, getDescription, getImage } from './iframe'

const TOOLTIP_ID = 'lia-tooltip'
const IFRAME_ID = 'lia-iframe-container'

const PROXY = 'https://api.allorigins.win/get?url='

var backup = Object()

class PreviewLink extends HTMLElement {
  public sourceUrl: string | null = null

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
    this.sourceUrl = this.getAttribute('src')

    this.container = document.getElementById(TOOLTIP_ID) || undefined

    if (this.container && this.firstChild) {
      this.firstChild.addEventListener('mouseenter', this.mouseenter)
      this.firstChild.addEventListener('mouseout', this.mouseout)
    }
  }

  disconnectedCallback() {
    if (this.firstChild) {
      this.firstChild.removeEventListener('mouseenter', this.mouseenter)
      this.firstChild.removeEventListener('mouseout', this.mouseout)
    }
  }

  mouseenter(e: any) {
    if (this.parentNode && this.parentNode.container) {
      this.parentNode.isActive = true

      this.parentNode.container.style.left = `${e.clientX}px`
      this.parentNode.container.style.top = `${e.clientY + 10}px`

      if (this.parentNode.cache) {
        this.parentNode.show()
      } else if (backup[this.parentNode.sourceUrl]) {
        this.parentNode.cache = backup[this.parentNode.sourceUrl]
        this.parentNode.show()
      } else if (!this.parentNode.isFetching) {
        this.style.cursor = 'progress'
        this.parentNode.isFetching = true
        try {
          let parent = this.parentNode
          extract(this.parentNode.sourceUrl, {})
            .then((data) => {
              parent.cache = toCard(
                parent.sourceUrl,
                data.title,
                undefined,
                data.thumbnail_url
              )

              parent.show()
            })
            .catch((_) => {
              fetch(parent)
            })
        } catch (e) {}
      }
    }
  }

  mouseout(e: any) {
    this.parentNode.isActive = false
    if (this.parentNode.container) {
      this.parentNode.container.style.display = 'none'
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
      if (this.firstChild) {
        this.firstChild.style.cursor = 'pointer'
      }
      this.container.style.display = 'block'
      this.container.innerHTML = this.cache
    }
  }
}

function toCard(
  url: string,
  title?: string,
  description?: string,
  image?: string
) {
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
      //div.style.minHeight = '200px'
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
