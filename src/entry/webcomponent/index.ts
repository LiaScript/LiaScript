import { LiaScript } from '../../typescript/liascript/index'
import { Connector } from '../../typescript/connectors/Base/index'

import customCSS from 'bundle-text:../../scss/main.scss'

import '../../typescript/webcomponents/editor'
import '../../typescript/webcomponents/formula'
import '../../typescript/webcomponents/embed/index'
import '../../typescript/webcomponents/chart'
import '../../typescript/webcomponents/preview-lia'
import '../../typescript/webcomponents/tooltip/index'
import '../../typescript/webcomponents/format'

customElements.define(
  'lia-script',

  class extends HTMLElement {
    private debug: boolean = false
    private app: any
    private embed: boolean = false

    private courseURL: string | null = null
    private responsiveVoiceKey: string | null = null
    private scriptUrl?: string
    private course?: string

    constructor() {
      super()
      if (process.env.NODE_ENV === 'development') {
        this.debug = true
      }
    }

    connectedCallback() {
      this.course = this.innerHTML || ''

      this.course = this.course.trim()

      //this.innerHTML = ''

      this.embed = this.getAttribute('embed') !== 'false'
      this.responsiveVoiceKey = this.getAttribute('responsiveVoiceKey')
      this.scriptUrl = document.currentScript?.src

      // shadowRoot.appendChild(this.container)
      if (this.embed) {
        const shadowRoot = this.attachShadow({
          mode: 'open',
        })

        const iframe = document.createElement('iframe')
        iframe.sandbox = 'allow-scripts allow-same-origin'

        //iframe.referrerPolicy = 'same-origin'

        const style = this.getAttribute('style')

        if (style) {
          iframe.style = style
          iframe.style.border = 'none'
          iframe.style.display = 'block'
        } else {
          iframe.style.width = '100%'
          iframe.style.height = '600px'
          iframe.style.border = 'none'
        }

        this.style.display = 'block'

        iframe.src = './?ReadMe.md'

        shadowRoot.append(iframe)

        iframe.contentDocument?.write(`<!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
          <style>
            ${customCSS}
          </style>
          <script type="module" src="${this.scriptUrl}"></script>
        <body>
          <lia-script src="ReadMe.md" embed="false">${this.course}</lia-script>
        </body>
        </html>`)

        iframe.contentDocument?.close()
      } else {
        const self = this
        setTimeout(function () {
          self.initLia()
        }, 1)
      }
    }

    initLia() {
      this.courseURL = this.getAttribute('src')

      // Load the Markdown document defined by the src attribute
      if (typeof this.courseURL === 'string') {
        this.app = new LiaScript(
          new Connector(),
          false, // allowSync
          this.debug,
          this.courseURL,
          null
        )
      } // Load the Content from within the web component
      else {
        this.app = new LiaScript(
          new Connector(),
          false, // allowSync
          this.debug,
          null,
          this.innerHTML.trimStart()
        )
      }
    }

    disconnectedCallback() {
      delete this.app
    }
  }
)
