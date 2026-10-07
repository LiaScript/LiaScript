import { endpoints } from './endpoints'
import { Params, Endpoint } from './types.d'
import * as helper from '../../helper'

/**
 * All requested embeds are cached here as promises, keyed by URL and params,
 * so that identical embeds on a page share a single request.
 */
const cache = new Map<string, Promise<any>>()

/**
 * Endpoint schemas compiled to regular expressions, built on first use.
 * Only `*` is a wildcard, everything else (`.`, `?`, ...) is matched literally.
 */
let providers: [string, RegExp][] | undefined

/**
 * Handle providers according to the spec:
 *
 * <https://oembed.com/>
 *
 * The only difference is, that it will previously lookup the internal provider
 * list and if there is no proper result, it will grab the website, if possible,
 * and extract the provider URL from the link-tag within the header.
 */
async function findProvider(url: string): Promise<string | undefined> {
  if (!providers) {
    providers = []
    for (const [endpoint, schemas] of endpoints as Endpoint[]) {
      for (const schema of schemas || []) {
        const pattern = schema
          .replace(/[.+?^${}()|[\]\\]/g, '\\$&')
          .replace(/\*/g, '.*')
        providers.push([endpoint, new RegExp(pattern, 'i')])
      }
    }
  }

  const link = url.replace(/^https?:\/\//, '')
  const candidate = providers.find(([, regex]) => regex.test(link))

  return candidate
    ? 'https://' + candidate[0]
    : fetchProviderFromWebsite(url)
}

/**
 * The proxy takes anything between 3s and a minute (or fails with a 520), the
 * iframe fallback is mostly the same result, so do not wait for it too long.
 */
const PROXY_TIMEOUT = 5000

/**
 * Fetch a text resource, if it fails due to CORS, retry via the proxy, which
 * wraps the response into `{ contents: string }`.
 */
export async function fetchText(
  url: string,
  useProxy = true,
  timeout = PROXY_TIMEOUT
): Promise<string> {
  try {
    const res = await fetch(url)
    if (res.ok) return await res.text()
  } catch (_) {}

  if (!useProxy) throw new Error(`oembed: could not fetch "${url}"`)

  const res = await Promise.race([
    fetch(helper.PROXY + encodeURIComponent(url)),
    new Promise<never>((_, reject) =>
      setTimeout(() => reject(new Error('oembed: proxy timeout')), timeout)
    ),
  ])
  return (await res.json()).contents
}

async function fetchProviderFromWebsite(
  url: string
): Promise<string | undefined> {
  try {
    // ponytail: no proxy here, pages without CORS (most) fall back to the
    // iframe at once instead of 10-60s later, sites that offer oEmbed only
    // via <link> and block CORS need an entry in endpoints.ts
    const html = await fetchText(url, false)
    const href = new DOMParser()
      .parseFromString(html, 'text/html')
      .querySelector(
        'link[type="application/json+oembed"], link[type="text/json+oembed"]'
      )
      ?.getAttribute('href')

    return href ? new URL(href, url).href : undefined
  } catch (_) {}
}

async function fetchEmbed(link: string, resourceUrl: string, params: Params) {
  // discovered providers already come with a query (url, format, ...)
  const url = new URL(resourceUrl.replace(/\{format\}/g, 'json'))

  url.searchParams.set('format', 'json')
  url.searchParams.set('url', link)
  if (params.maxwidth) url.searchParams.set('maxwidth', '' + params.maxwidth)
  if (params.maxheight) url.searchParams.set('maxheight', '' + params.maxheight)

  return JSON.parse(await fetchText(url.href))
}

export function extract(link: string, params: Params): Promise<any> {
  // this makes urls more equal
  if (link.endsWith('/')) {
    link = link.slice(0, -1)
  }

  const key = link + JSON.stringify(params)

  // ponytail: failures stay cached too, so revisiting a slide shows the iframe
  // fallback at once, a reload retries
  if (!cache.has(key)) {
    cache.set(
      key,
      findProvider(link).then((provider) => {
        if (!provider) {
          throw new Error(`No provider found with given url "${link}"`)
        }
        return fetchEmbed(link, provider, params)
      })
    )
  }

  return cache.get(key)!
}

customElements.define(
  'lia-embed',
  class extends HTMLElement {
    private url_: string | null = null
    private div_: HTMLDivElement
    private maxwidth_: number | undefined
    private maxheight_: number | undefined
    private thumbnail_: boolean = false
    private connected_: boolean = false
    private dataAttributes: { [key: string]: string } = {}

    constructor() {
      super()

      this.div_ = document.createElement('div')
      this.div_.style.width = 'inherit'
      this.div_.style.height = 'inherit'
      this.div_.style.display = 'inline-block'

      this.attachShadow({ mode: 'closed' }).appendChild(this.div_)
    }

    connectedCallback() {
      if (this.connected_) return
      this.connected_ = true

      const container = this.parentElement
      const scale = parseFloat(this.getAttribute('scale') || '0.674')

      try {
        const attributes = this.getAttribute('data-attributes')

        if (attributes) {
          this.dataAttributes = JSON.parse(attributes)
        }
      } catch (e) {
        console.warn("oembed: Couldn't parse data-attributes")
      }

      if (container) {
        const paddingLeft = parseFloat(
          window.getComputedStyle(container).paddingLeft
        )

        if (this.maxwidth_ == null) {
          this.maxwidth_ = container.clientWidth - paddingLeft - 30
        }
        if (this.maxheight_ == null) {
          this.maxheight_ = Math.floor(this.maxwidth_ * (scale || 0.674))
        }

        if (this.maxheight_ > screen.availHeight) {
          this.maxheight_ = Math.floor(screen.availHeight * (scale || 0.76))
        }
      }

      this.render()
    }

    render() {
      if (!this.connected_ || !this.url_) return

      const url = this.url_
      const thumbnail = this.thumbnail_
      const div = this.div_
      const options = {
        maxwidth: this.maxwidth_,
        maxheight: this.maxheight_,
      }

      extract(url, options)
        .then((json: any) => {
          // the url has changed while loading
          if (url !== this.url_) return

          if (thumbnail && json.thumbnail_url) {
            this.show(
              this.element('img', {
                src: json.thumbnail_url,
                style: 'width: inherit; height: inherit; object-fit: cover',
              })
            )
            return
          }

          if (json.html) {
            div.innerHTML = json.html
          } else if (json.type === 'photo' && json.url) {
            this.show(
              this.element('img', { src: json.url, style: 'width: 100%' })
            )
          } else {
            this.iframe(url, 'inherit')
            return
          }

          const frame = div.querySelector('iframe')
          if (frame) {
            // the provider sized the iframe for the width measured on connect,
            // stretching it to 100% has to keep the ratio, otherwise it gets thin
            frame.style.width = '100%'
            const ratio = parseFloat(json.width) / parseFloat(json.height)
            if (ratio > 0 && isFinite(ratio)) {
              frame.style.height = 'auto'
              // min(100%, 90vh) is dropped entirely, if the host height is auto
              frame.style.maxHeight = this.style.height.endsWith('px')
                ? '100%'
                : '90vh'
              frame.style.setProperty('aspect-ratio', '' + ratio)
            }
          } else if (div.firstElementChild instanceof HTMLElement) {
            div.firstElementChild.style.width = '100%'
          }

          this.applyAttributes()
        })
        .catch(() => {
          if (url === this.url_) {
            this.iframe(
              url,
              options.maxheight ? options.maxheight + 'px' : 'inherit'
            )
          }
        })
    }

    private element(tag: string, attributes: { [key: string]: string }) {
      const elem = document.createElement(tag)
      for (const [key, value] of Object.entries(attributes)) {
        elem.setAttribute(key, value)
      }
      return elem
    }

    private show(elem: HTMLElement) {
      this.div_.innerHTML = ''
      this.div_.appendChild(elem)
    }

    private iframe(src: string, height: string) {
      this.show(
        this.element('iframe', {
          src,
          style: `width: 100%; height: ${height}`,
          allowfullscreen: '',
          loading: 'lazy',
        })
      )
      this.applyAttributes()
    }

    private applyAttributes() {
      const target =
        this.div_.querySelector('iframe') || this.div_.firstElementChild

      if (!(target instanceof HTMLElement)) return

      for (const [key, value] of Object.entries(this.dataAttributes)) {
        if (key === 'style') {
          target.style.cssText += value
        } else {
          target.setAttribute(key, value)
        }
      }
    }

    get url() {
      return this.url_
    }

    set url(value) {
      if (this.url_ !== value) {
        this.url_ = value
        this.render()
      }
    }

    get maxheight() {
      return this.maxheight_
    }

    set maxheight(value) {
      if (value) this.maxheight_ = value
    }

    get maxwidth() {
      return this.maxwidth_
    }

    set maxwidth(value) {
      if (value) this.maxwidth_ = value
    }

    get thumbnail() {
      return this.thumbnail_
    }

    set thumbnail(value: boolean) {
      this.thumbnail_ = value
    }
  }
)
