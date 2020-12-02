import {
  Elm
} from '../../elm/Main.elm'
import {
  LiaEvents,
  lia_execute_event,
  lia_eval_event
} from './events'
import {
  persistent
} from './persistent'
import {
  lia
} from './logger'
import {
  swipedetect
} from './swipe'

function isInViewport (elem) {
  const bounding = elem.getBoundingClientRect()
  return (
    bounding.top >= 20 &&
    bounding.left >= 0 &&
    bounding.bottom <= (window.innerHeight - 20 || document.documentElement.clientHeight - 20) &&
    bounding.right <= (window.innerWidth || document.documentElement.clientWidth)
  )
};

function scrollIntoView (id, delay) {
  setTimeout(function () {
    try {
      document.getElementById(id).scrollIntoView({
        behavior: 'smooth'
      })
    } catch (e) {}
  }, delay)
};

function handleEffects (event, elmSend, section) {
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
        topic: 'settings',
        section: -1,
        message: {
          topic: 'speak',
          section: -1,
          message: 'stop'
        }
      }

      if (section >= 0) {
        msg = {
          topic: 'effect',
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
          responsiveVoice.cancel()
          msg.message.message = 'stop'
          elmSend(msg)
        } else if (event.message === 'repeat') {
          event.message = [ttsBackup[0], ttsBackup[1], 'true']
          handleEffects(event, elmSend)
        // } else if (firstSpeak) {
          // // this is a hack to deal with the delay in responsivevoice
          // firstSpeak = false;
          // setTimeout(function() {
          //   handleEffects (event, elmSend)
          // }, 1000)
        } else {
          ttsBackup = event.message
          if (event.message[2] === 'true') {
            responsiveVoice.speak(
              event.message[1],
              event.message[0], {
                onstart: (e) => {
                  msg.message.message = 'start'

                  elmSend(msg)
                },
                onend: (e) => {
                  msg.message.message = 'stop'
                  elmSend(msg)
                },
                onerror: (e) => {
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

var eventHandler
var liaStorage
var ttsBackup
var firstSpeak = true
var firstLoad = true

class LiaScript {
  constructor (elem, connector, debug = false, course = null, script = null, url = '', slide = 0, spa = true) {
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

    const sender = function (msg) {
      lia.log('event2elm => ', msg)
      sendTo(msg)
    }

    this.connector = connector
    this.connector.connect(sender)
    this.initEventSystem(elem, this.app.ports.event2js.subscribe, sender)

    liaStorage = this.connector.storage()

    window.playback = function (event) {
      handleEffects(event.message, sender, event.section)
    }

    setTimeout(function () {
      firstSpeak = false
    }, 1000)
  }

  footnote(key) {
      this.app.ports.footnote.send(key);
  }

  goto(line) {
      this.app.ports.event2elm.send({topic: "goto", section: line, message: null});
  }

  jit(code) {
      // port to jit compiler
      this.app.ports.jit.send(code)
  }

  reset() {
      this.app.ports.event2elm.send({ topic: "reset", section: -1, message: null});
  }

  initEventSystem(elem, jsSubscribe, elmSend) {
      lia.log("initEventSystem");
    let self = this

    swipedetect(elem, function (swipedir) {
      elmSend({
        topic: 'swipe',
        section: -1,
        message: swipedir
      })
    })

    jsSubscribe(function (event) {
      lia.log('elm2js => ', event)

      switch (event.topic) {
        case 'slide': {
          self.connector.slide(event.section)

          /*
          let sec = document.getElementsByTagName('section')[0]
          if (sec) {
            sec.scrollTo(0, 0)
          }
          */

          let elem = document.getElementById('focusedToc')
          if (elem) {
            if (!isInViewport(elem)) {
              elem.scrollIntoView({
                behavior: 'smooth'
              })
            }
          }

          break
        }
        case 'load': {
          self.connector.load({
            topic: event.message,
            section: event.section,
            message: null
          })
          break
        }
        case 'code': {
          switch (event.message.topic) {
            case 'eval':
              lia_eval_event(elmSend, eventHandler, event)
              break
            case 'store':
              event.message = event.message.message
              self.connector.store(event)
              break
            case 'input':
              eventHandler.dispatch_input(event)
              break
            case 'stop':
              eventHandler.dispatch_input(event)
              break
            default: {
              self.connector.update(event.message, event.section)
            }
          }
          break
        }
        case 'quiz': {
          if (event.message.topic === 'store') {
            event.message = event.message.message
            self.connector.store(event)
          } else if (event.message.topic === 'eval') {
            lia_eval_event(elmSend, eventHandler, event)
          }

          break
        }
        case 'survey': {
          if (event.message.topic === 'store') {
            event.message = event.message.message
            self.connector.store(event)
          } else if (event.message.topic === 'eval') {
            lia_eval_event(elmSend, eventHandler, event)
          }
          break
        }
        case 'effect':
          handleEffects(event.message, elmSend, event.section)
          break
        case 'settings': {
          // if (self.channel) {
          //  self.channel.push('lia', {settings: event.message});
          // } else {

          try {
            let conf = self.connector.getSettings()
            if (conf.table_of_contents !== event.message.table_of_contents) {
              setTimeout(function () {
                window.dispatchEvent(new Event('resize'))
              }, 200)
            }
          } catch (e) {}

          self.connector.setSettings(event.message)

          break
        }
        case 'resource': {
          let elem = event.message[0]
          let url = event.message[1]

          lia.log('loading resource => ', elem, ':', url)

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
              tag.onload = function (e) {
                window.event_semaphore--
                lia.log('successfully loaded :', url)
              }
              tag.onerror = function (e) {
                window.event_semaphore--
                lia.error('could not load :', url)
              }
            }

            document.head.appendChild(tag)
          } catch (e) {
            lia.error('loading resource => ', e)
          }

          break
        }
        case 'persistent': {
          if (event.message === 'store') {
            // todo, needs to be moved back
            // persistent.store(event.section)
            elmSend({
              topic: 'load',
              section: -1,
              message: null
            })
          }

          break
        }
        case 'init': {
          let data = event.message

          self.connector.open(
            data.readme,
            data.version,
            data.section_active,
            data
          )

          if (data.definition.onload !== '') {
            lia_execute_event({
              code: data.definition.onload,
              delay: 350
            })
          }

          // signal the ready state to the editor
          if (firstLoad) {
            firstLoad = false

            meta('author', data.definition.author)
            meta('og:description', data.comment)
            meta('og:title', data.str_title)
            meta('og:type', 'website')
            meta('og:url', '')
            meta('og:image', data.definition.logo)

            // store the basic info in the offline-repositories
            self.connector.storeToIndex(data)

            try {
              window.top.liaReady()
            } catch (e) {}
          }

          try {
            window.top.liaDefinitions(data.definition)
          } catch (e) {}

          break
        }
        case 'index': {
          switch (event.message.topic) {
            case 'list': {
              try {
                responsiveVoice.cancel()
              } catch (e) {}
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
              lia.error('Command  not found => ', event.message)
          }
          break
        }
        case 'share': {
          try {
            if (navigator.share) {
              navigator.share(event.message.message)
            }
          } catch (e) {
            lia.error('sharing was not possible => ', event.message, e)
          }

          break
        }
        case 'reset': {
          self.connector.reset()
          window.location.reload()
          break
        }
        default:
          lia.error('Command not found => ', event)
      }
    })
  }
};

export {
  LiaScript
}
