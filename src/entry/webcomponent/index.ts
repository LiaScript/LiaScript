import { LiaScript } from '../../typescript/liascript/index'
import * as Child from '../../typescript/connectors/IFrame/child'
import * as Parent from '../../typescript/connectors/IFrame/parent'

require('../../scss/main.scss')

import '../../typescript/webcomponents/editor'
import '../../typescript/webcomponents/formula'
import '../../typescript/webcomponents/embed/index'
import '../../typescript/webcomponents/chart'
import '../../typescript/webcomponents/preview-lia'
import '../../typescript/webcomponents/tooltip/index'
import '../../typescript/webcomponents/format'

import { allowedProtocol } from '../../typescript/helper'

customElements.define(
  'lia-script',

  class extends HTMLElement {
    private debug: boolean = false
    private app: any
    private embed: boolean = false

    private courseURL: string | null = null
    private courseString: string | null = null
    private responsiveVoiceKey: string | null = null
    private scriptUrl?: string

    private connector?: Parent.Connector

    constructor() {
      super()
      if (process.env.NODE_ENV === 'development') {
        this.debug = true
      }
    }

    getCourseURL(): string | null {
      let url: string | null = null

      if (this.embed && document.location.href.match('LiaScript=') !== null) {
        url = document.location.href.split('LiaScript=')[1]
      } else {
        url = this.getAttribute('src')
      }

      if (typeof url === 'string' && !allowedProtocol(url)) {
        url = new URL(url, document.location.href).href
      }

      return url
    }

    getCourseString(): string | null {
      const course = this.innerHTML || ''

      return course.trim() || null
    }

    connectedCallback() {
      this.courseString = this.getCourseString()

      this.courseURL = this.getCourseURL()

      this.embed = this.getAttribute('embed') !== 'false'

      this.responsiveVoiceKey = this.getAttribute('responsiveVoiceKey')

      this.scriptUrl = document.currentScript?.src

      if (this.embed && document.location.href.match('LiaScript=') === null) {
        const shadowRoot = this.attachShadow({
          mode: 'closed',
        })

        const iframe = document.createElement('iframe')
        iframe.sandbox = 'allow-scripts allow-same-origin allow-popups'

        this.connector = new Parent.Connector()
        //iframe.referrerPolicy = 'origin-when-cross-origin'

        //const style = this.getAttribute('style')

        iframe.style.width = '100%'
        iframe.style.height = '100%'
        iframe.style.border = 'none'

        this.style.display = 'none'

        iframe.src += '?LiaScript=' + this.courseURL
        iframe.name = 'liascript'

        iframe.style.display = 'none'

        const self = this

        iframe.onload = () => {
          console.warn('XXXX   iframe loaded')
          iframe.style.display = 'block'
          self.style.display = 'block'
        }

        shadowRoot.append(iframe)
      } else {
        let course = ''

        if (document.location.href.match('LiaScript=') !== null) {
          course = document.location.href.split('LiaScript=')[1]
        }

        if (
          (course && this.courseURL === course) ||
          (!this.embed && this.courseURL)
        ) {
          const self = this
          setTimeout(function () {
            self.initLia()
          }, 1)
        } else if (this.courseString) {
          this.initLia()
        }
      }
    }

    initLia() {
      this.courseURL = this.getCourseURL()

      if (this.embed && document.location.href.match('LiaScript=') !== null) {
        this.courseURL = document.location.href.split('LiaScript=')[1]
      }

      // Load the Markdown document defined by the src attribute
      if (!this.courseString && typeof this.courseURL === 'string') {
        this.app = new LiaScript(
          new Child.Connector(),
          false, // allowSync
          this.debug,
          this.courseURL,
          null
        )
      } // Load the Content from within the web component
      else {
        this.app = new LiaScript(
          new Child.Connector(),
          false, // allowSync
          this.debug,
          null,
          this.courseString
        )
      }
    }

    disconnectedCallback() {
      delete this.app
    }
  }
)
