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

const AUDIO = 'lia-tts-recordings'
const VIDEO = 'lia-tts-videos'

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

        if (event.track.length == 1 && event.track[0][0] === 'effect') {
          event.track[0][0] = SETTINGS
        }

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

  const options = getAudioSettings(text)

  if (typeof text !== 'string') {
    text = innerText(text)
  }

  speak(text, voice, lang, options, event)
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

function getAudioSettings(element: HTMLElement | Element) {
  const options = Object.assign({ videoRate: 1 }, window.LIA.settings.audio)
  const rate = element.getAttribute('data-rate')
  if (rate) {
    try {
      options.rate = parseFloat(rate)
    } catch (e) {}
  }
  const pitch = element.getAttribute('data-pitch')
  if (pitch) {
    try {
      options.pitch = parseFloat(pitch)
    } catch (e) {}
  }

  return options
}

function read(event: Lia.Event) {
  cancel()

  let element = document.getElementsByClassName(event.message.param)

  if (element.length) {
    let voice = element[0].getAttribute('data-voice') || 'default'
    let lang = element[0].getAttribute('data-lang') || 'en'
    let translation = (element[0].getAttribute('translate') || 'no') === 'yes'

    const options = getAudioSettings(element[0])

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

    const player: any = document.getElementById(VIDEO)
    const videos: HTMLVideoElement[] =
      (Array.from(player?.children as unknown[]) as HTMLVideoElement[]) || []

    if (videos.length > 0 && player) {
      let currentIndex = 0
      let isEnding = false
      let ttsFinished = !translation // If no translation needed, mark TTS as finished

      // Send initial start response
      sendResponse(event, 'start')

      // Handle translation mode differently
      if (translation && text.trim() !== '') {
        // For translation mode, preload videos to get their durations
        Promise.all(
          videos.map((video) => {
            return new Promise<number>((resolve) => {
              // If video is already loaded with duration
              if (video.readyState >= 2 && video.duration) {
                resolve(video.duration)
                return
              }

              // Otherwise wait for metadata to load
              const handleLoaded = () => {
                video.removeEventListener('loadedmetadata', handleLoaded)
                resolve(video.duration)
              }
              video.addEventListener('loadedmetadata', handleLoaded)

              // Set source if not already
              if (!video.src && video.querySelector('source')) {
                video.load()
              }
            })
          })
        )
          .then((durations) => {
            // Calculate total video duration
            const totalVideoDuration = durations.reduce(
              (total, duration) => total + duration,
              0
            )

            // Estimate TTS duration based on text length and speech rate
            const estimatedTTSDuration = estimateTTSDuration(
              text,
              lang,
              options.rate
            )

            // Calculate adjusted playback rate if video is shorter than TTS
            const originalRate = options.rate
            if (totalVideoDuration < estimatedTTSDuration) {
              // Calculate rate to match durations, with a minimum threshold
              const MIN_RATE = 0.5 // Most browsers support down to 0.5x speed
              options.videoRate = Math.max(
                MIN_RATE,
                (totalVideoDuration / estimatedTTSDuration) * originalRate
              )
              console.log(
                `Adjusting video playback rate to ${options.videoRate} to match estimated TTS duration`
              )
            } else {
              options.videoRate = originalRate
            }

            // Start TTS with custom handlers
            speak(text, voice, lang, options, {
              ...event,
              message: {
                ...event.message,
                cmd: event.message.cmd,
              },
              handlers: {
                onStart: () => {
                  // Start video when TTS begins speaking
                  playNext()
                },
                onStop: () => {
                  ttsFinished = true

                  // Stop the currently playing video when TTS finishes
                  if (currentIndex < videos.length) {
                    const currentVideo = videos[currentIndex]
                    if (!currentVideo.paused) {
                      currentVideo.pause()

                      // Trigger the end of video processing
                      currentIndex = videos.length
                      isEnding = true
                    }
                  }

                  // Send stop response
                  if (isEnding || currentIndex >= videos.length) {
                    sendResponse(event, 'stop')
                  } else {
                    // Mark as ending to prepare for stop response
                    isEnding = true
                  }
                },
                onError: (error) => {
                  console.warn('TTS translation error:', error)
                  ttsFinished = true
                  if (!videos[currentIndex]?.played.length) {
                    playNext()
                  }
                  if (currentIndex >= videos.length && isEnding) {
                    sendResponse(event, 'stop')
                  }
                },
              },
            })
          })
          .catch((error) => {
            console.warn('Error calculating video durations:', error)
            // Fall back to original behavior if duration calculation fails
            speak(text, voice, lang, options, {
              ...event,
              message: { ...event.message, cmd: event.message.cmd },
              handlers: {
                onStart: () => playNext(),
                onStop: () => {
                  ttsFinished = true

                  // Stop the currently playing video when TTS finishes
                  if (currentIndex < videos.length) {
                    const currentVideo = videos[currentIndex]
                    if (!currentVideo.paused) {
                      currentVideo.pause()

                      // Trigger the end of video processing
                      currentIndex = videos.length
                      isEnding = true
                    }
                  }

                  // Send stop response
                  if (isEnding || currentIndex >= videos.length) {
                    sendResponse(event, 'stop')
                  } else {
                    // Mark as ending to prepare for stop response
                    isEnding = true
                  }
                },
                onError: (error) => {
                  console.warn('TTS translation error:', error)
                  ttsFinished = true
                  if (!videos[currentIndex]?.played.length) playNext()
                  if (currentIndex >= videos.length && isEnding)
                    sendResponse(event, 'stop')
                },
              },
            })
          })
      } else {
        // For non-translation mode, play the video immediately with original audio
        playNext()
      }

      async function playNext() {
        if (currentIndex >= videos.length) {
          if (!isEnding) {
            isEnding = true
            if (ttsFinished) {
              sendResponse(event, 'stop')
            }
          }
          return
        }

        const video = videos[currentIndex]

        // Parse time fragment from video URL
        const timeFragment = parseTimeFragment(video.src)

        // Set up event to handle end time if specified
        if (timeFragment.end !== null) {
          const checkTimeUpdate = () => {
            if (video.currentTime >= timeFragment.end!) {
              video.pause()
              video.removeEventListener('timeupdate', checkTimeUpdate)
              video.onended!({} as Event)
            }
          }
          video.addEventListener('timeupdate', checkTimeUpdate)
        }

        video.onended = () => {
          currentIndex++
          playNext()
        }

        // Set start time if specified, otherwise reset to beginning
        if (timeFragment.start !== null) {
          video.currentTime = timeFragment.start
        } else if (video.currentTime !== 0) {
          video.currentTime = 0
        }

        video.preservesPitch = true
        // Use possibly adjusted video rate in translation mode
        video.playbackRate =
          translation && options.videoRate ? options.videoRate : options.rate

        // Set muted state based on translation flag
        video.muted = translation

        video.style.display = 'block'
        if (currentIndex > 0) {
          videos[currentIndex - 1].style.display = 'none'
        }

        // Always store the background video
        storeBackgroundVideo(player, video)

        // Play the video
        const response = video.play()
        if (response && typeof response.then === 'function') {
          response.catch((e) => {
            console.warn('Failed to play video:', e.message)
          })
        }
      }
    } else if (hasAudioURLs) {
      let audioUrls: HTMLMediaElement[] = Array.from(
        document.getElementsByClassName(
          AUDIO
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

        // Parse time fragment from audio URL
        const timeFragment = parseTimeFragment(source.src)

        // Set up event to handle end time if specified
        if (timeFragment.end !== null) {
          const checkTimeUpdate = () => {
            if (audio.currentTime >= timeFragment.end!) {
              audio.pause()
              audio.removeEventListener('timeupdate', checkTimeUpdate)
              audio.onended!({} as Event) // Trigger the onended event manually
            }
          }
          audio.addEventListener('timeupdate', checkTimeUpdate)
        }

        const error = (error: string) => {
          console.warn('TTS failed to play ->', '' + error, source.src)

          if (source.src.startsWith('blob:')) {
            currentIndex++
            playNext()
            return
          }

          audio.pause()

          if (window.LIA.fetchError) {
            window.LIA.fetchError(
              'audio',
              source.src.replace(window.location.origin, '')
            )
            return
          }

          currentIndex++
          playNext()
        }

        audio.onended = () => {
          audio.currentTime = 0
          currentIndex++
          playNext()
        }

        // Set start time if specified
        if (timeFragment.start !== null) {
          audio.currentTime = timeFragment.start
        } else if (audio.currentTime > 0) {
          // Your existing logic for resetting audio
          audio.innerHTML = source.outerHTML
        }

        audio.preservesPitch = true
        audio.playbackRate = options.rate
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
      speak(text, voice, lang, options, event)
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
  try {
    const audioRecordings = document.getElementsByClassName(
      AUDIO
    ) as HTMLCollectionOf<HTMLMediaElement>

    for (let i = 0; i < audioRecordings.length; i++) {
      audioRecordings[i].pause()
      audioRecordings[i].currentTime = 0
    }
  } catch (e) {
    console.warn('TTS failed to cancel audioRecordings', e.message)
  }

  try {
    const player: any = document.getElementById(VIDEO)
    const videos: HTMLMediaElement[] =
      (Array.from(player?.children as unknown[]) as HTMLMediaElement[]) || []

    for (let i = 0; i < videos.length; i++) {
      videos[i].pause()
    }
  } catch (e) {
    console.warn('TTS failed to cancel videoRecordings', e.message)
  }

  try {
    EasySpeech.cancel()
  } catch (e) {}

  if (window.responsiveVoice) {
    window.responsiveVoice.cancel()
  }
}

function speak(
  text: string,
  voice: string,
  lang: string,
  options: {
    rate: number
    pitch: number
    videoRate?: number
  },
  event: Lia.Event & {
    handlers?: {
      onStart: () => void
      onStop: () => void
      onError: (error: any) => void
    }
  }
) {
  const customHandlers = event.handlers || {
    onStart: () => sendResponse(event, 'start'),
    onStop: () => sendResponse(event, 'stop'),
    onError: (e) => {
      sendResponse(event, 'error', e.toString())
      console.warn('TTS playback failed:', e.toString())
    },
  }

  if (useBrowserTTS) {
    const syncVoice = getVoice(lang, voice)

    // there was a voice
    if (syncVoice) {
      easySpeak(text, syncVoice, options, customHandlers)
    }
    // try responsive-voice
    else if (window.responsiveVoice) {
      responsiveSpeak(text, voice, options, customHandlers)
    }
    // if everything fails get the first voice from the browser
    // and use it as the default voice
    else {
      const defaultVoice = getDefaultVoice()

      if (defaultVoice) {
        // store as default for the next run
        browserVoices[toKey(lang, voice)] = defaultVoice

        easySpeak(text, defaultVoice, options, customHandlers)
      } else {
        customHandlers.onError('no TTS support')
      }
    }
  } else if (window.responsiveVoice) {
    // fix for responsiveVoice not working with German
    if (voice.startsWith('German')) {
      voice.replace('German', 'Deutsch')
    }
    responsiveSpeak(text, voice, options, customHandlers)
  }
}

function easySpeak(
  text: string,
  syncVoice: string,
  options: {
    rate: number
    pitch: number
  },
  handlers: {
    onStart: () => void
    onStop: () => void
    onError: (error: any) => void
  }
) {
  EasySpeech.speak({
    text: text,
    voice: syncVoice,
    start: handlers.onStart,
    end: handlers.onStop,
    error: handlers.onError,
    pitch: options.pitch,
    rate: options.rate,
  })
}

function responsiveSpeak(
  text: string,
  voice: string,
  options: { pitch: number; rate: number },
  handlers: {
    onStart: () => void
    onStop: () => void
    onError: (error: any) => void
  }
) {
  if (window.responsiveVoice)
    window.responsiveVoice.speak(text, voice, {
      onstart: handlers.onStart,
      onend: handlers.onStop,
      onerror: handlers.onError,
      pitch: options.pitch,
      rate: options.rate,
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

function storeBackgroundVideo(player: HTMLElement, video: HTMLVideoElement) {
  try {
    const background = video.cloneNode(true) as HTMLVideoElement

    background.addEventListener('loadedmetadata', () => {
      background.currentTime = background.duration
    })

    background.id = 'tts-video-preview'
    background.preload = 'auto'
    background.autoplay = false
    background.muted = true
    background.onerror = null
    background.onended = null
    background.onplay = null

    if (document.getElementById('tts-video-preview')) {
      document.getElementById('tts-video-preview')?.replaceWith(background)
    } else {
      player.parentElement?.insertBefore(
        background,
        player.parentElement.firstChild
      )
    }
  } catch (e) {
    console.warn('TTS failed to draw video frame ->', e.message)
  }
}

function parseTimeFragment(url: string): {
  start: number | null
  end: number | null
} {
  const result: { start: number | null; end: number | null } = {
    start: null,
    end: null,
  }

  try {
    // Extract time fragment if it exists
    const hashIndex = url.indexOf('#t=')
    if (hashIndex !== -1) {
      const timeValue = url.substring(hashIndex + 3)
      const timeParts = timeValue.split(',')

      if (timeParts[0]) {
        result.start = parseFloat(timeParts[0])
      }

      if (timeParts[1]) {
        result.end = parseFloat(timeParts[1])
      }
    }
  } catch (e) {
    console.warn('Failed to parse time fragment:', e)
  }

  return result
}

/**
 * Estimates the duration of TTS output based on text length, language and speech rate
 * This is a rough approximation as actual TTS timing depends on many factors
 */
function estimateTTSDuration(text: string, lang: string, rate: number): number {
  // Average speaking rates for different languages (words per minute)
  const baseRates: { [key: string]: number } = {
    en: 150, // English: ~150 wpm
    de: 125, // German: ~125 wpm (generally longer words)
    fr: 165, // French: ~165 wpm
    es: 155, // Spanish: ~155 wpm
    it: 160, // Italian: ~160 wpm
    ja: 125, // Japanese: ~125 wpm
    zh: 130, // Chinese: ~130 wpm
    ru: 120, // Russian: ~120 wpm
    default: 140, // Default fallback
  }

  // Get base rate for language or use default
  const baseLang = lang.split('-')[0].toLowerCase()
  const baseWPM = baseRates[baseLang] || baseRates.default

  // Adjust by TTS rate setting
  const adjustedWPM = baseWPM * rate

  // Count words (simple approximation)
  const wordCount = text.split(/\s+/).filter((word) => word.length > 0).length

  // Add some padding (10%) for pauses and processing
  const durationSeconds = (wordCount / adjustedWPM) * 60 * 1.1

  // Ensure minimum duration
  return Math.max(2, durationSeconds)
}

export default Service
