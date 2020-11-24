interface Response {
  height?: number;
  width?: number;
  html: any;
}


customElements.define(
  'oembed-element',
  class extends HTMLElement {
    connectedCallback() {
      let shadow = this.attachShadow({
        mode: 'closed'
      })
      const urlAttr = this.getAttribute('url')
      if (urlAttr) {
        renderOembed(shadow, urlAttr, {
          maxwidth: this.getAttribute('maxwidth'),
          maxheight: this.getAttribute('maxheight')
        })
      } else {
        const discoverUrl = this.getAttribute('discover-url')
        if (discoverUrl) {
          getDiscoverUrl(discoverUrl, function(discoveredUrl: string | null) {
            if (discoveredUrl) {
              renderOembed(shadow, discoveredUrl, null)
            }
          })
        }
      }
    }
  }
)

function renderOembed(
  shadow: ShadowRoot,
  urlToEmbed: string,
  options: { maxwidth?: string | null; maxheight?: string | null } | null) {
  let apiUrlBuilder = new URL(
    `https://cors-anywhere.herokuapp.com/${urlToEmbed}`
  )
  if (options && options.maxwidth) {
    apiUrlBuilder.searchParams.set('maxwidth', options.maxwidth)
  }
  if (options && options.maxheight) {
    apiUrlBuilder.searchParams.set('maxheight', options.maxheight)
  }
  const apiUrl = apiUrlBuilder.toString()
  httpGetAsync(apiUrl, (rawResponse: string) => {
    const response = JSON.parse(rawResponse)

    switch (response.type) {
      case 'rich':
        tryRenderingHtml(shadow, response)
        break
      case 'video':
        tryRenderingHtml(shadow, response)
        break
      case 'photo':
        let img = document.createElement('img')
        img.setAttribute('src', response.url)
        if (options) {
          img.setAttribute(
            'style',
            `max-width: ${options.maxwidth}px; max-height: ${options.maxheight}px;`
          )
        }
        shadow.appendChild(img)
        break
      default:
        break
    }
  })
}

function tryRenderingHtml(
  shadow: ShadowRoot,
  response: Response
) {
  if (response && typeof response.html) {
    let iframe = createIframe(response)
    shadow.appendChild(iframe)
    setTimeout(() => {
      let refetchedIframe = shadow.querySelector('iframe')
      if (refetchedIframe && !response.height) {
        refetchedIframe.setAttribute(
          'height',
          // @ts-ignore
          (iframe.contentWindow.document.body.scrollHeight + 10).toString()
        )
      }
      if (refetchedIframe && !response.width) {
        refetchedIframe.setAttribute(
          'width',
          // @ts-ignore
          (iframe.contentWindow.document.body.scrollWidth + 10).toString()
        )
      }
    }, 1000)
  }
}

function createIframe(response: Response): HTMLIFrameElement {
  let iframe = document.createElement('iframe')
  iframe.style.border = '0px'
  //iframe.frameBorder = '0'
  iframe.height = ((response.height || 500) + 20).toString()
  iframe.width = ((response.width || 500) + 20).toString()
  iframe.style.maxWidth = '100%'
  iframe.srcdoc = response.html
  return iframe
}

function getDiscoverUrl(url: string, callback: (discoveredUrl: string | null) => void) {
  let apiUrl = new URL(`https://cors-anywhere.herokuapp.com/${url}`).toString()
  httpGetAsync(apiUrl, function(response: string) {
    let dom = document.createElement('html')
    dom.innerHTML = response
    const oembedTag: HTMLLinkElement | null = dom.querySelector(
      'link[type="application/json+oembed"]'
    )
    callback(oembedTag ? oembedTag.href : null)
  })
}


function httpGetAsync(theUrl: string, callback: (rawResponse: string) => void) {
  let xmlHttp = new XMLHttpRequest()
  xmlHttp.onreadystatechange = function() {
    if (xmlHttp.readyState === 4 && xmlHttp.status === 200) {
      callback(xmlHttp.responseText)
    }
  }
  xmlHttp.open('GET', theUrl, true) // true for asynchronous
  xmlHttp.setRequestHeader('X-Requested-With', 'XMLHttpRequest')
  xmlHttp.send(null)
}
