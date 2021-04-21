// @ts-ignore
import { Elm } from '../../elm/Main.elm'
import { LiaEvents, lia_execute_event, lia_eval_event } from './events'
// import persistent from './persistent.ts'
import log from './log'
import * as Swipe from './swipe'

import './types/globals'
import Lia from './types/lia.d'
import Port from './types/ports'
import TTS from './tts'
import { Connector } from '../connectors/Base/index'
import { updateClassName } from '../connectors/Base/settings'

function isInViewport(elem: HTMLElement) {
  const bounding = elem.getBoundingClientRect()
  return (
    bounding.top >= 85 &&
    bounding.left >= 0 &&
    bounding.bottom <=
      (window.innerHeight - 40 || document.documentElement.clientHeight - 40) &&
    bounding.right <=
      (window.innerWidth || document.documentElement.clientWidth)
  )
}

function scrollIntoView(id: string, delay: number) {
  setTimeout(function () {
    const elem = document.getElementById(id)

    if (elem) {
      elem.scrollIntoView({ behavior: 'smooth' })
    }
  }, delay)
}

function handleEffects(
  event: Lia.Event,
  elmSend: Lia.Send,
  section: number = -1,
  self?: LiaScript,
) {
  switch (event.topic) {
    case 'scrollTo':
      scrollIntoView(event.message, 350)
      break
    case 'persistent':
      // Todo
      // setTimeout((e) => { persistent.load(event.section) }, 10)
      break
    case 'execute':
      lia_execute_event(event.message, elmSend, section)
      break
    case 'speak': {
      let msg = {
        topic: Port.SETTINGS,
        section: -1,
        message: {
          topic: 'speak',
          section: -1,
          message: 'stop',
        },
      }

      if (section >= 0) {
        msg = {
          topic: Port.EFFECT,
          section: section,
          message: {
            topic: 'speak',
            section: event.section,
            message: 'stop',
          },
        }
      }

      try {
        if (event.message === 'cancel') {
          TTS.cancel()
          msg.message.message = 'stop'
          elmSend(msg)
        } else if (event.message === 'repeat') {
          event.message = [ttsBackup[0], ttsBackup[1], 'true']
          handleEffects(event, elmSend)
        } else if (
          typeof event.message === 'string' &&
          event.message.startsWith('lia-tts-')
        ) {
          let element = document.getElementsByClassName(event.message)

          let text = ''

          for (let i = 0; i < element.length; i++) {
            text += element[i].innerText || element[i].textContent
          }

          // This is used to clean up effect numbers, which are marked by a \b
          text = text.replace(/\\u001a\\d+\\u001a/g, '').trim()

          if (text !== '') {
            TTS.speak(
              text,
              element[0].getAttribute('data-voice'),
              function () {
                msg.topic = Port.SETTINGS
                msg.message.message = 'start'

                elmSend(msg)
              },
              function () {
                msg.topic = Port.SETTINGS
                msg.message.message = 'stop'
                elmSend(msg)
              },
              function (e: any) {
                msg.message.message = e.toString()
                elmSend(msg)
              },
            )
          }
        } else if (firstSpeak) {
          // this is a hack to deal with the delay in responsivevoice
          firstSpeak = false
          setTimeout(function () {
            handleEffects(event, elmSend)
          }, 200)
        } else {
          ttsBackup = event.message
          if (event.message[2] === 'true') {
            TTS.speak(
              event.message[1],
              event.message[0],
              function () {
                msg.message.message = 'start'
                elmSend(msg)
              },
              function () {
                msg.message.message = 'stop'
                elmSend(msg)
              },
              function (e: any) {
                msg.message.message = e.toString()
                elmSend(msg)
              },
            )
          }
        }
      } catch (e) {
        msg.message.message = e.toString()
        elmSend(msg)
      }
      break
    }
    case 'sub': {
      if (self != undefined && event.message != null) {
        const newSend = function (subEvent: Lia.Event) {
          elmSend({
            topic: Port.EFFECT,
            section: section,
            message: {
              topic: 'sub',
              section: event.section,
              message: subEvent,
            },
          })
        }

        process(false, self, newSend, event.message)
      }
      break
    }
    default: {
      // checking for sub-events
      log.warn('effect missed => ', event, section)
    }
  }
}

function meta(name: string, content: string) {
  if (content !== '') {
    let meta = document.createElement('meta')
    meta.name = name
    meta.content = content
    document.getElementsByTagName('head')[0].appendChild(meta)
  }
}
// -----------------------------------------------------------------------------

var eventHandler: LiaEvents
var liaStorage: any
var ttsBackup: [string, string]
var firstSpeak = true

class LiaScript {
  private app: any
  public connector: Connector

