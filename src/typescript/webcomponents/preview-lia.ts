import {
  Elm
} from '../../elm/Worker.elm'

function fetch(self: PreviewLia) {
  let http = new XMLHttpRequest()

  http.open('GET', self.source_url, true)

  http.onload = function(_e) {
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
        cmd: ''
      }
    })

    const template = document.createElement('template')

    template.innerHTML = `
    <style>
    .blog-card {
       display: flex;
       flex-direction: column;
       margin: 1rem auto;
       box-shadow: 0 3px 7px -1px rgba(0, 0, 0, .1);
       margin-bottom: 1.6%;
       background: #fff;
       line-height: 1.4;
       font-family: sans-serif;
       border-radius: 5px;
       overflow: hidden;
       z-index: 0;
    }
     .blog-card a {
       color: inherit;
    }
     .blog-card a:hover {
       color: #5ad67d;
    }
     .blog-card:hover .photo {
       transform: scale(1.3) rotate(3deg);
    }
     .blog-card .meta {
       position: relative;
       z-index: 0;
       height: 200px;
    }
     .blog-card .photo {
       position: absolute;
       top: 0;
       right: 0;
       bottom: 0;
       left: 0;
       background-size: cover;
       background-position: center;
       transition: transform 0.2s;
    }
     .blog-card .details, .blog-card .details ul {
       margin: auto;
       padding: 0;
       list-style: none;
    }
     .blog-card .details {
       position: absolute;
       top: 0;
       bottom: 0;
       left: -100%;
       margin: auto;
       transition: left 0.2s;
       background: rgba(0, 0, 0, .6);
       color: #fff;
       padding: 10px;
       width: 100%;
       font-size: 0.9rem;
    }
     .blog-card .details a {
       text-decoration: dotted underline;
    }
     .blog-card .details ul li {
       display: inline-block;
    }
     .blog-card .details .author:before {
       font-family: FontAwesome;
       margin-right: 10px;
       content: "\f007";
    }
     .blog-card .details .date:before {
       font-family: FontAwesome;
       margin-right: 10px;
       content: "\f133";
    }
     .blog-card .details .tags ul:before {
       font-family: FontAwesome;
       content: "\f02b";
       margin-right: 10px;
    }
     .blog-card .details .tags li {
       margin-right: 2px;
    }
     .blog-card .details .tags li:first-child {
       margin-left: -4px;
    }
     .blog-card .description {
       padding: 1rem;
       background: #fff;
       position: relative;
       z-index: 1;
    }
     .blog-card .description h1, .blog-card .description h2 {
       font-family: Poppins, sans-serif;
    }
     .blog-card .description h1 {
       line-height: 1;
       margin: 0;
       font-size: 1.7rem;
    }
     .blog-card .description h2 {
       font-size: 1rem;
       font-weight: 300;
       text-transform: uppercase;
       color: #a2a2a2;
       margin-top: 5px;
    }
     .blog-card .description .read-more {
       text-align: right;
    }
     .blog-card .description .read-more a {
       color: #5ad67d;
       display: inline-block;
       position: relative;
    }
     .blog-card .description .read-more a:after {
       content: "\f061";
       font-family: FontAwesome;
       margin-left: -10px;
       opacity: 0;
       vertical-align: middle;
       transition: margin 0.3s, opacity 0.3s;
    }
     .blog-card .description .read-more a:hover:after {
       margin-left: 5px;
       opacity: 1;
    }
     .blog-card p {
       position: relative;
       margin: 1rem 0 0;
    }
     .blog-card p:first-of-type {
       margin-top: 1.25rem;
    }
     .blog-card p:first-of-type:before {
       content: "";
       position: absolute;
       height: 5px;
       background: #5ad67d;
       width: 35px;
       top: -0.75rem;
       border-radius: 3px;
    }
     .blog-card:hover .details {
       left: 0%;
    }
     @media (min-width: 640px) {
       .blog-card {
         flex-direction: row;
         max-width: 700px;
      }
       .blog-card .meta {
         flex-basis: 40%;
         height: auto;
      }
       .blog-card .description {
         flex-basis: 60%;
      }
       .blog-card .description:before {
         transform: skewX(-3deg);
         content: "";
         background: #fff;
         width: 30px;
         position: absolute;
         left: -10px;
         top: 0;
         bottom: 0;
         z-index: -1;
      }
       .blog-card.alt {
         flex-direction: row-reverse;
      }
       .blog-card.alt .description:before {
         left: inherit;
         right: -10px;
         transform: skew(3deg);
      }
       .blog-card.alt .details {
         padding-left: 25px;
      }
    }
    </style>
    <div id="container" style="display: inline"></div>
    `

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

    const link = this.getAttribute('link') || ('https://LiaScript.github.io/course/?' + this.source_url)

    if (div) {
      div.innerHTML = `<a href="${url}">preview-lia</a>`

      let self = this

      this.lia.ports.output.subscribe(function(event: [boolean, any]) {
        let [ok, json] = event

        if (ok) {
          json = JSON.parse(json)

          let tag

          try {
            tag = json.definition.macro.tags.split(',').map((e: string) => e.trim())
          } catch (e) {
            tag = []
          }

          let logo = json.definition.logo

          if (!logo.startsWith('http')) {
            let base = self.source_url.split('/')
            base.pop()
            logo = base.join('/') + '/' + logo
          }

          if (json.sections.length !== 0) {
            div.className = 'blog-card'
            div.style.all = ''
            div.innerHTML = `<div class="meta">
              <div class="photo" style="background-image: url(${logo})"></div>
              <ul class="details">
                <li class="author">${json.definition.author}</li>
                <li class="date"><a href="mailto:${json.definition.email}">${json.definition.email}</a></li>
                <li class="tags">
                  <ul>
                    <li>${!tag[0] ? '' : tag[0]}</li>
                    <li>${!tag[1] ? '' : tag[1]}</li>
                    <li>${!tag[2] ? '' : tag[2]}</li>
                    <li>${!tag[3] ? '' : '...'}</li>
                  </ul>
                </li>
              </ul>
            </div>
            <div class="description">
              <h1>${json.str_title}</h1>
              <h2>Version: ${json.definition.version}</h2>
              <p> ${json.comment} </p>
              <p class="read-more">
                <a href="${link}">Open</a>
              </p>
            </div>`
          }

          // `${json.str_title} <br>  <img style="width: 90px" src="${json.definition.logo}">`
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
}


customElements.define('preview-lia', PreviewLia)
