import log from '../log'

import { TextToSpeech } from '@capacitor-community/text-to-speech'

var firstSpeak = true

var elmSend: Lia.Send | null

const SETTINGS = 'settings'

export const Service = {
  PORT: 'tts',

  init: async function (elmSend_: Lia.Send) {
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

        setTimeout(
          function () {
            read(event)
          },
          firstSpeak ? 2000 : 500
        )
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

  speak(
    text,
    voice,
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

function cancel() {
  TextToSpeech.stop()
}

function speak(
  text: string,
  voice: string,
  onstart?: () => void,
  onend?: () => void,
  onerror?: (_: any) => void
) {
  onstart()

  TextToSpeech.speak({
    text: text,
    lang: toLang(voice),
  })
    .then(() => onend())
    .catch((e) => {
      alert(JSON.stringify(e))
      onerror(e)
    })
}

function toLang(voice: string): string {
  switch (voice) {
    case 'UK English Female':
    case 'UK English Male':
    case 'US English Male':
    case 'US English Female':
    case 'Australian Female':
    case 'Australian Male':
      return 'en'

    case 'Afrikaans Female':
    case 'Afrikaans Male':
      return 'af'

    case 'Albanian Female':
    case 'Albanian Male':
      return 'sq'

    case 'Arabic Female':
    case 'Arabic Male':
      return 'ar'

    case 'Armenian Female':
    case 'Armenian Male':
      return 'hy'

    case 'Bangla Bangladesh Female':
    case 'Bangla Bangladesh Male':
    case 'Bangla India Female':
    case 'Bangla India Male':
      return 'bn'

    case 'Bosnian Female':
    case 'Bosnian Male':
      return 'bs'

    case 'Brazilian Portuguese Female':
    case 'Brazilian Portuguese Male':
    case 'Portuguese Female':
    case 'Portuguese Male':
      return 'pt'

    case 'Catalan Female':
    case 'Catalan Male':
      return 'ca'

    case 'Chinese Female':
    case 'Chinese Male':
    case 'Chinese (Hong Kong) Female':
    case 'Chinese(Hong Kong) Male':
    case 'Chinese Taiwan Female':
    case 'Chinese Taiwan Male':
      return 'zh'

    case 'Croatian Female':
    case 'Croatian Male':
      return 'hr'

    case 'Czech Female':
    case 'Czech Male':
      return 'cs'

    case 'Danish Female':
    case 'Danish Male':
      return 'da'

    case 'Deutsch Female':
    case 'Deutsch Male':
      return 'de'

    case 'Dutch Female':
    case 'Dutch Male':
      return 'nl'

    case 'Esperanto Female':
    case 'Esperanto Male':
      return 'eo'

    case 'Estonian Female':
    case 'Estonian Male':
      return 'et'

    case 'Filipino Female':
    case 'Filipino Male':
      return 'fil'

    case 'Finnish Female':
    case 'Finnish Male':
      return 'fi'

    case 'French Canadian Female':
    case 'French Canadian Male':
    case 'French Female':
    case 'French Male':
      return 'fr'

    case 'Greek Female':
    case 'Greek Male':
      return 'el'

    case 'Hindi Female':
    case 'Hindi Male':
      return 'hi'

    case 'Hungarian Female':
    case 'Hungarian Male':
      return 'hu'

    case 'Icelandic Female':
    case 'Icelandic Male':
      return 'is'

    case 'Indonesian Female':
    case 'Indonesian Male':
      return 'id'

    case 'Italian Female':
    case 'Italian Male':
      return 'it'

    case 'Japanese Female':
    case 'Japanese Male':
      return 'ja'

    case 'Korean Female':
    case 'Korean Male':
      return 'ko'

    case 'Latin Female':
    case 'Latin Male':
      return 'la'

    case 'Latvian Female':
    case 'Latvian Male':
      return 'lv'

    case 'Macedonian Female':
    case 'Macedonian Male':
      return 'mk'

    case 'Moldavian Female':
    case 'Moldavian Male':
      return 'ro'

    case 'Montenegrin Female':
    case 'Montenegrin Male':
      return 'cnr'

    case 'Nepali':
    case 'Nepali Female':
    case 'Nepali Male':
      return 'ne'

    case 'Norwegian Female':
    case 'Norwegian Male':
      return 'nn'

    case 'Polish Female':
    case 'Polish Male':
      return 'pl'

    case 'Romanian Female':
    case 'Romanian Male':
      return 'ro'

    case 'Russian Female':
    case 'Russian Male':
      return 'ru'

    case 'Serbian Female':
    case 'Serbian Male':
    case 'Serbo-Croatian Male':
      return 'sr'

    case 'Sinhala':
    case 'Sinhala Female':
    case 'Sinhala Male':
      return 'si'

    case 'Slovak Female':
    case 'Slovak Male':
      return 'sk'

    case 'Spanish Female':
    case 'Spanish Male':
    case 'Spanish Latin American Female':
    case 'Spanish Latin American Male':
      return 'es'

    case 'Swahili Female':
    case 'Swahili Male':
      return 'sw'

    case 'Swedish Female':
    case 'Swedish Male':
      return 'sv'

    case 'Tamil Female':
    case 'Tamil Male':
      return 'ta'

    case 'Thai Female':
    case 'Thai Male':
      return 'th'

    case 'Turkish Female':
    case 'Turkish Male':
      return 'tr'

    case 'Ukrainian Female':
    case 'Ukrainian Male':
      return 'uk'

    case 'Vietnamese Female':
    case 'Vietnamese Male':
      return 'vi'

    case 'Welsh Male':
      return 'cy'
  }
}

export default Service
