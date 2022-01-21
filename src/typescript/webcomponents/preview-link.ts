import { extract } from './embed/index'

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
        self.sourceUrl = `https://api.allorigins.win/get?url=${self.sourceUrl}`
        fetch(self, 1)
      }
    }
    http.send()
  }
}

function getTitle(doc: Document | null): string | undefined {
  if (doc === null) return

  const ogTitle = <HTMLMetaElement>(
    doc.querySelector('meta[property="og:title"]')
  )
  if (ogTitle && ogTitle.content.length > 0) {
    return ogTitle.content
  }

  const twitterTitle = <HTMLMetaElement>(
    doc.querySelector('meta[name="twitter:title"]')
  )
  if (twitterTitle && twitterTitle.content.length > 0) {
    return twitterTitle.content
  }

  const docTitle = doc.title
  if (docTitle && docTitle.length > 0) {
    return docTitle
  }

  const h1 = <HTMLHeadElement>doc.querySelector('h1')
  if (h1 && h1.innerHTML) {
    return h1.innerHTML
  }
  const h2 = <HTMLHeadElement>doc.querySelector('h2')
  if (h2 && h2.innerHTML) {
    return h2.innerHTML
  }
}

function getDescription(doc: Document | null): string | undefined {
  if (doc === null) return

  const ogDescription = <HTMLMetaElement>(
    doc.querySelector('meta[property="og:description"]')
  )
  if (ogDescription && ogDescription.content.length > 0) {
    return ogDescription.content
  }

  const twitterDescription = <HTMLMetaElement>(
    doc.querySelector('meta[name="twitter:description"]')
  )
  if (twitterDescription && twitterDescription.content.length > 0) {
    return twitterDescription.content
  }

  const metaDescription = <HTMLMetaElement>(
    doc.querySelector('meta[name="description"]')
  )
  if (metaDescription && metaDescription.content.length > 0) {
    return metaDescription.content
  }

  const paragraphs = doc.querySelectorAll('p')
  for (let i = 0; i < paragraphs.length; i++) {
    const par = paragraphs[i]
    if (
      // if object is visible in dom
      par.offsetParent !== null &&
      par.childElementCount !== 0 &&
      par.textContent
    ) {
      return par.textContent
    }
  }
}

function getDomainName(doc: Document | null, uri: string) {
  let domainName = null

  if (doc) {
    const canonicalLink = <HTMLLinkElement>(
      doc.querySelector('link[rel=canonical]')
    )
    if (canonicalLink && canonicalLink.href.length > 0) {
      domainName = canonicalLink.href
    } else {
      const ogUrlMeta = <HTMLMetaElement>(
        doc.querySelector('meta[property="og:url"]')
      )
      if (ogUrlMeta && ogUrlMeta.content.length > 0) {
        domainName = ogUrlMeta.content
      }
    }
  }

  return domainName != null
    ? new URL(domainName).hostname.replace('www.', '')
    : new URL(uri).hostname.replace('www.', '')
}

function getImage(doc: Document | null) {
  if (doc === null) return

  const ogImg = <HTMLMetaElement>doc.querySelector('meta[property="og:image"]')
  if (ogImg != null && ogImg.content.length > 0) {
    return ogImg.content
  }

  const imgRelLink = <HTMLLinkElement>doc.querySelector('link[rel="image_src"]')
  if (imgRelLink != null && imgRelLink.href.length > 0) {
    return imgRelLink.href
  }

  const twitterImg = <HTMLMetaElement>(
    doc.querySelector('meta[name="twitter:image"]')
  )
  if (twitterImg != null && twitterImg.content.length > 0) {
    return twitterImg.content
  }

  try {
    return Array.from(doc.getElementsByTagName('img'))[0].src
  } catch (e) {}
}

class PreviewLink extends HTMLElement {
  public sourceUrl: string | null = null
  private baseUrl: string | null = null

