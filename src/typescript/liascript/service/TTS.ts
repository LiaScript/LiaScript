import log from '../log'
import TTS from '../tts'
import Port from '../types/ports'

var firstSpeak = true
var backup: {
  voice: string
  text: string
}

var elmSend: Lia.Send | null

const Service = {
  PORT: 'tts',

  init: function (elmSend_: Lia.Send) {
    setTimeout(function () {
      firstSpeak = false
    }, 2000)

    elmSend = elmSend_

    window.playback = function (event: Lia.Event) {
      playback(event)
    }
  },

  mute: function () {
    TTS.cancel()
  },

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'cancel': {
        TTS.cancel()
        event.message.cmd = 'stop'
        event.message.param = 'TODO'

        if (event.track[0][1] < 0) {
          event.track[0][0] = Port.SETTINGS
        }

        sendReply(event)
        break
      }

      case 'read': {
        setTimeout(
          function () {
            let element = document.getElementsByClassName(event.message.param)
            let voice = element[0].getAttribute('data-voice') || 'default'

            let text = ''

            for (let i = 0; i < element.length; i++) {
              text +=
                (element[i] as HTMLElement).innerText || element[i].textContent
            }

            // This is used to clean up effect numbers, which are marked by a \b
            text = text.replace(/\\u001a\\d+\\u001a/g, '').trim()

            if (text !== '' && element[0]) {
              backup = { voice: voice, text: text }

              TTS.speak(
                text,
                voice,
                function () {
                  event.track[0][0] = Port.SETTINGS
                  event.message.cmd = 'start'
                  event.message.param = undefined
                  sendReply(event)
                },
                function () {
                  event.track[0][0] = Port.SETTINGS
                  event.message.cmd = 'stop'
                  event.message.param = undefined
                  sendReply(event)
                },
                function (e: any) {
                  event.track[0][0] = Port.SETTINGS
                  event.message.cmd = 'error'
                  event.message.param = e.toString()
                  sendReply(event)
                }
              )
            }
          },
          firstSpeak ? 2000 : 500
        )

        break
      }

      case 'repeat': {
        event.message.param = backup
        playback(event)
        break
      }

      case 'playback': {
        playback(event)
        break
      }

      default:
        log.warn('(Service TTS) unknown message =>', event)
    }
  },
}

function playback(event: Lia.Event) {
  backup = event.message.param

  TTS.speak(
    event.message.param.text,
    event.message.param.voice,
    function () {
      event.message.cmd = 'start'
      event.message.param = undefined
      sendReply(event)
    },
    function () {
      event.message.cmd = 'stop'
      event.message.param = undefined
      sendReply(event)
    },
    function (e: any) {
      event.message.cmd = 'error'
      event.message.param = e.toString()
      sendReply(event)
    }
  )
}

function sendReply(event: Lia.Event) {
  if (elmSend) {
    elmSend(event)
  }
}

export default Service
