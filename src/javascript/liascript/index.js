'use strict'

import { Elm } from '../../elm/Main.elm'
import { LiaDB } from './database'
import { LiaStorage } from './storage'
import { LiaEvents, lia_execute_event, lia_eval_event } from './events'
import { SETTINGS, initSettings } from './settings'
import { persistent } from './persistent'
import { lia } from './logger'

function isInViewport (elem) {
    var bounding = elem.getBoundingClientRect();
    return (
        bounding.top >= 20 &&
        bounding.left >= 0 &&
        bounding.bottom <= (window.innerHeight -20 || document.documentElement.clientHeight -20) &&
        bounding.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
};


function scrollIntoView (id, delay) {
  setTimeout(function (e) {
    try {
      document.getElementById(id).scrollIntoView({ behavior: 'smooth' })
    } catch (e) {}
  }, delay)
};

function handleEffects (event, elmSend) {
  switch (event.topic) {
    case 'scrollTo':
      scrollIntoView(event.message, 350)
      break
    case 'persistent':
      setTimeout((e) => { persistent.load(event.section) }, 10)
      break
    case 'execute':
      lia_execute_event(event.message)
      break
    case 'speak' : {
      let msg = {
        topic: 'settings',
        section: -1,
        message: {
          topic: 'speak',
          section: -1,
          message: 'stop'
        }
      }

      try {
        if (event.message === 'cancel') {
          responsiveVoice.cancel()
          msg.message.message = 'stop'
          elmSend(msg)
        } else if (event.message === 'repeat') {
          event.message = [ttsBackup[0], ttsBackup[1], 'true']
          handleEffects(event, elmSend)
        } else {
          ttsBackup = event.message
          if (event.message[2] === 'true') {
            responsiveVoice.speak(
              event.message[1],
              event.message[0],
              { onstart: e => {
                msg.message.message = 'start'
                elmSend(msg)
              },
              onend: e => {
                msg.message.message = 'stop'
                elmSend(msg)
              },
              onerror: e => {
                msg.message.message = e.toString()
                elmSend(msg)
              } })
          }
        }
      } catch (e) {
        msg.message.message = e.toString()
        elmSend(msg)
      }
      break
    }
    default:
      lia.warn('effect missed', event)
  }
};

function meta (name, content) {
  if (content !== '') {
    let meta = document.createElement('meta')
    meta.name = name
    meta.content = content
    document.getElementsByTagName('head')[0].appendChild(meta)
  }
}
// -----------------------------------------------------------------------------

var eventHandler = undefined
var liaStorage = undefined
var ttsBackup = undefined

class LiaScript {
  constructor (elem, debug = false, course = null, script = null, url = '', slide = 0, spa = true, channel = null) {
    if (debug) window.debug__ = true

    eventHandler = new LiaEvents()

    let settings = localStorage.getItem(SETTINGS)

    this.app = Elm.Main.init({
      node: elem,
      flags: {
        course: course,
        script: script,
        debug: debug,
        spa: spa,
        settings: settings ? JSON.parse(settings) : settings,
        screen: {
          width: window.innerWidth,
          height: window.innerHeight
        }
      }
    })

    console.log(this.app.ports)

    let sendTo = this.app.ports.event2elm.send

    let sender = function (msg) {
      lia.log('event2elm => ', msg)
      sendTo(msg)
    }

    this.initChannel(channel, sender)
    this.initDB(channel, sender)
    this.initEventSystem(this.app.ports.event2js.subscribe, sender)

    liaStorage = new LiaStorage(channel)
  }

  initDB (channel, sender) {
    this.db = new LiaDB(sender, channel)
  }

  initChannel (channel, send) {
    if (!channel) return

    this.channel = channel
    channel.on('service', e => { eventHandler.dispatch(e.event_id, e.message) })

    channel.join()
      .receive('ok', (e) => { lia.log('joined to channel', e) }) // initSettings(send, e); })
      .receive('error', e => { lia.error('channel join => ', e) })
  }

  reset () {
    this.app.ports.event2elm.send({
      topic: 'reset',
      section: -1,
      message: null
    })
  }

  initEventSystem (jsSubscribe, elmSend) {
    lia.log('initEventSystem')

    let self = this

    jsSubscribe(function (event) {
      lia.log('elm2js => ', event)

      switch (event.topic) {
        case 'slide': {
          // if(self.channel)
          //    self.channel.push('lia', { slide: event.section + 1 });

          let sec = document.getElementsByTagName('section')[0]
          if (sec) {
            sec.scrollTo(0, 0)
          }


          let elem = document.getElementById("focusedToc");
          if (elem) {
            if (!isInViewport(elem)) {
              elem.scrollIntoView({ behavior: 'smooth' })
            }
          }

          break
        }
        case 'load': {
          self.db.load({
            topic: event.message,
            section: event.section,
            message: null })
          break
        }
        case 'code' : {
          switch (event.message.topic) {
            case 'eval':
              lia_eval_event(elmSend, self.channel, eventHandler, event)
              break
            case 'store':
              event.message = event.message.message
              self.db.store(event)
              break
            case 'input':
              eventHandler.dispatch_input(event)
              break
            case 'stop':
              eventHandler.dispatch_input(event)
              break
            default: {
              self.db.update(event.message, event.section)
            }
          }
          break
        }
        case 'quiz' : {
          if (event.message.topic === 'store') {
            event.message = event.message.message
            self.db.store(event)
          } else if (event.message.topic === 'eval') {
            lia_eval_event(elmSend, self.channel, eventHandler, event)
          }

          break
        }
        case 'survey' : {
          if (event.message.topic === 'store') {
            event.message = event.message.message
            self.db.store(event)
          } else if (event.message.topic === 'eval') {
            lia_eval_event(elmSend, self.channel, eventHandler, event)
          }
          break
        }
        case 'effect' :
          handleEffects(event.message, elmSend)
          break
        case SETTINGS: {
          // if (self.channel) {
          //  self.channel.push('lia', {settings: event.message});
          // } else {
          localStorage.setItem(SETTINGS, JSON.stringify(event.message))
          // }
          break
        }
        case 'resource' : {
          let elem = event.message[0]
          let url = event.message[1]

          lia.log('loading resource => ', elem, ':', url)

          try {
            var tag = document.createElement(elem)
            if (elem === 'link') {
              tag.href = url
              tag.rel = 'stylesheet'
            } else {
              tag.src = url
              tag.async = false
            }
            document.head.appendChild(tag)
          } catch (e) {
            lia.error('loading resource => ', e.msg)
          }
          break
        }
        case 'persistent': {
          if (event.message === 'store') {
            persistent.store(event.section)
            elmSend({ topic: 'load', section: -1, message: null })
          }

          break
        }
        case 'init': {
          let data = event.message

          self.db.open(
            data.readme,
            data.version,
            { topic: 'code',
              section: data.section_active,
              message: {
                topic: 'restore',
                section: -1,
                message: null }
          })

          if (onload !== '') {
            lia_execute_event({ code: onload, delay: 350 })
          }

          meta('author', data.definition.author)
          meta('og:description', data.comment)
          meta('og:title', data.str_title)
          meta('og:type', 'website')
          meta('og:url', '')
          meta('og:image', data.definition.logo)

          // store the basic info in the offline-repositories
          self.db.storeIndex(data)

          break
        }
        case 'index' : {
          switch (event.message.topic) {
            case 'list': {
              self.db.listIndex()
              break
            }
            case 'delete' : {
              self.db.deleteIndex(event.message.message)
              break
            }
            case 'restore' : {
              self.db.restore(event.message.message, event.message.section)
              break
            }
            case 'get' : {
              self.db.getIndex(event.message.message)
              break
            }

            default:
              lia.error('Command  not found => ', event.message)
          }
          break
        }
        case 'reset': {
          self.db.del()
          if (!self.channel) {
            initSettings(elmSend, null, true)
          }
          window.location.reload()
          break
        }
        default:
          lia.error('Command not found => ', event)
      }
    })
  }
};

export { LiaScript };
