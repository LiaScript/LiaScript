import { LiaScript } from '../../typescript/liascript/index'
import { Connector } from '../../typescript/connectors/Base/index'

require('../../scss/main.scss')

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

      this.courseURL = this.getAttribute('src')

      this.embed = this.getAttribute('embed') !== 'false'

      console.warn('embed', this.embed)

      this.responsiveVoiceKey = this.getAttribute('responsiveVoiceKey')
      this.scriptUrl = document.currentScript?.src

      if (this.embed && document.location.href.match('LiaScript=') === null) {
        const shadowRoot = this.attachShadow({
          mode: 'closed',
        })

        const iframe = document.createElement('iframe')
        iframe.sandbox = 'allow-scripts'

        //iframe.referrerPolicy = 'origin-when-cross-origin'

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

        iframe.src += '?LiaScript=' + this.courseURL
        iframe.name = 'liascript'

        shadowRoot.append(iframe)
      } else {
        let course = ''

        if (document.location.href.match('LiaScript=') !== null) {
          course = document.location.href.split('LiaScript=')[1]
        }

        if (course && this.courseURL === course) {
          const self = this
          setTimeout(function () {
            self.initLia()
          }, 1)
        }
      }
    }

    initLia() {
      this.courseURL = this.getAttribute('src')

      if (document.location.href.match('LiaScript=') !== null) {
        this.courseURL = document.location.href.split('LiaScript=')[1]
      }

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
