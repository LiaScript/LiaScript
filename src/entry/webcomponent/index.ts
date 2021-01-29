import '@babel/polyfill'

import LiaScript from '../../typescript/liascript/index'
import { Connector } from '../../typescript/connectors/Base/index'
import TTS from '../../typescript/liascript/tts'

import "../../scss/main.scss"
import "../../../node_modules/material-icons/iconfont/material-icons.scss"

import "../../typescript/webcomponents/editor"
import "../../typescript/webcomponents/formula"
import "../../typescript/webcomponents/oembed"
import "../../typescript/webcomponents/chart"
import "../../typescript/webcomponents/preview-lia"
import "../../typescript/webcomponents/preview-link"
import "../../typescript/webcomponents/format"


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
        this.textContent
      )
    }

    window.showFootnote = (key) => this.app.footnote(key);
    //window.gotoLia = (line: number) => this.app.goto(line);
    //window.jitLia = (code: string) => this.app.jit(code);
  }

  initResponsiveVoice() {
    this.responsiveVoiceKey = this.getAttribute("responsiveVoiceKey")

    if (typeof this.responsiveVoiceKey === "string") {
      TTS.inject(this.responsiveVoiceKey)
    }
  }

  disconnectedCallback() {
    delete this.app
  }
})
