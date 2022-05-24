import log from '../log'

import '../types/responsiveVoice'

var firstSpeak = true

var elmSend: Lia.Send | null

const SETTINGS = 'settings'

export const Service = {
  PORT: 'tts',

  init: function (elmSend_: Lia.Send) {
    setTimeout(function () {
      firstSpeak = false

      window.LIA.playback = function (event: Lia.Event) {
        playback(event)
      }
    }, 2000)

    elmSend = elmSend_
  },

  mute: function () {
    cancel()
  },

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      // stop talking but send a response to the sender
      case 'cancel': {
        cancel()
        event.message.cmd = 'stop'
        event.message.param = null

        sendReply(event)
        break
      }

      case 'read': {
        // TODO: this is a hack to guide TTS from the effect to the settings,
        // such that the current status can be marked at the bottom buttons!
        if (event.track.length == 1 && event.track[0][0] === 'effect') {
          event.track[0][0] = SETTINGS
        }

        const timeout =
          firstSpeak || event.message.param.endsWith('0') ? 2000 : 500

        setTimeout(function () {
          read(event)
        }, timeout)
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
  console.warn('playback', event)

  const text = event.message.param.text
  const voice = event.message.param.voice
  const lang = event.message.param.lang

  speak(
    text,
    voice,
    lang,
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

      console.warn('TTS playback failed:', e.toString())
    }
  )
}

function read(event: Lia.Event) {
  let element = document.getElementsByClassName(event.message.param)
  let voice = element[0].getAttribute('data-voice') || 'default'
  let lang = element[0].getAttribute('data-lang') || 'en'

  let text = ''

  for (let i = 0; i < element.length; i++) {
    text += (element[i] as HTMLElement).innerText || element[i].textContent
  }

  // This is used to clean up effect numbers, which are marked by a \b
  // \b(1.)\b is not visible to the user within the browser
  text = text.replace(/\\u001a\\d+\\u001a/g, '').trim()

  if (text !== '' && element[0]) {
    speak(
      text,
      voice,
      lang,
      function () {
        //event.track[0][0] = SETTINGS
        event.message.cmd = 'start'
        event.message.param = undefined
        sendReply(event)
      },
      function () {
        //event.track[0][0] = SETTINGS
        event.message.cmd = 'stop'
        event.message.param = undefined
        sendReply(event)
      },
      function (e: any) {
        //event.track[0][0] = SETTINGS
        event.message.cmd = 'error'
        event.message.param = e.toString()
        sendReply(event)
      }
    )
  }
}

function sendReply(event: Lia.Event) {
  if (elmSend) {
    elmSend(event)
  }
}

export function inject(key: string) {
  if (typeof key === 'string') {
    setTimeout(function () {
      const script = document.createElement('script')
      script.src =
        'https://code.responsivevoice.org/responsivevoice.js?key=' + key
      script.async = true
      script.defer = true
      document.head.appendChild(script)

      script.onload = () => {
        window.responsiveVoice.init()
      }
    }, 250)
  }
}

function cancel() {
  if (window.responsiveVoice) window.responsiveVoice.cancel()
}

function speak(
  text: string,
  voice: string,
  lang: string,
  onstart?: () => void,
  onend?: () => void,
  onerror?: (_: any) => void
) {
  if (window.responsiveVoice)
    window.responsiveVoice.speak(text, voice, {
      onstart: onstart,
      onend: onend,
      onerror: onerror,
    })
}

export default Service
