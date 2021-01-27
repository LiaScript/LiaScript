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

    this.initResponsiveVoice()
    this.initLia()
  }

  initLia() {
    this.courseURL = this.getAttribute("src")

    if (typeof this.courseURL === "string") {
      // Load the Markdown document defined by the src attribute
      this.app = new LiaScript(
        this.container,
        new Connector(),
        this.debug,
        this.courseURL,
      )
    } else {
      // Load the Content from within the web component
      this.app = new LiaScript(
        this.container,
        new Connector(),
        this.debug,
        null,
        this.innerText
      )
    }

    window.showFootnote = (key) => this.app.footnote(key);
    //window.gotoLia = (line: number) => this.app.goto(line);
    //window.jitLia = (code: string) => this.app.jit(code);
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
