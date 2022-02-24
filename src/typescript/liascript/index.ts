// @ts-ignore
import { Elm } from '../../elm/Main.elm'

import log from './log'

import './types/globals'
import Lia from './types/lia.d'

import { Connector } from '../connectors/Base/index'

import { initTooltip } from '../webcomponents/tooltip/index'

// Services
import Console from './service/Console'
import Database from './service/Database'
import { Service as Resource } from './service/Resource'
import Script from './service/Script'
import Share from './service/Share'
import Slide from './service/Slide'
import Swipe from './service/Swipe'
import Sync from './service/Sync'
import { inject, Service as TTS } from './service/TTS'
import Translate from './service/Translate'

// ----------------------------------------------------------------------------
// GLOBAL INITIALIZATION
import { initGlobals } from './init'
// TODO: CHECK window.LIA.defaultCourse functionality
initGlobals()
window.LIA.injectResposivevoice = inject

// ----------------------------------------------------------------------------
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
    window.LIA.debug = debug

    this.app = Elm.Main.init({
      //node: elem,
      flags: {
        courseUrl: window.LIA.defaultCourseURL || courseUrl,
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
        if (window.LIA.debug) {
          log.info(`LIA <<< (${msg.track}) :`, msg.message)
        }
        sendTo(msg)
      }
    }

    window.LIA.send = sender

    this.connector = connector

    this.initEventSystem(elem, this.app.ports.event2js.subscribe, sender)

    let self = this

    window.LIA.img.load = (src: string, width: number, height: number) => {
      self.app.ports.media.send([src, width, height])
    }
    window.LIA.img.click = (url: string) => {
      // abuse media port to open modals
      if (document.getElementsByClassName('lia-modal').length === 0) {
        self.app.ports.media.send([url, null, null])
      }
    }
    window.LIA.showFootnote = (key: string) => {
      self.app.ports.footnote.send(key)
    }
    window.LIA.goto = (slide: number) => {
      sender({
        reply: true,
        track: [['goto', -1]],
        service: '',
        message: {
          cmd: 'goto',
          param: slide,
        },
      })
    }

    window.LIA.gotoNext = () => {
      sender({
        reply: true,
        track: [['goto', -1]],
        service: '',
        message: {
          cmd: 'next',
          param: null,
        },
      })
    }

    window.LIA.gotoPrevious = () => {
      sender({
        reply: true,
        track: [['goto', -1]],
        service: '',
        message: {
          cmd: 'prev',
          param: null,
        },
      })
    }

    // Attach a tooltip-div to the end of the DOM
    initTooltip()
  }

  reset() {
    this.app.ports.event2elm.send({
      track: [
        {
          topic: 'reset',
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

    Database.init(elmSend, this.connector)
    TTS.init(elmSend)
    Script.init(elmSend)
    Swipe.init(elem, elmSend)
    Translate.init(elmSend)
    Sync.init(elmSend)

    let connector = this.connector
    jsSubscribe((event: Lia.Event) => {
      if (window.LIA.debug)
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
            connector.slide(event.message.param.slide)
          }
          Slide.handle(event)
          break

        case TTS.PORT:
          TTS.handle(event)
          break

        case Script.PORT:
          Script.handle(event)
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
    })
  }
}

/* case Port.RESET: {
     self.connector.reset()
     window.location.reload()
     break
   }
*/

export default LiaScript
