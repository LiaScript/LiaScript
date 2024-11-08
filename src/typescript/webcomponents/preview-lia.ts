// @ts-ignore
import { Elm } from '../../elm/Worker.elm'
import * as helper from '../helper'

export function fetch(
  url: string,
  callback: (
    url?: string,
    title?: string,
    description?: string,
    logo?: string,
    logo_alt?: string,
    icon?: string,
    author?: string,
    email?: string,
    tags?: string[],
    version?: string
  ) => void
) {
  let http = new XMLHttpRequest()

  http.open('GET', url, true)

  http.onload = function (_e) {
    if (http.readyState === 4 && http.status === 200) {
      try {
        const lia = Elm.Worker.init({
          flags: {
            cmd: '',
          },
        })

        lia.ports.output.subscribe(function (event: [boolean, any]) {
          let [ok, json] = event

          if (ok) {
            json = JSON.parse(json)

            let image
            if (json.definition.logo !== '') {
              image = addBase(url, json.definition.logo)
            }

            let alt
            try {
              alt = json.definition.macro.logo_alt
            } catch (e) {}

            let tags
            try {
              tags = json.definition.macro.tags
                .split(',')
                .map((e: string) => e.trim())
            } catch (e) {}

            let icon
            try {
              icon = addBase(url, json.definition.macro.icon)
            } catch (e) {
              icon = 'https://liascript.github.io/course/icon.ico'
            }

            callback(
              url,
              json.str_title,
              json.comment,
              image,
              alt,
              icon,
              json.definition.author,
              json.definition.email,
              tags,
              json.definition.version
            )
          }
        })

        lia.ports.input.send(['defines', http.responseText])
      } catch (e) {
        console.warn('fetching', e)
      }
    }
  }
  http.send()
}

export function addBase(base: string, url: string) {
  if (helper.allowedProtocol(url)) {
    return url
  }

  let path = base.split('/')
  path.pop()
  return path.join('/') + '/' + url
}

const TEMPLATE = `<style>
  .card {
    border: 5px solid #399193;
    position: relative;
    background-color: white;
    display: flex;
    flex-direction: row;
    margin: 2rem auto;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  }
  .card:hover {
    transform: translateY(-1px);
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
  }
  .card__media {
    flex: 1;
    max-width: 300px;
    min-height: 100%;
  }
  .card__image {
    height: 100%;
    width: 100%;
    object-fit: cover;
    object-position: center;
  }
  .card__content {
    flex: 2;
    padding: 2rem;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }
  .card__header {
    margin-bottom: 1.5rem;
  }
  .card__title {
    color: #4b4b4b;
    margin: 0;
    position: relative;
  }
  .card__title:before {
    content: "";
    position: absolute;
    bottom: -0.5rem;
    width: 50%;
    height: 2px;
    background-color: #399193;
  }
  .card__subtitle {
    color: #aeaeae;
    margin: 0.5rem 0 1rem;
  }
  .card__version {
    display: inline-block;
    padding: 0.5rem;
    background-color: #399193;
    color: white;
    position: absolute;
    font-size: x-small;
    top: -1.5rem;
    left: 1rem;
    z-index: 1;
  }
  .card__body {
    line-height: 1.5;
  }
  .card__contact {
    color: #399193;
    text-decoration: none;
    font-size: small;
  }
</style>
<a id="container" href="">preview-lia</a>`

class PreviewLia extends HTMLElement {
  public container: ShadowRoot
  public source_url: string = ''

  constructor() {
    super()

    const template = document.createElement('template')

    template.innerHTML = TEMPLATE
    this.container = this.attachShadow({ mode: 'open' })
    this.container.appendChild(template.content.cloneNode(true))
  }

  connectedCallback() {
    const url = this.getAttribute('src')
    const a = this.container.getElementById(
      'container'
    ) as HTMLAnchorElement | null

    if (!url) return

    const urls = url.split('/course/?')

    if (urls.length === 2) {
      this.source_url = urls[1]
    } else {
      this.source_url = urls[0]
    }

    const link =
      this.getAttribute('link') ||
      'https://LiaScript.github.io/course/?' + this.source_url

    if (a !== null) {
      a.innerHTML = `<a href="${url}">preview-lia</a>`

      let self = this

      fetch(
        this.source_url,
        function (
          url?: string,
          title?: string,
          description?: string,
          logo?: string,
          logo_alt?: string,
          icon?: string,
          author?: string,
          email?: string,
          tags?: string[],
          version?: string
        ) {
          let tagLine = ''
          if (tags && tags.length > 0) {
            tagLine = `<h3 class="card__subtitle">${tags.join(' | ')}</h3>`
          }

          if (logo) {
            logo_alt = logo_alt ? `alt="${logo_alt}"` : ''
            logo = `<div class="card__media">
              <img src="${logo}" ${logo_alt} class="card__image">
            </div>`
          }

          if (author && email) {
            author = `<a class="card__contact" href="mailto:${email}">${author} ✉️</a>`
          } else if (author) {
            author = `<span class="card__contact">${author}</span>`
          } else if (email) {
            author = `<a class="card__contact" href="mailto:${email}">${email} ✉️</a>`
          } else {
            author = ''
          }

          a.href = link
          a.style.textDecoration = 'none'
          a.style.color = 'black'
          a.style.display = 'block'
          a.innerHTML = `<article class="card">
            <div class="card__version">V ${version}</div>
            ${logo || ''}
            <div class="card__content">
              <img src="${icon}" alt="" style="display: block; height: 3rem; position: absolute; right: 5px; top: 5px">
              <header class="card__header">
                <h2 class="card__title">${title}</h2>
                ${tagLine}
              </header>
              <div class="card__body">
                <p class="card__copy">${description}</p>
              </div>
              <footer>
                ${author}
              </footer>
            </div>
            
            </article>`
        }
      )
    }
  }

  disconnectedCallback() {
    // todo
  }
}

customElements.define('preview-lia', PreviewLia)
