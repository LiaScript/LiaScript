import '@babel/polyfill'

import LiaScript from '../../typescript/liascript/index'
import { Connector } from '../../typescript/connectors/Base/index'

import "../../scss/main.scss"
import "../../../node_modules/material-icons/iconfont/material-icons.scss"

import "../../typescript/webcomponents/editor.ts"
import "../../typescript/webcomponents/formula.ts"
import "../../typescript/webcomponents/oembed.ts"
import "../../typescript/webcomponents/chart.ts"
import "../../typescript/webcomponents/preview-lia.ts"
import "../../typescript/webcomponents/preview-link.ts"
import "../../typescript/webcomponents/format.ts"

customElements.define('lia-script', class extends HTMLElement {
  private container: HTMLDivElement
  private debug: boolean
  private app: any

  private courseURL: string | null
  private responsiveVoiceKey: string | null

  constructor() {
    super()

    this.debug = false
    this.courseURL = null
    this.responsiveVoiceKey = null

    if (process.env.NODE_ENV === 'development') {
      this.debug = true
    }

    this.container = document.createElement('div')
  }

  connectedCallback() {
    const shadowRoot = this.attachShadow({
      mode: 'open'
    })

    shadowRoot.appendChild(this.container)

    this.initLia()
    this.initResponsiveVoice()
  }

  initLia() {
    this.courseURL = this.getAttribute("src")

    // Load the Markdown document defined by the src attribute
    if (typeof this.courseURL === "string") {
      this.app = new LiaScript(
        this.container,
        new Connector(),
        this.debug,
        this.courseURL,
        null
      )
    } // Load the Content from within the web component
    else {
      this.app = new LiaScript(
        this.container,
        new Connector(),
        this.debug,
        null,
        this.innerHTML
      )
    }

    window.showFootnote = (key) => this.app.footnote(key);
    window.gotoLia = (line: number) => this.app.goto(line);
    window.jitLia = (code: string) => this.app.jit(code);
  }

  initResponsiveVoice() {
    this.responsiveVoiceKey = this.getAttribute("responsiveVoiceKey")

    if (typeof this.responsiveVoiceKey === "string") {
      let tag = document.createElement("script")

      tag.src = "https://code.responsivevoice.org/responsivevoice.js?key=" + this.responsiveVoiceKey
      document.head.appendChild(tag)
    }
  }

  disconnectedCallback() {
    delete this.app
  }
})
