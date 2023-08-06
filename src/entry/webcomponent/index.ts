import { LiaScript } from '../../typescript/liascript/index'
import * as Child from '../../typescript/connectors/IFrame/child'
import * as Parent from '../../typescript/connectors/IFrame/parent'
import * as Browser from '../../typescript/connectors/Browser/index'

require('../../scss/main.scss')

import '../../typescript/webcomponents/editor'
import '../../typescript/webcomponents/formula'
import '../../typescript/webcomponents/embed/index'
import '../../typescript/webcomponents/chart'
import '../../typescript/webcomponents/preview-lia'
import '../../typescript/webcomponents/tooltip/index'
import '../../typescript/webcomponents/format'

import { allowedProtocol, customElementsDefine } from '../../typescript/helper'

function getCourse(): [string | null, string | null] {
  let url: string | null = null
  let id: string | null = null

  if (document.location.href.match('LiaScript=') !== null) {
    const reference = document.location.href.split('LiaScript=')[1].split('|')

    if (reference.length > 1) {
      id = reference[0]
      url = reference[1]
    } else if (reference.length == 0) {
      url = reference[0]
    }
  }

  return [url, id]
}

async function start(
  embed: boolean,
  url: string | null,
  content: string | null,
  debug: boolean,
  allowSync: boolean,
  parentID?: string
) {
  if (embed) {
    if (parentID) {
      const course = await Child.postAwait('get-content', null, parentID)

      console.warn('XXXXXXXXXXXXXX', course)

      if (course.url !== null && course.content !== null) {
        course.content = null
      }

      app = new LiaScript(
        new Child.Connector(parentID),
        allowSync,
        debug,
        course.url,
        course.content
      )
    }
  } else {
    app = new LiaScript(new Browser.Connector(), allowSync, debug, url, content)
  }
}

var app: any

class LiaScriptElement extends HTMLElement {
  private debug: boolean = false
  private embed: boolean = false

  private courseURL: string | null = null
  private courseContent: string | null = null

  private connector?: Parent.Connector

  private responsiveVoiceKey: string | null = null

  constructor() {
    super()
    if (process.env.NODE_ENV === 'development') {
      this.debug = true
    }
  }

  getCourseURL(): [string | null, string | null] {
    let url: string | null = null
    let id: string | null = null

    if (this.embed && document.location.href.match('LiaScript=') !== null) {
      const reference = document.location.href.split('LiaScript=')[1].split('|')

      if (reference.length > 1) {
        id = reference[0]
        url = reference[1]
      } else if (reference.length == 0) {
        url = reference[0]
      }
    } else {
      url = this.getAttribute('src')
    }

    if (typeof url === 'string' && !allowedProtocol(url)) {
      url = new URL(url, document.location.href).href
    }

    return [url, id]
  }

  getCourseContent(): string | null {
    const course = this.innerHTML || ''

    return course.trim() || null
  }

  connectedCallback() {
    this.embed = this.getAttribute('embed') !== 'false'

    this.courseContent = this.getCourseContent()

    const [url, parentID] = this.getCourseURL()

    this.courseURL = url

    this.responsiveVoiceKey = this.getAttribute('responsiveVoiceKey')

    // LiaScript will take over entirely
    if (!this.embed) {
      start(this.embed, this.courseURL, this.courseContent, this.debug, false)
    }
    // prepare for embedding the course into an iframe
    else if (
      this.embed &&
      document.location.href.match('LiaScript=') === null
    ) {
      const id_ = Math.random().toString(36).substr(2, 9)
      const self = this

      window.addEventListener('message', async (event) => {
        try {
          console.warn('XXXXXXXXXX', event.data)

          const { cmd, param, id } = JSON.parse(event.data)

          switch (cmd) {
            case 'get-content': {
              if (id === id_) {
                Parent.resolve(event, {
                  url: self.courseURL,
                  content: self.courseContent,
                })
              }
            }
          }
        } catch (e) {}
      })

      this.connector = new Parent.Connector(id_)

      const shadowRoot = this.attachShadow({
        mode: 'closed',
      })

      const iframe = document.createElement('iframe')
      iframe.sandbox = 'allow-scripts allow-same-origin allow-popups'

      iframe.style.width = '100%'
      iframe.style.height = '100%'
      iframe.style.border = 'none'

      this.style.display = 'none'

      iframe.src += '?LiaScript=' + id_ + '|' + this.courseURL
      iframe.name = 'liascript'

      iframe.style.display = 'none'
      iframe.setAttribute('data-embed', 'true')

      iframe.onload = () => {
        iframe.style.display = 'block'
        self.style.display = 'block'
      }

      shadowRoot.append(iframe)
    }
  }

  disconnectedCallback() {
    app = undefined
  }
}

customElementsDefine('lia-script', LiaScriptElement)

const [url, parentID] = getCourse()

console.warn('XXXXXX LiaScript: ' + url + ' ' + parentID)

// load embedded immediately if identified
if (parentID) {
  start(
    true,
    null,
    null,
    process.env.NODE_ENV === 'development',
    false,
    parentID
  )
}
