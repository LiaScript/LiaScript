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
    const parent = this.parentElement as PreviewLink

    if (parent && parent.container) {
      parent.isActive = true

      parent.container.style.left = `${
        e.clientX - (425 * e.clientX) / window.innerWidth
      }px`

      if (e.clientY * 1.5 > window.innerHeight) {
        parent.container.style.top = ''
        parent.container.style.bottom = `${
          window.innerHeight - e.clientY + 10
        }px`
      } else {
        parent.container.style.top = `${e.clientY + 20}px`
        parent.container.style.bottom = ''
      }

      if (parent.cache) {
        parent.show()
      } else if (parent.sourceUrl) {
        if (backup[parent.sourceUrl]) {
          parent.cache = backup[parent.sourceUrl]
          parent.show()
        } else if (!parent.isFetching) {
          this.style.cursor = 'progress'
          parent.isFetching = true

          let liascript_url = parent.sourceUrl.match(LIASCRIPT_PATTERN)
          if (liascript_url) {
            fetch_LiaScript(
              liascript_url[1],
              function (
                url?: string,
                title?: string,
                description?: string,
                image?: string
              ) {
                parent.cache = toCard(
                  parent.sourceUrl,
                  title,
                  description,
                  image
                )

                parent.show()
              }
            )
          } else {
            try {
              extract(parent.sourceUrl, {})
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
    }
  }

  mouseout(e: any) {
    const parent = this.parentElement as PreviewLink

    parent.isActive = false

    if (parent.container) {
      parent.container.style.display = 'none'
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
