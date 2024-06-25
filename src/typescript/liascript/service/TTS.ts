import log from '../log'
import '../types/responsiveVoice'

// @ts-ignore
import EasySpeech from 'easy-speech/dist/EasySpeech'

enum Gender {
  Female,
  Male,
  Unknown,
}

var useBrowserTTS = false
var browserVoices = {}

var firstSpeak = true

var elmSend: Lia.Send | null

const SETTINGS = 'settings'

export const Service = {
  PORT: 'tts',

  easySpeechSettings: null,

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_

    setTimeout(function () {
      firstSpeak = false
      if (window.responsiveVoice) {
        sendEnabledTTS('responsiveVoiceTTS')
      }

      window.LIA.playback = function (event: Lia.Event) {
        playback(event)
      }
    }, 2000)

    this.easySpeechSettings = EasySpeech.detect()

    EasySpeech.init({ maxTimeout: 5000, interval: 250 })
      .then(() => {
        useBrowserTTS = true
        sendEnabledTTS('browserTTS')
      })
      .catch((e) => {
        console.warn(e)
      })
  },

  mute: function () {
    cancel()
  },

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      // stop talking but send a response to the sender
      case 'cancel': {
        cancel()

        sendResponse(event, 'stop', null)
        break
      }

      case 'read': {
        // TODO: this is a hack to guide TTS from the effect to the settings,
        // such that the current status can be marked at the bottom buttons!
        if (event.track.length == 1 && event.track[0][0] === 'effect') {
          event.track[0][0] = SETTINGS
        }

        if (firstSpeak) {
          sendResponse(event, 'stop')
          return
        }

        const timeout = event.message.param.endsWith('-0') ? 2000 : 500

        setTimeout(function () {
          read(event)
        }, timeout)
        break
      }

      case 'playback': {
        playback(event)
        break
      }

      case 'browserTTS': {
        useBrowserTTS = event.message.param ? true : false
        break
      }
      default:
        log.warn('(Service TTS) unknown message =>', event)
    }
  },
}

function playback(event: Lia.Event) {
  const voice = event.message.param.voice
  const lang = event.message.param.lang
  let text = event.message.param.text

  if (typeof text !== 'string') {
    text = innerText(text)
  }

  speak(text, voice, lang, event)
}

function innerText(node) {
  if (node.nodeType === Node.TEXT_NODE) {
    // If the child node is a text node, append its text content
    return node.textContent
  } else if (node.tagName === 'INPUT') {
    // If the child node is an input element, append its value
    return node.value
  } else if (
    node.classList.contains('lia-effect__circle') ||
    node.classList.contains('lia-quiz-multi')
  ) {
    return ''
  } else if (node.classList.contains('lia-dropdown')) {
    node = node.childNodes[0]
  }

  let text = ''

  try {
    if (window.getComputedStyle(node).display !== 'none') {
      node.childNodes.forEach((n) => {
        text += innerText(n)
      })
    }
  } catch (e) {
    console.warn('TTS: could not read innerText -->', e.message)
  }

  return text
}

function read(event: Lia.Event) {
  cancel()

  let element = document.getElementsByClassName(event.message.param)

  if (element.length) {
    let voice = element[0].getAttribute('data-voice') || 'default'
    let lang = element[0].getAttribute('data-lang') || 'en'
    let hasAudioURLs: boolean = false
    let text = ''

    for (let i = 0; i < element.length; i++) {
      text += (element[i] as HTMLElement).innerText || element[i].textContent

      let audioUrl = element[i].getAttribute('data-file') || null

      if (audioUrl) {
        hasAudioURLs = true
      }
    }

    // This is used to clean up effect numbers, which are marked by a \b
    // \b(1.)\b is not visible to the user within the browser
    text = text.replace(/\\u001a\\d+\\u001a/g, '').trim()

    if (hasAudioURLs) {
      let audioUrls: HTMLMediaElement[] = Array.from(
        document.getElementsByClassName(
          'lia-tts-recordings'
        ) as HTMLCollectionOf<HTMLMediaElement>
      )
      let currentIndex = 0

      async function playNext() {
        if (currentIndex >= audioUrls.length) {
          sendResponse(event, 'stop')
          return
        }

        const audio = audioUrls[currentIndex]
        const source = audio.firstChild as HTMLSourceElement
        const error = (error: string) => {
          console.warn('TTS failed to play ->', '' + error, source.src)
          if (source.src.startsWith('blob:')) {
            currentIndex++
            playNext()
          } else {
            audio.pause()

            window.LIA.fetchError(
              'audio',
              source.src.replace(window.location.origin, '')
            )
          }
        }

        audio.onended = () => {
          audio.currentTime = 0
          currentIndex++
          playNext()
        }

        // resource could not be loaded
        if (audio.readyState === 0) {
          // has previously failed
          error("resource couldn't be loaded")
          return
        }

        // this might be the case for *.flac files or others,
        // in Firefox they can be played only ones and not set
        // to start, this will force the audio to be reloaded
        if (audio.currentTime > 0) {
          audio.innerHTML = source.outerHTML
        }

        const response = audio.play()

        if (response !== undefined) {
          response.catch((e) => error(e.message))
        } else {
          error("resource couldn't be played")
        }
      }

      sendResponse(event, 'start')
      playNext()
    } else if (text !== '' && element[0] !== undefined) {
      speak(text, voice, lang, event)
    }
  }
}

