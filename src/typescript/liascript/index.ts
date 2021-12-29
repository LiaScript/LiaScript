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

import { initTooltip } from '../webcomponents/tooltip/index'

import * as Beaker from '../sync/Beaker/index'
import * as Jitsi from '../sync/Jitsi/index'
import * as Matrix from '../sync/Matrix/index'
import * as PubNub from '../sync/PubNub/index'
import * as GUN from '../sync/Gun/index'

import Console from './service/Console'
import Share from './service/Share'

window.img_Zoom = function (e: MouseEvent | TouchEvent) {
  const target = e.target as HTMLImageElement

  if (target) {
    const zooming = e.currentTarget as HTMLImageElement

    if (zooming) {
      if (target.width < target.naturalWidth) {
        var offsetX = e instanceof MouseEvent ? e.offsetX : e.touches[0].pageX
        var offsetY = e instanceof MouseEvent ? e.offsetY : e.touches[0].pageY
        var x = (offsetX / zooming.offsetWidth) * 100
        var y = (offsetY / zooming.offsetHeight) * 100
        zooming.style.backgroundPosition = x + '% ' + y + '%'
        zooming.style.cursor = 'zoom-in'
      } else {
        zooming.style.cursor = ''
      }
    }
  }
}

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
  self?: LiaScript
) {
  switch (event.track[0][0]) {
    case 'scrollTo':
      scrollIntoView(event.message, 350)
      break
    case 'persistent':
      // Todo
      // setTimeout((e) => { persistent.load(event.section) }, 10)
      break
    case 'execute':
      lia_execute_event(event.message, elmSend, event.track[0][1])
      break
    case 'speak': {
      let msg: Lia.Event = {
        reply: false,
        track: [
          [Port.SETTINGS, -1],
          ['speak', -1],
        ],
        service: null,
        message: 'stop',
      }

      if (section >= 0) {
        msg = {
          reply: false,
          track: [
            [Port.EFFECT, section],
            ['speak', event.track[0][1]],
          ],
          service: null,
          message: 'stop',
        }
      }

      try {
        if (event.message === 'cancel') {
          TTS.cancel()
          msg.message = 'stop'
          elmSend(msg)
        } else if (event.message === 'repeat') {
          event.message = [ttsBackup[0], ttsBackup[1], 'true']
          handleEffects(event, elmSend)
        } else if (
          typeof event.message === 'string' &&
          event.message.startsWith('lia-tts-')
        ) {
          setTimeout(function () {
            let element = document.getElementsByClassName(event.message)
            let voice = element[0].getAttribute('data-voice') || 'default'

            let text = ''

            for (let i = 0; i < element.length; i++) {
              text +=
                (element[i] as HTMLElement).innerText || element[i].textContent
            }

            // This is used to clean up effect numbers, which are marked by a \b
            text = text.replace(/\\u001a\\d+\\u001a/g, '').trim()

            if (text !== '' && element[0]) {
              TTS.speak(
                text,
                voice,
                function () {
                  msg.track[0][0] = Port.SETTINGS
                  msg.message = 'start'

                  elmSend(msg)
                },
                function () {
                  msg.track[0][0] = Port.SETTINGS
                  msg.message = 'stop'
                  elmSend(msg)
                },
                function (e: any) {
                  msg.message = e.toString()
                  elmSend(msg)
                }
              )
            }
          }, 500)
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
                msg.message = 'start'
                elmSend(msg)
              },
              function () {
                msg.message = 'stop'
                elmSend(msg)
              },
              function (e: any) {
                msg.message = e.toString()
                elmSend(msg)
              }
            )
          }
        }
      } catch (e: any) {
        msg.message = e.toString()
        elmSend(msg)
      }
      break
    }
    case 'sub': {
      if (self != undefined && event.track.length != 0) {
        const newSend = function (subEvent: Lia.Event) {
          elmSend({
            reply: false,
            track: [
              [Port.EFFECT, section],
              ['sub', event.track[0][1]],
            ],
            service: null,
            message: subEvent,
          })
        }

        process(false, self, newSend, event)
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
  public sync?: any

  constructor(
    elem: HTMLElement,
    connector: Connector,
    allowSync: boolean = false,
    debug: boolean = false,
    courseUrl: string | null = null,
    script: string | null = null
  ) {
    if (debug) window.debug__ = true

    eventHandler = new LiaEvents()

    this.app = Elm.Main.init({
      //node: elem,
      flags: {
        courseUrl: window.liaDefaultCourse || courseUrl,
        script: script,
        settings: connector.getSettings(),
        screen: {
          width: window.innerWidth,
          height: window.innerHeight,
        },
        hasShareAPI: !!navigator.share,
        hasIndex: connector.hasIndex(),
        syncSupport: allowSync
          ? [
              // beaker is only supported within the beaker-browser
              Beaker.isSupported() ? 'beaker' : '',
              // remove these strings if you want to enable or disable certain sync support
              'gun',
              'jitsi',
              'matrix',
              'pubnub',
            ]
          : [],
      },
    })

    const sendTo = this.app.ports.event2elm.send

    const sender = function (msg: Lia.Event) {
      log.info(`LIA <<< (${msg.track}) :`, msg.message)
      sendTo(msg)
    }

    this.connector = connector
    this.connector.connect(sender)
    this.initEventSystem(elem, this.app.ports.event2js.subscribe, sender)

    liaStorage = this.connector.storage()

    window.playback = function (event) {
      const id = event.track[0][1]
      event.track = event.track.slice(1)
      handleEffects(event, sender, id)
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

    initTooltip()
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
      this.app.ports.media.send([url, null, null])
    }
  }

  initNavigation(elem: HTMLElement, elmSend: Lia.Send) {
    Swipe.detect(elem, function (swipeDir) {
      if (document.getElementsByClassName('lia-modal').length === 0) {
        elmSend({
          reply: false,
          track: [[Port.SWIPE, -1]],
          service: null,
          message: swipeDir,
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
                reply: false,
                track: [[Port.SWIPE, -1]],
                service: null,
                message: Swipe.Dir.left,
              })
            }
            break
          }
          case 'ArrowLeft': {
            if (document.getElementsByClassName('lia-modal').length === 0) {
              elmSend({
                reply: false,
                track: [[Port.SWIPE, -1]],
                service: null,
                message: Swipe.Dir.right,
              })
            }
            break
          }
        }
      },
      false
    )
  }

  reset() {
    this.app.ports.event2elm.send({
      track: [
        {
          topic: Port.RESET,
          id: null,
        },
      ],
      message: null,
    })
  }

  initSynchronization() {
    let self = this
    let publish = this.app.ports.syncIn.send

    this.app.ports.syncOut.subscribe(function (event: Lia.Event) {
      switch (event.topic) {
        case 'connect': {
          if (!self.sync) delete self.sync

          self.sync = new Sync()

          self.sync.connect(
            publish,
            event.message.course,
            event.message.room,
            event.message.username,
            event.message.password
          )

          break
        }
      }
    })
  }

  initEventSystem(
    elem: HTMLElement,
    jsSubscribe: (fn: (_: Lia.Event) => void) => void,
    elmSend: Lia.Send
  ) {
    log.info('initEventSystem')

    let self = this

    this.initNavigation(elem, elmSend)

    var observer = new MutationObserver(function (mutations) {
      mutations.forEach(function (mutation) {
        changeGoogleStyles()

        elmSend({
          reply: false,
          track: [['lang', -1]],
          service: null,
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
  event: Lia.Event
) {
  log.info(`LIA >>> (${JSON.stringify(event.track)})`, event.message)

  if (event.service) {
    switch (event.service) {
      case Console.PORT:
        Console.handle(event)
        break

      case Share.PORT:
        Share.handle(event)
        break

      default:
        console.warn('Unknown Service => ', event)
    }
  } else
    switch (event.track[0][0]) {
      case Port.SLIDE: {
        self.connector.slide(event.track[0][1])

        const sec = document.getElementsByTagName('main')[0]
        if (sec) {
          sec.scrollTo(0, 0)

          if (sec.children.length > 0) (sec.children[0] as HTMLElement).focus()
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
        self.connector.load(
          // generate the return message ...
          // the previous topic is mapped with the current message to match the return path
          {
            reply: false,
            track: [[event.message, event.track[0][1]]],
            service: null,
            message: event.message,
          }
        )
        break
      }
      case Port.CODE: {
        switch (event.track[1][0]) {
          case 'eval':
            lia_eval_event(elmSend, eventHandler, event)
            break
          case 'store':
            if (isConnected) {
              //event.track = event.track.slice(1)
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
              const slide = event.track[0][1]
              event.track = event.track.slice(1)
              self.connector.update(event, slide)
            }
          }
        }
        break
      }
      case Port.QUIZ: {
        if (isConnected && event.track[1][0] === 'store') {
          // event.track.slice(1)
          self.connector.store(event)
        } else if (event.track[1][0] === 'eval') {
          lia_eval_event(elmSend, eventHandler, event)
        }

        break
      }
      case Port.SURVEY: {
        if (isConnected && event.track[1][0] === 'store') {
          // event.track.slice(1)
          self.connector.store(event)
        } else if (event.track[1][0] === 'eval') {
          lia_eval_event(elmSend, eventHandler, event)
        }
        break
      }
      case Port.TASK: {
        if (isConnected && event.track[1][0] === 'store') {
          // event.track.slice(1)
          self.connector.store(event)
        } else if (event.track[1][0] === 'eval') {
          lia_eval_event(elmSend, eventHandler, event)
        }
        break
      }
      case Port.EFFECT: {
        const id = event.track[0][1]
        event.track = event.track.slice(1)
        handleEffects(event, elmSend, id, self)
        break
      }

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
      case Port.SYNC: {
        switch (event.track[1][0]) {
          case 'sync': {
            // all sync relevant messages
            switch (event.track[2][0]) {
              case 'connect': {
                if (!self.sync) delete self.sync

                switch (event.message.backend) {
                  case 'beaker': {
                    self.sync = new Beaker.Sync(elmSend)
                    self.sync.connect(event.message)

                    break
                  }
                  case 'gun': {
                    self.sync = new GUN.Sync(elmSend)
                    self.sync.connect(event.message)

                    break
                  }
                  case 'jitsi': {
                    self.sync = new Jitsi.Sync(elmSend)
                    self.sync.connect(event.message)

                    break
                  }
                  case 'matrix': {
                    self.sync = new Matrix.Sync(elmSend)
                    self.sync.connect(event.message)

                    break
                  }

                  case 'pubnub': {
                    self.sync = new PubNub.Sync(elmSend)
                    self.sync.connect(event.message)

                    break
                  }
                  default: {
                    log.error('could not load =>', event.message)
                  }
                }

                break
              }
              case 'disconnect': {
                if (self.sync) self.sync.disconnect()
                break
              }
              default: {
                if (self.sync) self.sync.publish(event)
              }
            }
            break
          }

          default: {
            if (self.sync) self.sync.publish(event)
          }
        }
        break
      }
      case Port.PERSISTENT: {
        if (event.message === 'store') {
          // todo, needs to be moved back
          // persistent.store(event.section)
          elmSend({
            reply: false,
            track: [[Port.LOAD, -1]],
            service: null,
            message: null,
          })
        }

        break
      }
      case Port.INIT: {
        let data = event.message

        let isPersistent = true

        try {
          isPersistent = !(
            data.definition.macro['persistent'].trim().toLowerCase() === 'false'
          )
        } catch (e) {}

        if (isConnected && isPersistent) {
          self.connector.open(
            data.readme,
            data.version,
            data.section_active,
            data
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
        if (isConnected && isPersistent) {
          self.connector.storeToIndex(data)
        }

        break
      }
      case Port.INDEX: {
        if (!isConnected) break

        switch (event.track[1][0]) {
          case 'list': {
            try {
              TTS.cancel()
            } catch (e) {}
            self.connector.getIndex()
            break
          }
          case 'delete': {
            self.connector.deleteFromIndex(event.message)
            break
          }
          case 'restore': {
            self.connector.restoreFromIndex(event.message, event.track[1][1])
            break
          }
          case 'reset': {
            self.connector.reset(event.message, event.track[1][1])
            break
          }
          case 'get': {
            self.connector.getFromIndex(event.message)
            break
          }
          default:
            log.error('Command not found => ', event)
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
      // @ts-ignore: will be injected by google
      new google.translate.TranslateElement(
        {
          pageLanguage: document.documentElement.lang,
          // includedLanguages: 'ar,en,es,jv,ko,pa,pt,ru,zh-CN',
          // layout: google.translate.TranslateElement.InlineLayout.HORIZONTAL,
          autoDisplay: false,
        },
        'google_translate_element'
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
