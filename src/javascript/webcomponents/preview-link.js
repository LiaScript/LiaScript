function fetch(self, trial = 0) {
  let http = new XMLHttpRequest()

  http.open('GET', self._src, true)
  http.setRequestHeader('User-Agent', 'bla')

  http.onload = function(e) {
    if (http.readyState === 4 && http.status === 200) {
      try {
        self.parse(http.responseText)
      } catch (e) {
        console.warn('fetching', e)
      }
    }
    http = null
  }

  http.onerror = function(e) {
    if (trial === 0) {
      self._src = `https://cors-anywhere.herokuapp.com/${self._src}`
      fetch(self, 1)
    }
  }
  http.send()
}

function getTitle(doc) {
  const ogTitle = doc.querySelector('meta[property="og:title"]')

  if (ogTitle != null && ogTitle.content.length > 0) {
    return ogTitle.content
  }
  const twitterTitle = doc.querySelector('meta[name="twitter:title"]')
  if (twitterTitle != null && twitterTitle.content.length > 0) {
    return twitterTitle.content
  }
  const docTitle = doc.title
  if (docTitle != null && docTitle.length > 0) {
    return docTitle
  }
  const h1 = doc.querySelector('h1').innerHTML
  if (h1 != null && h1.length > 0) {
    return h1
  }
  const h2 = doc.querySelector('h2').innerHTML
  if (h2 != null && h2.length > 0) {
    return h2
  }
  return null
}

function getDescription(doc) {
  const ogDescription = doc.querySelector('meta[property="og:description"]')
  if (ogDescription != null && ogDescription.content.length > 0) {
    return ogDescription.content
  }
  const twitterDescription = doc.querySelector('meta[name="twitter:description"]')
  if (twitterDescription != null && twitterDescription.content.length > 0) {
    return twitterDescription.content
  }
  const metaDescription = doc.querySelector('meta[name="description"]')
  if (metaDescription != null && metaDescription.content.length > 0) {
    return metaDescription.content
  }
  const paragraphs = doc.querySelectorAll('p')
  let fstVisibleParagraph = null
  for (let i = 0; i < paragraphs.length; i++) {
    if (
      // if object is visible in dom
      paragraphs[i].offsetParent !== null &&
      !paragraphs[i].childElementCount !== 0
    ) {
      fstVisibleParagraph = paragraphs[i].textContent
      break
    }
  }
  return fstVisibleParagraph
}

function getDomainName(doc, uri) {
  let domainName = null
  const canonicalLink = document.querySelector('link[rel=canonical]')
  if (canonicalLink != null && canonicalLink.href.length > 0) {
    domainName = canonicalLink.href
  } else {
    const ogUrlMeta = document.querySelector('meta[property="og:url"]')
    if (ogUrlMeta != null && ogUrlMeta.content.length > 0) {
      domainName = ogUrlMeta.content
    }
  }

  return domainName != null ?
    new URL(domainName).hostname.replace('www.', '') :
    new URL(uri).hostname.replace('www.', '')
}

function getImage(doc, uri) {
  const ogImg = doc.querySelector('meta[property="og:image"]')
  if (ogImg != null && ogImg.content.length > 0) {
    return ogImg.content
  }
  const imgRelLink = doc.querySelector('link[rel="image_src"]')
  if (imgRelLink != null && imgRelLink.href.length > 0) {
    return imgRelLink.href
  }
  const twitterImg = doc.querySelector('meta[name="twitter:image"]')
  if (twitterImg != null && twitterImg.content.length > 0) {
    return twitterImg.content
  }

  try {
    return Array.from(doc.getElementsByTagName('img'))[0].src
  } catch (e) {}

  return null
}

customElements.define('preview-link', class extends HTMLElement {
  constructor() {
    super()

    const template = document.createElement('template')

    template.innerHTML = `
    <style></style>
    <a href="" id="container_" style="display: inline-block;">preview-link</a>
    <iframe id="iframe" style="display: none;"></iframe>
    `

    this._shadowRoot = this.attachShadow({
      mode: 'closed'
    })
    this._shadowRoot.appendChild(template.content.cloneNode(true))
  }

  connectedCallback() {
    this._src = this.getAttribute('src')
    this._base = this._src

    this._shadowRoot.getElementById('container_').href = this._src

    let self = this
    fetch(self)
  }

  disconnectedCallback() {
    if (super.disconnectedCallback) {
      super.disconnectedCallback()
    }
  }

  parse(index) {
    try {
      let iframe = this._shadowRoot.getElementById('iframe')

      let self = this
      iframe.onload = function() {
        self._title = getTitle(iframe.contentDocument)
        self._description = getDescription(iframe.contentDocument)
        self._domain = getDomainName(iframe.content, self._base)
        self._image = getImage(iframe.contentDocument)

        self.show()
      }
      iframe.srcdoc = index
    } catch (e) {}
  }

  show() {
    const div = this._shadowRoot.getElementById('container_')

    div.innerHTML = `<div style="float: left">
                        <h4>${this._title}</h4>
                        <p style="max-width: 400px">${this._description}</p>
                      </div>
                      <img src="${this._image}" style="height:100%; float: right;">`
  }
})