function sendReply(event: Lia.Event) {
  if (elmSend) {
    elmSend(event)
  }
}

function sendEnabledTTS(system: 'responsiveVoiceTTS' | 'browserTTS') {
  sendReply({
    reply: true,
    track: [[SETTINGS, 0]],
    service: 'tts',
    message: {
      cmd: system,
      param: true,
    },
  })
}

export function inject(key: string) {
  if (typeof key === 'string') {
    useBrowserTTS = false

    setTimeout(function () {
      const script = document.createElement('script')
      script.src =
        'https://code.responsivevoice.org/responsivevoice.js?key=' + key
      script.async = true
      script.defer = true
      document.head.appendChild(script)

      script.onload = () => {
        window.responsiveVoice.init()
        sendEnabledTTS('responsiveVoiceTTS')
      }
    }, 250)
  }
}

function cancel() {
  console.log('CANCEL audioRecordings')
  try {
    const audioRecordings = document.getElementsByClassName(
      'lia-tts-recordings'
    ) as HTMLAllCollection<HTMLMediaElement>

    for (let i = 0; i < audioRecordings.length; i++) {
      audioRecordings[i].pause()
      audioRecordings[i].currentTime = 0
    }
  } catch (e) {
    console.warn('TTS failed to cancel audioRecordings', e.message)
  }

  try {
    EasySpeech.cancel()
  } catch (e) {}

  if (window.responsiveVoice) {
    window.responsiveVoice.cancel()
  }
}

function speak(text: string, voice: string, lang: string, event: Lia.Event) {
  if (useBrowserTTS) {
    const syncVoice = getVoice(lang, voice)

    // there was a voice
    if (syncVoice) {
      easySpeak(text, syncVoice, event)
    }
    // try responsive-voice
    else if (window.responsiveVoice) {
      responsiveSpeak(text, voice, event)
    }
    // if everything fails get the first voice from the browser
    // and use it as the default voice
    else {
      const defaultVoice = getDefaultVoice()

      if (defaultVoice) {
        // store as default for the next run
        browserVoices[toKey(lang, voice)] = defaultVoice

        easySpeak(text, defaultVoice, event)
      } else {
        sendResponse(event, 'ERROR', 'no TTS support')
      }
    }
  } else if (window.responsiveVoice) {
    // fix for responsiveVoice not working with German
    if (voice.startsWith('German')) {
      voice.replace('German', 'Deutsch')
    }
    responsiveSpeak(text, voice, event)
  }
}

function easySpeak(text: string, syncVoice: string, event: Lia.Event) {
  EasySpeech.speak({
    text: text,
    voice: syncVoice,
    start: function () {
      sendResponse(event, 'start')
    },
    end: function () {
      sendResponse(event, 'stop')
    },
    error: function (e: any) {
      sendResponse(event, 'error', e.toString())
      console.warn('TTS playback failed:', e.toString())
    },
  })
}

function responsiveSpeak(text: string, voice: string, event: Lia.Event) {
  if (window.responsiveVoice)
    window.responsiveVoice.speak(text, voice, {
      onstart: function () {
        sendResponse(event, 'start')
      },

      onend: function () {
        sendResponse(event, 'stop')
      },

      onerror: function (e: any) {
        sendResponse(event, 'error', e.toString())
        console.warn('TTS playback failed:', e.toString())
      },
    })
}

function sendResponse(
  event: Lia.Event,
  cmd: string,
  param: string | null = 'browser'
) {
  event.message.cmd = cmd
  event.message.param = param
  sendReply(event)
}

function getDefaultVoice() {
  const voices = EasySpeech.voices()

  if (!voices) {
    return null
  }

  return voices[0]
}

function toKey(lang: string, voice: string) {
  return lang + ' - ' + voice
}

function getVoice(lang: string, voice: string) {
  // fix for browserTTS not working with Deutsch
  if (voice.startsWith('Deutsch')) {
    voice.replace('Deutsch', 'German')
  }

  const key = toKey(lang, voice)

  if (browserVoices[key]) {
    return browserVoices[key]
  }

  const voices = EasySpeech.voices()

  if (!voices) {
    return null
  }

  let gender = detectGender(voice)

  let temp
  let bestFit

  for (let i = 0; i < voices.length; i++) {
    temp = voices[i]

    if (
      temp.lang.startsWith(lang) &&
      gender === detectGender(temp.name + temp.voiceURI)
    ) {
      bestFit = temp
      break
    }

    if (temp.lang.startsWith(lang) && !bestFit) {
      bestFit = temp
    }
  }

  if (bestFit) {
    browserVoices[key] = bestFit
    return bestFit
  }

  return null
}

function detectGender(voice: string) {
  if (voice.match(/female/i)) {
    return Gender.Female
  }

  if (voice.match(/male/i)) {
    return Gender.Male
  }

  return Gender.Unknown
}

export default Service
