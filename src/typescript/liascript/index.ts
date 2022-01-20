// @ts-ignore
import { Elm } from '../../elm/Main.elm'
import { LiaEvents, lia_execute_event, lia_eval_event } from './events'
// import persistent from './persistent.ts'
import log from './log'

import './types/globals'
import Lia from './types/lia.d'
import Port from './types/ports'
import { Connector } from '../connectors/Base/index'

import { initTooltip } from '../webcomponents/tooltip/index'

// Services
import Console from './service/Console'
import Database from './service/Database'
import { Service as Resource } from './service/Resource'
import Share from './service/Share'
import Slide from './service/Slide'
import Swipe from './service/Swipe'
import Sync from './service/Sync'
import TTS from './service/TTS'
import Translate from './service/Translate'

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

function handleEffects(
  event: Lia.Event,
  elmSend: Lia.Send,
  section: number = -1,
  self?: LiaScript
) {
  switch (event.track[0][0]) {
    case 'persistent':
      // Todo
      // setTimeout((e) => { persistent.load(event.section) }, 10)
      break
    case 'execute':
      lia_execute_event(event.message, elmSend, event.track[0][1])
      break
    /*case 'speak': {
      let msg: Lia.Event = {
        reply: true,
        track: [
          [Port.SETTINGS, -1],
          ['speak', -1],
        ],
        service: null,
        message: 'stop',
      }

      if (section >= 0) {
        msg = {
          reply: true,
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
    */
    case 'sub': {
      if (self != undefined && event.track.length != 0) {
        const newSend = function (subEvent: Lia.Event) {
          elmSend({
            reply: true,
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

// -----------------------------------------------------------------------------

var eventHandler: LiaEvents
var liaStorage: any

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
        hasShareAPI: Share.isSupported(),
        hasIndex: connector.hasIndex(),
        syncSupport: Sync.supported(allowSync),
      },
    })

    const sendTo = this.app.ports.event2elm.send

    const sender = function (msg: Lia.Event) {
      if (msg.reply) {
        log.info(`LIA <<< (${msg.track}) :`, msg.message)
        sendTo(msg)
      }
    }

    this.connector = connector

    this.initEventSystem(elem, this.app.ports.event2js.subscribe, sender)

    liaStorage = this.connector.storage()

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

  initEventSystem(
    elem: HTMLElement,
    jsSubscribe: (fn: (_: Lia.Event) => void) => void,
    elmSend: Lia.Send
  ) {
    log.info('initEventSystem')

    let self = this

    Database.init(elmSend, this.connector)
    TTS.init(elmSend)
    Swipe.init(elem, elmSend)
    Translate.init(elmSend)
    Sync.init(elmSend)

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
  log.info(
    `LIA >>> (${JSON.stringify(event.track)})`,
    event.service,
    event.message
  )

  switch (event.service) {
    case Database.PORT:
      Database.handle(event)
      break

    case Slide.PORT:
      if (event.message.param.slide) {
        // store the current slide number within the backend
        self.connector.slide(event.message.param.slide)
      }
      Slide.handle(event)
      break

    case TTS.PORT:
      TTS.handle(event)
      break

    case Console.PORT:
      Console.handle(event)
      break

    case Sync.PORT:
      Sync.handle(event)
      break

    case Share.PORT:
      Share.handle(event)
      break

    case Resource.PORT:
      Resource.handle(event)
      break

    case Translate.PORT:
      Translate.handle(event)
      break

    default:
      console.warn('Unknown Service => ', event)
  }

  /*else
    switch (event.track[0][0]) {
      
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

      case Port.PERSISTENT: {
        if (event.message === 'store') {
          // todo, needs to be moved back
          // persistent.store(event.section)
          elmSend({
            reply: true,
            track: [[Port.LOAD, -1]],
            service: null,
            message: null,
          })
        }

        break
      }

      case Port.RESET: {
        self.connector.reset()
        window.location.reload()
        break
      }
    }
    */
}

export default LiaScript