  constructor(
    elem: HTMLElement,
    connector: Connector,
    debug: boolean = false,
    courseUrl: string | null = null,
    script: string | null = null,
  ) {
    if (debug) window.debug__ = true

    eventHandler = new LiaEvents()

    this.app = Elm.Main.init({
      node: elem,
      flags: {
        courseUrl: courseUrl,
        script: script,
        settings: connector.getSettings(),
        screen: {
          width: window.innerWidth,
          height: window.innerHeight,
        },
        hasShareAPI: !!navigator.share,
        hasIndex: connector.hasIndex(),
      },
    })

    const sendTo = this.app.ports.event2elm.send

    const sender = function (msg: Lia.Event) {
      log.info(`LIA <<< (${msg.topic}:${msg.section})`, msg.message)
      sendTo(msg)
    }

    this.connector = connector
    this.connector.connect(sender)
    this.initEventSystem(elem, this.app.ports.event2js.subscribe, sender)

    liaStorage = this.connector.storage()

    window.playback = function (event) {
      handleEffects(event.message, sender, event.section)
    }

    let self = this
    window.showFootnote = (key) => {
      self.footnote(key)
    }
    window.img_ = (src: string, width: number, height: number) => {
      self.img_(src, width, height)
    }
    window.img_Click = (url: string) => {
      self.img_Click(url)
    }

    setTimeout(function () {
      firstSpeak = false
    }, 1000)
  }

  footnote(key: string) {
    this.app.ports.footnote.send(key)
  }

  img_(src: string, width: number, height: number) {
    this.app.ports.media.send([src, width, height])
  }

  img_Click(url: string) {
    // abuse media port to open modals
    if (document.getElementsByClassName('lia-modal').length === 0) {
      console.warn("SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs", url)
      this.app.ports.media.send([url, null, null])
    }
  }

  initNaviation(elem: HTMLElement, elmSend: Lia.Send) {
    Swipe.detect(elem, function (swipedir) {
      if (document.getElementsByClassName('lia-modal').length === 0) {
        elmSend({
          topic: Port.SWIPE,
          section: -1,
          message: swipedir,
        })
      }
    })

    elem.addEventListener(
      'keydown',
      (e) => {
        switch (e.key) {
          case 'ArrowRight': {
            if (document.getElementsByClassName('lia-modal').length === 0) {
              elmSend({
                topic: Port.SWIPE,
                section: -1,
                message: Swipe.Dir.left,
              })
            }
            break
          }
          case 'ArrowLeft': {
            if (document.getElementsByClassName('lia-modal').length === 0) {
              elmSend({
                topic: Port.SWIPE,
                section: -1,
                message: Swipe.Dir.right,
              })
            }
            break
          }
        }
      },
      false,
    )
  }

  reset() {
    this.app.ports.event2elm.send({
      topic: Port.RESET,
      section: -1,
      message: null,
    })
  }

  initEventSystem(
    elem: HTMLElement,
    jsSubscribe: (fn: (_: Lia.Event) => void) => void,
    elmSend: Lia.Send,
  ) {
    log.info('initEventSystem')

    let self = this

    this.initNaviation(elem, elmSend)

    var observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        changeGoogleStyles()

        elmSend({
          topic: 'lang',
          section: -1,
          message: document.documentElement.lang,
        })
      })
    })

    observer.observe(document.documentElement, {
      attributes: true,
      childList: false,
      characterData: false,
      attributeFilter: ['lang'],
    })

    jsSubscribe((event: Lia.Event) => {
      process(true, self, elmSend, event)
    })
  }
}

