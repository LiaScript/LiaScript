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

type Course = {
  url: string | null
  id: string | null
  key: string | null
}

function getCourse(): Course {
  let course: Course = {
    url: null,
    id: null,
    key: null,
  }

  if (document.location.href.match('LiaScript=') !== null) {
    const reference = document.location.href.split('LiaScript=')[1].split('|')

    course.url = reference[0] || null
    course.id = reference[1] || null
    course.key = reference[2] || null
  }

  return course
}

function link(url: string) {
  let tag = document.createElement('link')
  tag.href = url
  tag.rel = 'stylesheet'
  tag.type = 'text/css'

  tag.onerror = (_event) => {
    console.warn('could not load =>', url)
  }

  document.head.appendChild(tag)
}

async function start(
  embed: boolean,
  url: string | null,
  content: string | null,
  responsiveVoiceKey: string | null,
  debug: boolean,
  allowSync: boolean,
  parentID?: string
) {
  document.querySelector('style')?.remove()
  document.querySelector('link')?.remove()

  let src = new URL((document.currentScript as HTMLScriptElement)?.src)

  let path = src.pathname.split('/')
  path.pop()
  src.pathname = path.join('/')

  link(src.href + '/index.css')
  link(src.href + '/katex.min.css')

  if (embed) {
    if (parentID) {
      const course = await Child.postAwait('get-content', null, parentID)

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

  if (responsiveVoiceKey) {
    window?.LIA?.injectResposivevoice(responsiveVoiceKey)
  }
}

var app: any

class LiaScriptElement extends HTMLElement {
  private debug: boolean = false
  private embed: boolean = false
  private singlePage: boolean = false

  private courseURL: string | null = null
  private courseContent: string | null = null

  private responsiveVoiceKey: string | null = null

  constructor() {
    super()

    if (process.env.NODE_ENV === 'development') {
      this.debug = true
    }
  }

  getCourseURL(): Course {
    let course = getCourse()

    if (this.embed && !course.url) {
      course.url = this.getAttribute('src')
    }

    if (typeof course.url === 'string' && !allowedProtocol(course.url)) {
      course.url = new URL(course.url, document.location.href).href
    }

    return course
  }

  getCourseContent(): string | null {
    const course = this.innerHTML || ''

    return course.trim() || null
  }

  connectedCallback() {
    this.embed = this.getAttribute('embed') !== 'false'

    this.courseContent = this.getCourseContent()

    const course = this.getCourseURL()

    this.courseURL = course.url

    this.responsiveVoiceKey = this.getAttribute('responsiveVoiceKey')
    this.singlePage = this.getAttribute('singlePage') === 'true'

    // LiaScript will take over entirely
    if (!this.embed) {
      start(
        this.embed,
        this.courseURL,
        this.courseContent,
        this.responsiveVoiceKey,
        this.debug,
        false
      )
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

      Parent.startListening(id_)

      const shadowRoot = this.attachShadow({
        mode: 'closed',
      })

      const iframe = document.createElement('iframe')
      iframe.setAttribute(
        'sandbox',
        'allow-scripts allow-same-origin allow-popups'
      )

      iframe.style.width = '100%'
      iframe.style.height = '100%'
      iframe.style.border = 'none'

      this.style.display = 'none'

      iframe.src =
        document.location.href +
        '?LiaScript=' +
        this.courseURL +
        '|' +
        id_ +
        (this.responsiveVoiceKey ? '|' + this.responsiveVoiceKey : '')

      iframe.name = 'liascript'

      iframe.style.display = 'none'
      iframe.setAttribute('data-embed', 'true')

      iframe.onload = () => {
        setTimeout(() => {
          iframe.style.display = 'block'
          self.style.display = 'block'

          console.log('XXXXXXXXXXXXXXXXXx iframe loaded', iframe.contentWindow)
        }, 1000)
      }

      shadowRoot.append(iframe)
    }
  }

  disconnectedCallback() {
    app = undefined
  }
}

customElementsDefine('lia-script', LiaScriptElement)

const course = getCourse()

// load embedded immediately if identified
if (course.id) {
  start(
    true,
    null,
    null,
    course.key,
    process.env.NODE_ENV === 'development',
    false,
    course.id
  )
}
