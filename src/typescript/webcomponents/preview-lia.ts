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
html {
  font-size: 62.5%;
}
  body {
    font-size: 1.5rem;
}
  .card {
    border: 1px solid #399193;
    position: relative;
    background-color: white;
    display: flex;
    flex-direction: column;
    max-width: 42.6rem;
}
  @media screen and (min-width: 768px) and (max-width: 1024px) {
    .card {
      display: grid;
      grid-template-columns: 40% 1fr;
      max-width: 100%;
  }
}
  @media screen and (min-width: 1024px) {
    .card {
      max-width: 42.6rem;
  }
}
  .card__media {
    margin-bottom: 2rem;
    height: 100%;
}
  @media screen and (min-width: 768px) and (max-width: 1024px) {
    .card__media {
      margin-bottom: 0;
  }
}
  .card__content {
    display: flex;
    flex-direction: column;
    height: 100%;
}
  @media screen and (min-width: 768px) and (max-width: 1024px) {
    .card__content {
      margin-top: 4rem;
      height: auto;
  }
}
  @media screen and (min-width: 768px) and (max-width: 1024px) {
    .card__aside {
      height: 100%;
  }
}
  .card__figure {
    margin: 0;
    height: 20rem;
    width: 100%;
}
  @media screen and (min-width: 768px) and (max-width: 1024px) {
    .card__figure {
      height: 100%;
  }
}
  .card__image {
    height: 100%;
    width: 100%;
    object-fit: cover;
}
  .card__version {
    display: inline-block;
    padding: 0.5rem;
    background-color: #399193;
    color: white;
    position: absolute;
    top: 0;
    right: 2.4rem;
}
  .card__header {
    padding: 0 2.4rem;
}
  .card__title {
    display: inline-block;
    color: #4b4b4b;
    font-size: 2.3rem;
    font-family: serif;
    position: relative;
    margin: 0 0 2rem;
}
  .card__title:before {
    content: "";
    position: absolute;
    bottom: -0.5rem;
    width: 80%;
    height: 1px;
    background-color: #399193;
}
  .card__subtitle {
    color: #aeaeae;
    margin: 0 0 1rem;
}
  .card__body {
    padding: 0 2.4rem;
}
  .card__footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 2.4rem;
    margin-top: auto;
}
  .card__contact {
    color: #399193;
    text-decoration: none;
}
</style>
<div id="container" style="display:inline-block"></div>`

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
    const div = this.container.getElementById('container')

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

    if (div) {
      div.innerHTML = `<a href="${url}">preview-lia</a>`

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
            tagLine = `<h4 class="card__subtitle">${tags.join(' | ')}</h4>`
          }

          if (logo) {
            logo_alt = logo_alt ? `alt="${logo_alt}"` : ''
            logo = `<div class="card__media">
              <aside class="card__aside">
                <figure class="card__figure">
                  <img src="${logo}" ${logo_alt} class="card__image">
                </figure>
              </aside>
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

          div.innerHTML = `<a href="${link}" style="text-decoration: none; color: black"><article class="card">
            <div class="card__version">V ${version}</div>
            ${logo}
            <div class="card__content">
              <header class="card__header">
                <h3 class="card__title">${title}</h3>
                ${tagLine}
              </header>
              <div class="card__body">
                <p class="card__copy">${description}</p>
              </div>
              <footer class="card__footer">
                <img height="50" src="${icon}" alt="Logo" class="card__logo">
                ${author}
              </footer>
            </div>
            </article></a>`
        }
      )
    }
  }

  disconnectedCallback() {
    // todo
  }
}

helper.customElementsDefine('preview-lia', PreviewLia)