  public cache: string | null = null
  public isFetching = false

  public container?: HTMLElement
  private iframe: HTMLIFrameElement

  constructor() {
    super()
    this.iframe = document.createElement('iframe')
  }

  connectedCallback() {
    this.style.cursor = 'pointer'

    this.sourceUrl = this.getAttribute('src')
    this.baseUrl = this.sourceUrl

    this.container = document.getElementById(TOOLTIP) || undefined

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
      this.parentNode.container.style.left = `${e.clientX}px`
      this.parentNode.container.style.top = `${e.clientY + 10}px`

      this.parentNode.container.className = 'lds-dual-ring'
      this.parentNode.container.style.display = 'block'
      this.parentNode.container.innerHTML = ''
      console.warn(e)

      if (this.parentNode.cache) {
        this.parentNode.show()
      } else if (!this.parentNode.isFetching) {
        this.parentNode.isFetching = true
        try {
          let parent = this.parentNode
          extract(this.parentNode.sourceUrl, {})
            .then((data) => {
              parent.cache = toCard(
                parent.sourceUrl,
                data.title,
                data.description,
                data.thumbnail_url
              )
              parent.show()
            })
            .catch((e) => {
              fetch(parent)
            })
        } catch (e) {}
      }
    }

    // console.warn(e)
  }

  mouseout(e: any) {
    if (this.parentNode.container) {
      this.parentNode.container.style.display = 'none'
      console.warn('out')
    }
  }

  parse(index: string) {
    console.warn(index)

    if (this.cache !== null) {
      this.show()
    } else if (this.iframe) {
      let self = this
      let iframe = this.iframe

      iframe.style.width = '0px'
      iframe.style.height = '0px'
      iframe.style.border = '0'
      iframe.style.display = 'inline'
      this.appendChild(iframe)

      this.iframe.onload = function () {
        let title = getTitle(iframe.contentDocument)
        let description = getDescription(iframe.contentDocument)
        let domain = self.baseUrl
          ? getDomainName(iframe.contentDocument, self.baseUrl)
          : undefined
        let image = getImage(iframe.contentDocument)

        iframe.style.display = 'none'

        console.warn('-----------------------------------------------', image)

        if (typeof image == 'string') {
          const url = image.match(/.*?%22(.*)\/%22/)

          if (url && url.length == 2) {
            image = url[1]
          }
        }

        self.cache = toCard(domain || self.sourceUrl, title, description, image)

        if (self.cache === '') {
          self.container = undefined
        }

        self.show()
        //iframe.srcdoc = ''
      }

      try {
        index = JSON.parse(index).contents
      } catch (e) {}

      iframe.srcdoc = index
    }
  }

  show() {
    if (this.container && this.cache) {
      this.container.className = ''
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
  let card = ''

  if (image) card += `<img src="${image}">`
  if (title) card += `<h4>${title}</h4>`
  if (description) card += description

  if (card != '') {
    card += url
  }

  return card
}

const TOOLTIP = 'lia-tooltip'

export function initTooltip() {
  if (!document.getElementById(TOOLTIP)) {
    setTimeout(function () {
      const div = document.createElement('div')

      div.id = TOOLTIP

      div.style.zIndex = '20000'
      div.style.width = '425px'
      div.style.minHeight = '200px'
      div.style.height = 'auto'
      div.style.padding = '15px'
      div.style.background = 'white'
      div.style.boxShadow = '0 30px 90px -20px rgba(0, 0, 0, 0.3)'
      div.style.position = 'absolute'
      div.style.display = 'none'

      div.addEventListener('mouseenter', () => {
        //div.style.display = 'block'
      })
      div.addEventListener('mouseout', () => {
        console.warn('QQQQQQQQQQQQQQQQQQQQQQQQQQQQ')

        //div.style.display = 'none'
      })

      document.body.appendChild(div)
    }, 0)
  }
}

customElements.define('preview-link', PreviewLink)