function process(
  isConnected: boolean,
  self: LiaScript,
  elmSend: Lia.Send,
  event: Lia.Event,
) {
  log.info(`LIA >>> (${event.topic}:${event.section})`, event.message)

  switch (event.topic) {
    case Port.SLIDE: {
      self.connector.slide(event.section)

      const sec = document.getElementsByTagName('main')[0]
      if (sec) {
        sec.scrollTo(0, 0)

        if (sec.children.length > 0) {
          sec.children[0].focus()
        }
      }

      const elem = document.getElementById('focusedToc')
      if (elem) {
        if (!isInViewport(elem)) {
          elem.scrollIntoView({
            behavior: 'smooth',
          })
        }
      }

      break
    }
    case Port.LOAD: {
      self.connector.load({
        topic: event.message,
        section: event.section,
        message: null,
      })
      break
    }
    case Port.CODE: {
      switch (event.message.topic) {
        case 'eval':
          lia_eval_event(elmSend, eventHandler, event)
          break
        case 'store':
          if (isConnected) {
            event.message = event.message.message
            self.connector.store(event)
          }
          break
        case 'input':
          eventHandler.dispatch_input(event)
          break
        case 'stop':
          eventHandler.dispatch_input(event)
          break
        default: {
          if (isConnected) {
            self.connector.update(event.message, event.section)
          }
        }
      }
      break
    }
    case Port.QUIZ: {
      if (isConnected && event.message.topic === 'store') {
        event.message = event.message.message
        self.connector.store(event)
      } else if (event.message.topic === 'eval') {
        lia_eval_event(elmSend, eventHandler, event)
      }

      break
    }
    case Port.SURVEY: {
      if (isConnected && event.message.topic === 'store') {
        event.message = event.message.message
        self.connector.store(event)
      } else if (event.message.topic === 'eval') {
        lia_eval_event(elmSend, eventHandler, event)
      }
      break
    }
    case Port.TASK: {
      if (isConnected && event.message.topic === 'store') {
        event.message = event.message.message
        self.connector.store(event)
      } else if (event.message.topic === 'eval') {
        lia_eval_event(elmSend, eventHandler, event)
      }
      break
    }
    case Port.EFFECT:
      handleEffects(event.message, elmSend, event.section, self)
      break
    case Port.SETTINGS: {
      // if (self.channel) {
      //  self.channel.push('lia', {settings: event.message});
      // } else {

      try {
        updateClassName(event.message[0])

        const conf = self.connector.getSettings()

        setTimeout(function () {
          window.dispatchEvent(new Event('resize'))
        }, 333)

        let style = document.getElementById('lia-custom-style')

        if (typeof event.message[1] === 'string') {
          if (style == null) {
            style = document.createElement('style')
            style.id = 'lia-custom-style'
            document.head.appendChild(style)
          }

          style.innerHTML = ':root {' + event.message[1] + '}'
        } else if (style !== null) {
          style.innerHTML = ''
        }
      } catch (e) {}

      if (isConnected) {
        self.connector.setSettings(event.message[0])
      }

      break
    }
    case Port.RESOURCE: {
      let elem = event.message[0]
      let url = event.message[1]

      log.info('loading resource => ', elem, ':', url)

      try {
        let tag = document.createElement(elem)
        if (elem === 'link') {
          tag.href = url
          tag.rel = 'stylesheet'
        } else {
          window.event_semaphore++

          tag.src = url
          tag.async = false
          tag.defer = true
          tag.onload = function () {
            window.event_semaphore--
            log.info('successfully loaded =>', url)
          }
          tag.onerror = function (e: Error) {
            window.event_semaphore--
            log.warn('could not load =>', url, e)
          }
        }
        document.head.appendChild(tag)
      } catch (e) {
        log.error('loading resource => ', e)
      }

      break
    }
    case Port.PERSISTENT: {
      if (event.message === 'store') {
        // todo, needs to be moved back
        // persistent.store(event.section)
        elmSend({
          topic: Port.LOAD,
          section: -1,
          message: null,
        })
      }

      break
    }
    case Port.INIT: {
      let data = event.message

      if (isConnected) {
        self.connector.open(
          data.readme,
          data.version,
          data.section_active,
          data,
        )
      }

      if (data.definition.onload !== '') {
        lia_execute_event({
          code: data.definition.onload,
          delay: 350,
        })
      }

      document.documentElement.lang = data.definition.language

      meta('author', data.definition.author)
      meta('og:description', data.comment)
      meta('og:title', data.str_title)
      meta('og:type', 'website')
      meta('og:url', '')
      meta('og:image', data.definition.logo)

      // store the basic info in the offline-repositories
      if (isConnected) {
        self.connector.storeToIndex(data)
      }

      break
    }
    case Port.INDEX: {
      if (!isConnected) break

      switch (event.message.topic) {
        case 'list': {
          try {
            TTS.cancel()
          } catch (e) {}
          self.connector.getIndex()
          break
        }
        case 'delete': {
          self.connector.deleteFromIndex(event.message.message)
          break
        }
        case 'restore': {
          self.connector.restoreFromIndex(
            event.message.message,
            event.message.section,
          )
          break
        }
        case 'reset': {
          self.connector.reset(event.message.message, event.message.section)
          break
        }
        case 'get': {
          self.connector.getFromIndex(event.message.message)
          break
        }
        default:
          log.error('Command  not found => ', event.message)
      }
      break
    }
    case Port.SHARE: {
      try {
        if (navigator.share) {
          navigator.share(event.message.message)
        }
      } catch (e) {
        log.error('sharing was not possible => ', event.message, e)
      }

      break
    }
    case Port.RESET: {
      self.connector.reset()
      window.location.reload()
      break
    }

    case Port.TRANSLATE: {
      injectGoogleTranslate()
      break
    }
    default:
      log.error('Command not found => ', event)
  }
}

var googleTranslate = false
function injectGoogleTranslate() {
  // inject the google translator
  if (!googleTranslate) {
    let tag = document.createElement('script')
    tag.src =
      '//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit'
    tag.type = 'text/javascript'
    document.head.appendChild(tag)

    window.googleTranslateElementInit = function () {
      new google.translate.TranslateElement(
        {
          pageLanguage: document.documentElement.lang,
          // includedLanguages: 'ar,en,es,jv,ko,pa,pt,ru,zh-CN',
          // layout: google.translate.TranslateElement.InlineLayout.HORIZONTAL,
          autoDisplay: false,
        },
        'google_translate_element',
      )
    }
    googleTranslate = true
  }
}

function changeGoogleStyles() {
  let goog = document.getElementById(':1.container')

  if (goog) {
    goog.style.visibility = 'hidden'
    document.body.style.top = ''
  }
}

export default LiaScript
