// @ts-ignore
import { Elm } from '../../elm/Worker.elm'

function fetch(self: PreviewLia) {
  let http = new XMLHttpRequest()

  http.open('GET', self.source_url, true)

  http.onload = function (_e) {
    if (http.readyState === 4 && http.status === 200) {
      try {
        self.parse(http.responseText)
      } catch (e) {
        console.warn('fetching', e)
      }
    }
  }
  http.send()
}

class PreviewLia extends HTMLElement {
  private lia: any
  public container: ShadowRoot
  public source_url: string

  constructor() {
    super()

    this.source_url = ''
    this.lia = Elm.Worker.init({
      flags: {
        cmd: '',
      },
    })

    const template = document.createElement('template')

    template.innerHTML = `
    <style>    
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

      this.lia.ports.output.subscribe(function (event: [boolean, any]) {
        let [ok, json] = event

        if (ok) {
          json = JSON.parse(json)

          let tags, icon, author, logo

          try {
            tags = json.definition.macro.tags
              .split(',')
              .map((e: string) => e.trim())
              .join(' | ')

            tags = `<h4 class="card__subtitle">${tags}</h4>`
          } catch (e) {
            tags = ''
          }

          try {
            icon = self.addBase(json.definition.macro.icon)
          } catch (e) {
            icon = 'https://liascript.github.io/course/icon.ico'
          }

          logo = ''
          if (json.definition.logo !== '') {
            logo = `<div class="card__media">
              <aside class="card__aside">
                <figure class="card__figure">
                  <img src="${self.addBase(
                    json.definition.logo,
                  )}" class="card__image">
                </figure>
              </aside>
            </div>`
          }

          if (json.definition.author !== '' && json.definition.email !== '') {
            author = `<a class="card__contact" href="mailto:${json.definition.email}">${json.definition.author} ✉️</a>`
          } else if (json.definition.author !== '') {
            author = `<span class="card__contact">${json.definition.author}</span>`
          } else if (json.definition.email !== '') {
            author = `<a class="card__contact" href="mailto:${json.definition.email}">${json.definition.email} ✉️</a>`
          } else {
            author = ''
          }

          if (json.sections.length !== 0) {
            div.innerHTML = `<a href="${link}" style="text-decoration: none; color: black"><article class="card">
            <div class="card__version">V ${json.definition.version}</div>
            ${logo}
            <div class="card__content">
              <header class="card__header">
                <h3 class="card__title">${json.str_title}</h3>
                ${tags}
              </header>
              <div class="card__body">
                <p class="card__copy">${json.comment}</p>
              </div>
              <footer class="card__footer">
                <img height="50" src="${icon}" alt="Logo" class="card__logo">
                ${author}
              </footer>
            </div>
            </article></a>`
          }
        } else {
          console.warn('could not load course ...')
        }
      })
      fetch(self)
    }
  }

  disconnectedCallback() {
    // todo
  }

  parse(course: string) {
    this.lia.ports.input.send(['defines', course])
  }

  addBase(url: string) {
    if (url.startsWith('http')) {
      return url
    }

    let base = this.source_url.split('/')
    base.pop()
    return base.join('/') + '/' + url
  }
}

customElements.define('preview-lia', PreviewLia)
