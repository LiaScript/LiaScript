import { endpoints } from './endpoints'
import { Params, Endpoint } from './types.d'
import { PROXY } from '../../helper'

/**
 * All retrieved embeds are stored within this global variable. The key is
 * defined by the URL, whereby the body is a string that should replace the
 * innerHTML.
 */
var backup = Object()

function findProvider(link: string): string | undefined {
  link = link.replace('https://', '')
  link = link.replace('http://', '')

  const candidate = endpoints.find((endpoint: Endpoint) => {
    const [url, schema] = endpoint

    if (!schema || !schema.length) {
      return url.includes(link)
    }

    return schema.some((schema) => {
      return link.match(new RegExp(schema.replace(/\*/g, '(?:.*)'), 'i'))
    })
  })

  if (candidate) {
    return 'https://' + candidate[0]
  }
}

async function fetchEmbed(
  link: string,
  resourceUrl: string,
  params: Params,
  prefix?: string
) {
  resourceUrl = resourceUrl.replace(/\{format\}/g, 'json')

  let url = `${resourceUrl}?format=json&url=${encodeURIComponent(link)}`

  url = params.maxwidth ? `${url}&maxwidth=${params.maxwidth}` : url
  url = params.maxheight ? `${url}&maxheight=${params.maxheight}` : url

  let res, json

  if (prefix) {
    url = prefix + encodeURIComponent(url)

    res = await fetch(url)
    json = await res.text()
    json = JSON.parse(json)
    json = JSON.parse(json.contents)
  } else {
    res = await fetch(url)
    json = await res.json()
  }

  return json
}

export async function extract(link: string, params: Params) {
  // this makes urls more equal
  if (link.endsWith('/')) {
    link = link.slice(0, -1)
  }

  // check if it has been loaded so far
  if (backup[link] && backup[link][JSON.stringify(params)]) {
    return backup[link][JSON.stringify(params)]
  }

  const p = findProvider(link)

  if (!p) {
    throw new Error(`No provider found with given url "${link}"`)
  }

  let data

  try {
    data = await fetchEmbed(link, p, params)
  } catch (error) {
    data = await fetchEmbed(link, p, params, PROXY)
  }

  const key = JSON.stringify(params)

  if (!backup[link]) {
    let x = {}
    x[key] = data
    backup[link] = x
  } else {
    backup[link][key] = data
  }

  return data
}

function iframe(url: string) {
  return `<iframe src="${url}" style="width: 100%; height: inherit" allowfullscreen loading="lazy"></iframe>`
}

customElements.define(
  'lia-embed',
  class extends HTMLElement {
    private url_: string | null
    private div_: HTMLDivElement
    private maxwidth_: number | undefined
    private maxheight_: number | undefined
    private thumbnail_: boolean
    private paramCount: number

    constructor() {
      super()

      this.url_ = null

      this.div_ = document.createElement('div')
      this.div_.style.width = 'inherit'
      this.div_.style.height = 'inherit'
      this.div_.style.display = 'inline-block'

      this.thumbnail_ = false

      this.paramCount = 0
    }

    connectedCallback() {
      let shadowRoot = this.attachShadow({
        mode: 'closed',
      })

      shadowRoot.appendChild(this.div_)

      const container = this.parentElement // document.getElementsByClassName("lia-slide__content")[0]

      let scale = parseFloat(this.getAttribute('scale') || '0.674')

      if (container) {
        const paddingLeft = parseInt(
          window
            .getComputedStyle(container)
            .getPropertyValue('padding-left')
            .replace('px', '')
        )

        this.maxwidth_ =
          this.maxwidth_ != null
            ? this.maxwidth_
            : container.clientWidth - paddingLeft - 30
        this.maxheight_ =
          this.maxheight_ != null
            ? this.maxheight_
            : Math.floor(this.maxwidth_ * (scale || 0.674))

        if (this.maxheight_ > screen.availHeight) {
          this.maxheight_ = Math.floor(screen.availHeight * (scale || 0.76))
        }
      }

      this.render()
    }

    render() {
      if (this.paramCount > 2) {
        let div = this.div_
        let options = {
          maxwidth: this.maxwidth_,
          maxheight: this.maxheight_,
        }

        if (this.url_) {
          let url_ = this.url_
          let thumbnail_ = this.thumbnail_

          extract(url_, options)
            .then((json: any) => {
              try {
                if (thumbnail_ && json.thumbnail_url) {
                  div.innerHTML = `<img style="width: inherit; height: inherit; object-fit: cover" src="${json.thumbnail_url}"></img>`
                } else {
                  div.innerHTML = json.html
                }
              } catch (e) {
                div.innerHTML = iframe(url_)
              }
            })
            .catch((err: any) => {
              div.innerHTML = `<iframe src="${url_}" style="width: ${
                options.maxwidth ? options.maxwidth + 'px' : '100%'
              }; height: ${
                options.maxheight ? options.maxheight + 'px' : 'inherit'
              };" allowfullscreen loading="lazy"></iframe>`
            })
        }
      }
    }

    get url() {
      return this.url_
    }

    set url(value) {
      if (this.url_ !== value) {
        this.url_ = value
        this.paramCount++
        this.render()
      }
    }

    get maxheight() {
      return this.maxheight_
    }

    set maxheight(value) {
      if (this.maxheight_ !== value) {
        this.paramCount++
        if (value != 0) {
          this.maxheight_ = value
        }
      }
    }

    get maxwidth() {
      return this.maxwidth_
    }

    set maxwidth(value) {
      if (this.maxwidth_ !== value) {
        this.paramCount++
        if (value != 0) {
          this.maxwidth_ = value
        }
      }
    }

    get thumbnail() {
      return this.thumbnail_
    }

    set thumbnail(value: boolean) {
      this.thumbnail_ = value
    }
  }
)
