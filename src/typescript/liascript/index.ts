// @ts-ignore
import { Elm } from '../../elm/Main.elm'

import log from './log'

import './types/globals'
import Lia from './types/lia.d'

import 'abortcontroller-polyfill/dist/abortcontroller-polyfill-only.js'

import { Connector } from '../connectors/Base/index'

import * as TOOLTIP from '../webcomponents/tooltip/index'

// Services
import Console from './service/Console'
import Database from './service/Database'
import Local from './service/Local'
import { Service as Resource } from './service/Resource'
import Script from './service/Script'
import Share from './service/Share'
import Slide from './service/Slide'
import Swipe from './service/Swipe'
import Sync from './service/Sync'
import * as TTS from './service/TTS'
import Translate from './service/Translate'
import Zip from './service/Zip'
import Torrent from './service/Torrent'
import Nostr from './service/Nostr'

// ----------------------------------------------------------------------------
// GLOBAL INITIALIZATION
import * as GLOBALS from './init'
// TODO: CHECK window.LIA.defaultCourse functionality
GLOBALS.initGlobals()
window.LIA.injectResposivevoice = TTS.inject

if (typeof queueMicrotask !== 'function') {
  window.queueMicrotask = function (callback) {
    Promise.resolve().then(callback)
  }
}

// ----------------------------------------------------------------------------
export class LiaScript {
  private app: any
  public connector: Connector
  public sync?: any

  constructor(
    connector: Connector,
    {
      allowSync = false,
      debug = false,
      courseUrl = null,
      script = null,
      hideURL = false,
      hasShareAPI = undefined,
    }: {
      allowSync?: boolean
      debug?: boolean
      courseUrl?: string | null
      script?: string | null
      hideURL?: boolean
      hasShareAPI?: boolean
    } = {}
  ) {
    window.LIA.debug = debug

    if (hasShareAPI === undefined) {
      hasShareAPI = Share.isSupported()
    }

    this.app = Elm.Main.init({
      //node: elem,
      flags: {
        courseUrl: window.LIA.defaultCourseURL || courseUrl,
        script: script,
        settings: connector.getSettings(),
        seed: Math.round(Math.random() * 10000000),
        screen: {
          width: window.innerWidth,
          height: window.innerHeight,
        },
        hasShareAPI,
        isFullscreen: !!document.fullscreenElement,
        hasIndex: connector.hasIndex(),
        sync: {
          support: Sync.supported,
          enabled: allowSync,
        },
        hideURL: hideURL,
      },
    })

    this.app.ports.copyToClipboard.subscribe((text: string) => {
      try {
        navigator.clipboard.writeText(text)
      } catch (e) {
        console.warn('Failed to copy: ', e.message)
      }
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

    this.initEventSystem(
      document.body,
      this.app.ports.event2js.subscribe,
      sender
    )

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
    TOOLTIP.initTooltip()
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
    Local.init(elmSend, Database)
    TTS.Service.init(elmSend)
    Script.init(elmSend)
    Swipe.init(elem, elmSend)
    Translate.init(elmSend)
    Sync.init(elmSend)
    Zip.init(elmSend)
    Torrent.init(elmSend, Database)
    Nostr.init(elmSend)

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

        case TTS.Service.PORT:
          TTS.Service.handle(event)
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

        case Local.PORT:
          Local.handle(event)
          break

        case Zip.PORT:
          Zip.handle(event)
          break

        case Torrent.PORT:
          Torrent.handle(event)
          break

        case Nostr.PORT:
          Nostr.handle(event)
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
