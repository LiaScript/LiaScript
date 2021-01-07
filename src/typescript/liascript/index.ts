import { Elm } from '../../elm/Main.elm'
import {
  LiaEvents,
  lia_execute_event,
  lia_eval_event
} from './events'
// import persistent from './persistent.ts'
import log from './log'
import swipedetect from './swipe'

import './types/globals'
import './types/responsiveVoice'
import Lia from './types/lia.d'
import Port from './types/ports'

import { Connector } from '../connectors/Base/index'

function isInViewport(elem: HTMLElement) {
  const bounding = elem.getBoundingClientRect()
  return (
    bounding.top >= 20 &&
    bounding.left >= 0 &&
    bounding.bottom <= (window.innerHeight - 20 || document.documentElement.clientHeight - 20) &&
    bounding.right <= (window.innerWidth || document.documentElement.clientWidth)
  )
};

function scrollIntoView(id: string, delay: number) {
  setTimeout(function() {
    const elem = document.getElementById(id)

    if (elem) {
      elem.scrollIntoView({ behavior: 'smooth' })
    }
  }, delay)
};

function handleEffects(event: Lia.Event, elmSend: Lia.Send, section: number = -1, self?: LiaScript) {
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
          message: 'stop'
        }
      }

      if (section >= 0) {
        msg = {
          topic: Port.EFFECT,
          section: section,
          message: {
            topic: 'speak',
            section: event.section,
            message: 'stop'
          }
        }
      }

      try {
        if (event.message === 'cancel') {
          window.responsiveVoice.cancel()
          msg.message.message = 'stop'
          elmSend(msg)
        } else if (event.message === 'repeat') {
          event.message = [ttsBackup[0], ttsBackup[1], 'true']
          handleEffects(event, elmSend)
        } else if (firstSpeak) {
          // this is a hack to deal with the delay in responsivevoice
          firstSpeak = false
          setTimeout(function() {
            handleEffects(event, elmSend)
          }, 1000)
        } else {
          ttsBackup = event.message
          if (event.message[2] === 'true') {
            window.responsiveVoice.speak(
              event.message[1],
              event.message[0], {
                onstart: () => {
                  msg.message.message = 'start'

                  elmSend(msg)
                },
                onend: () => {
                  msg.message.message = 'stop'
                  elmSend(msg)
                },
                onerror: (e: any) => {
                  msg.message.message = e.toString()
                  elmSend(msg)
                }
              })
          }
        }
      } catch (e) {
        msg.message.message = e.toString()
        elmSend(msg)
      }
      break
    }
    case "sub": {
      if ( self != undefined && event.message != null ) {
        const newSend = function (subEvent: Lia.Event) {
          elmSend({
            topic: Port.EFFECT,
            section: section,
            message: {
              topic: "sub",
              section: event.section,
              message: subEvent
            }
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
};

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
    course: string | null = null,
    script: string | null = null,
    url: string = '',
    slide: number = 0,
    spa: boolean = true
  ) {
    if (debug) window.debug__ = true

    eventHandler = new LiaEvents()

    this.app = Elm.Main.init({
      node: elem,
      flags: {
        course: course,
        script: script,
        debug: debug,
        spa: spa,
        settings: connector.getSettings(),
        screen: {
          width: window.innerWidth,
          height: window.innerHeight
        },
        share: !!navigator.share,
        hasIndex: connector.hasIndex()
      }
    })

    const sendTo = this.app.ports.event2elm.send

    const sender = function(msg: Lia.Event) {
      log.info(`LIA <<< (${msg.topic}:${msg.section})`, msg.message)
      sendTo(msg)
    }

    this.connector = connector
    this.connector.connect(sender)
    this.initEventSystem(elem, this.app.ports.event2js.subscribe, sender)

    liaStorage = this.connector.storage()

    window.playback = function(event) {
      handleEffects(event.message, sender, event.section)
    }

    window.showFootnote = this.app.ports.footnote.send

    setTimeout(function() {
      firstSpeak = false
    }, 1000)
  }

  reset() {
    this.app.ports.event2elm.send({
      topic: Port.RESET,
      section: -1,
      message: null
    })
  }

  initEventSystem(elem: HTMLElement, jsSubscribe: (fn: (_: Lia.Event) => void) => void, elmSend: Lia.Send) {
    log.info('initEventSystem')

    let self = this

    swipedetect(elem, function(swipedir) {
      elmSend({
        topic: Port.SWIPE,
        section: -1,
        message: swipedir
      })
    })

    jsSubscribe((event: Lia.Event) => { process(true, self, elmSend, event) })
  }
};


function process(isConnected: boolean, self:LiaScript, elmSend: Lia.Send, event: Lia.Event) {
  log.info(`LIA >>> (${event.topic}:${event.section})`, event.message)

  switch (event.topic) {
    case Port.SLIDE: {
      self.connector.slide(event.section)

      const sec = document.getElementsByTagName('section')[0]
      if (sec) {
        sec.scrollTo(0, 0)
      }

      const elem = document.getElementById('focusedToc')
      if (elem) {
        if (!isInViewport(elem)) {
          elem.scrollIntoView({
            behavior: 'smooth'
          })
        }
      }

      break
    }
    case Port.LOAD: {
      self.connector.load({
        topic: event.message,
        section: event.section,
        message: null
      })
      break
    }
    case Port.CODE: {
      switch (event.message.topic) {
        case 'eval':
          lia_eval_event(elmSend, eventHandler, event)
          break
        case 'store':
          if( isConnected ) {
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
          if( isConnected ) {
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
    case Port.EFFECT:
      handleEffects(event.message, elmSend, event.section, self)
      break
    case Port.SETTINGS: {
      // if (self.channel) {
      //  self.channel.push('lia', {settings: event.message});
      // } else {

      try {
        const conf = self.connector.getSettings()
        if (conf?.table_of_contents !== event.message.table_of_contents) {
          setTimeout(function() {
            window.dispatchEvent(new Event('resize'))
          }, 200)
        }
      } catch (e) { }

      if( isConnected ) {
        self.connector.setSettings(event.message)
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
          tag.onload = function() {
            window.event_semaphore--
            log.info('successfully loaded =>', url)
          }
          tag.onerror = function(e: Error) {
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
          message: null
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
          data
        )
      }

      if (data.definition.onload !== '') {
        lia_execute_event({
          code: data.definition.onload,
          delay: 350
        })
      }

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
            window.responsiveVoice.cancel()
          } catch (e) { }
          self.connector.getIndex()
          break
        }
        case 'delete': {
          self.connector.deleteFromIndex(event.message.message)
          break
        }
        case 'restore': {
          self.connector.restoreFromIndex(event.message.message, event.message.section)
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
    default:
      log.error('Command not found => ', event)
  }
}


export default LiaScript
