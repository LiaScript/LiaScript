import log from '../log'
import '../types/responsiveVoice'
import LANGUAGE_FALLBACKS, {
  LEGACY_LANGUAGE_MAP,
} from './helper/language-fallbacks'

// @ts-ignore
import EasySpeech from 'easy-speech/dist/EasySpeech'

enum Gender {
  Female,
  Male,
  Unknown,
}

var useBrowserTTS: null | boolean = null
var browserVoices: Record<string, SpeechSynthesisVoice> = {}

var firstSpeak = true

var elmSend: Lia.Send | null

// Chrome/Safari bug: resume() fires 'end' instead of continuing — re-speak on resume.
// browserTTSIntentionalPause flags an explicit user pause so 'end' triggers re-speak.
type BrowserTTSSpeakArgs = {
  text: string
  voice: SpeechSynthesisVoice
  options: { rate: number; pitch: number }
  handlers: { onStart: () => void; onStop: () => void; onError: (e: any) => void }
} | null

var browserTTSSpeakArgs: BrowserTTSSpeakArgs = null
var browserTTSIntentionalPause = false

// Tracks the current responsiveVoice speak call to enable re-speak on resume failure.
type ResponsiveVoiceSpeakArgs = {
  text: string
  voice: string
  options: { rate: number; pitch: number }
  handlers: { onStart: () => void; onStop: () => void; onError: (e: any) => void }
} | null

var responsiveVoiceSpeakArgs: ResponsiveVoiceSpeakArgs = null

// For tracking active audio/video media to enable pause/resume and progress updates.
type ActiveMediaState = {
  media: HTMLMediaElement | null
  event: Lia.Event | null
  progressInterval: ReturnType<typeof setInterval> | null
}

var activeMedia: ActiveMediaState = { media: null, event: null, progressInterval: null }

function stopProgressInterval() {
  if (activeMedia.progressInterval !== null) {
    clearInterval(activeMedia.progressInterval)
    activeMedia.progressInterval = null
  }
}

function clearMediaState() {
  stopProgressInterval()
  activeMedia.media = null
  activeMedia.event = null
}

function startProgressInterval(event: Lia.Event) {
  stopProgressInterval()
  let lastTime = -1
  let playStart: number | null = null
  activeMedia.progressInterval = setInterval(() => {
    const media = activeMedia.media
    if (!media || media.paused) {
      playStart = null
      return
    }
    const t = media.currentTime
    // If duration is not available, estimate total time as current time + 10s, and adjust dynamically as current time advances.
    const total = isFinite(media.duration) && media.duration > 0
      ? media.duration
      : (() => {
          if (playStart === null) playStart = Date.now()
          return (Date.now() - playStart) / 1000 + t + 10
        })()
    if (t !== lastTime) {
      lastTime = t
      sendResponse(event, 'progress', JSON.stringify({ current: t, total }))
    }
  }, 250)
}

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
      .catch((e: any) => {
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

      case 'pause': {
        if (activeMedia.media && !activeMedia.media.paused) {
          activeMedia.media.pause()
          stopProgressInterval()
          if (activeMedia.event) {
            sendResponse(activeMedia.event, 'paused', null)
          }
        } else if (window.responsiveVoice && responsiveVoiceSpeakArgs && window.responsiveVoice.isPlaying()) {
          try {
            window.responsiveVoice.pause()
            sendResponse(event, 'paused', null)
          } catch (e) {
            console.warn('Failed to pause responsiveVoice:', e)
          }
        } else if (window.speechSynthesis && window.speechSynthesis.speaking) {
          try {
            browserTTSIntentionalPause = true
            EasySpeech.pause()
            sendResponse(event, 'paused', null)
          } catch (e) {
            browserTTSIntentionalPause = false
            console.warn('Failed to pause browser TTS:', e)
          }
        }
        break
      }

      case 'resume': {
        if (activeMedia.media && activeMedia.media.paused && activeMedia.event) {
          activeMedia.media.play().catch((e: any) => {
            if (e.name !== 'AbortError') {
              console.warn('Failed to resume media:', e.message)
            }
          })
          startProgressInterval(activeMedia.event)
          sendResponse(activeMedia.event, 'start', null)
          const resumeT = activeMedia.media.currentTime
          const resumeTotal = isFinite(activeMedia.media.duration) && activeMedia.media.duration > 0
            ? activeMedia.media.duration
            : resumeT + 10
          sendResponse(activeMedia.event, 'progress', JSON.stringify({ current: resumeT, total: resumeTotal }))
        } else if (window.responsiveVoice && responsiveVoiceSpeakArgs) {
          try {
            window.responsiveVoice.resume()
            sendResponse(event, 'start', null)
          } catch (e) {
            // resume() failed — re-speak from scratch as last resort
            const args = responsiveVoiceSpeakArgs
            if (args) responsiveSpeak(args.text, args.voice, args.options, args.handlers)
            console.warn('Failed to resume responsiveVoice, re-speaking:', e)
          }
        } else if (browserTTSSpeakArgs && (window.speechSynthesis?.paused || browserTTSIntentionalPause)) {
          try {
            EasySpeech.resume()
            // If we reach here, resume() did not fire 'end' synchronously — clear
            // the flag so any future natural 'end' is treated as real completion.
            browserTTSIntentionalPause = false
            sendResponse(event, 'start', null)
          } catch (e) {
            browserTTSIntentionalPause = false
            // resume() threw — re-speak from scratch as last resort
            const args = browserTTSSpeakArgs
            if (args) easySpeak(args.text, args.voice, args.options, args.handlers)
            console.warn('Failed to resume browser TTS, re-speaking:', e)
          }
        }
        break
      }

      case 'seek': {
        const seekTo = parseFloat(event.message.param)
        if (!isNaN(seekTo) && activeMedia.media && activeMedia.event) {
          stopProgressInterval()
          activeMedia.media.currentTime = seekTo
          sendResponse(
            activeMedia.event,
            'progress',
            JSON.stringify({ current: seekTo, total: activeMedia.media.duration })
          )
          if (!activeMedia.media.paused) {
            startProgressInterval(activeMedia.event)
          }
        }
        break
      }

      case 'preferBrowserTTS': {
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
      node.childNodes.forEach((n: Node) => {
        text += innerText(n)
      })
    }
  } catch (e: any) {
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
      let ttsFinished = !translation

      sendResponse(event, 'start')

      const makeVideoHandlers = () => ({
        onStart: () => playNextVideo(),
        onStop: () => {
          ttsFinished = true
          if (currentIndex < videos.length && !videos[currentIndex].paused) {
            videos[currentIndex].pause()
            currentIndex = videos.length
            isEnding = true
          }
          if (isEnding || currentIndex >= videos.length) {
            sendResponse(event, 'stop')
          } else {
            isEnding = true
          }
        },
        onError: (err: any) => {
          console.warn('TTS translation error:', err)
          ttsFinished = true
          if (!videos[currentIndex]?.played.length) playNextVideo()
          if (currentIndex >= videos.length && isEnding) sendResponse(event, 'stop')
        },
      })

      if (translation && text.trim() !== '') {
        Promise.all(
          videos.map(
            video =>
              new Promise<number>(resolve => {
                if (video.readyState >= 2 && video.duration) {
                  resolve(video.duration)
                  return
                }
                const onLoaded = () => {
                  video.removeEventListener('loadedmetadata', onLoaded)
                  resolve(video.duration)
                }
                video.addEventListener('loadedmetadata', onLoaded)
                if (!video.src && video.querySelector('source')) video.load()
              })
          )
        )
          .then(durations => {
            const totalVideoDuration = durations.reduce((a, b) => a + b, 0)
            const estimatedTTSDuration = estimateTTSDuration(text, lang, options.rate)
            const MIN_RATE = 0.5
            if (totalVideoDuration < estimatedTTSDuration) {
              options.videoRate = Math.max(
                MIN_RATE,
                (totalVideoDuration / estimatedTTSDuration) * options.rate
              )
              console.log(`Adjusting video playback rate to ${options.videoRate}`)
            } else {
              options.videoRate = options.rate
            }
            speak(text, voice, lang, options, { ...event, handlers: makeVideoHandlers() })
          })
          .catch(err => {
            console.warn('Error calculating video durations:', err)
            speak(text, voice, lang, options, { ...event, handlers: makeVideoHandlers() })
          })
      } else {
        playNextVideo()
      }

      function playNextVideo() {
        if (currentIndex >= videos.length) {
          if (!isEnding) {
            isEnding = true
            if (ttsFinished) {
              clearMediaState()
              sendResponse(event, 'stop')
            }
          }
          return
        }

        const video = videos[currentIndex]
        const timeFragment = parseTimeFragment(video.src)

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
          playNextVideo()
        }

        video.currentTime = timeFragment.start ?? 0
        video.preservesPitch = true
        video.playbackRate = translation && options.videoRate ? options.videoRate : options.rate
        video.muted = translation
        video.style.display = 'block'
        if (currentIndex > 0) videos[currentIndex - 1].style.display = 'none'

        storeBackgroundVideo(player, video)
        activeMedia.media = video
        activeMedia.event = event
        startProgressInterval(event)

        const sendVideoProgress = () => {
          if (isFinite(video.duration) && video.duration > 0) {
            video.removeEventListener('durationchange', sendVideoProgress)
            sendResponse(event, 'progress', JSON.stringify({ current: video.currentTime, total: video.duration }))
          }
        }

        if (isFinite(video.duration) && video.duration > 0) {
          sendVideoProgress()
        } else {
          video.addEventListener('durationchange', sendVideoProgress)
        }

        video.play().catch((e: any) => {
          if (e.name !== 'AbortError') {
            console.warn('Failed to play video:', e.message)
          }
        })
      }
    } else if (hasAudioURLs) {
      const audioUrls: HTMLMediaElement[] = Array.from(
        document.getElementsByClassName(AUDIO) as HTMLCollectionOf<HTMLMediaElement>
      )
      let currentIndex = 0

      function playNextAudio() {
        if (currentIndex >= audioUrls.length) {
          clearMediaState()
          sendResponse(event, 'stop')
          return
        }

        const audio = audioUrls[currentIndex]
        const source = audio.firstChild as HTMLSourceElement
        const timeFragment = parseTimeFragment(source.src)

        if (timeFragment.end !== null) {
          const checkTimeUpdate = () => {
            if (audio.currentTime >= timeFragment.end!) {
              audio.pause()
              audio.removeEventListener('timeupdate', checkTimeUpdate)
              audio.onended!({} as Event)
            }
          }
          audio.addEventListener('timeupdate', checkTimeUpdate)
        }

        const onError = (err: string) => {
          console.warn('TTS failed to play ->', err, source.src)
          if (source.src.startsWith('blob:')) {
            currentIndex++
            playNextAudio()
            return
          }
          audio.pause()
          if (window.LIA.fetchError) {
            window.LIA.fetchError('audio', source.src.replace(window.location.origin, ''))
            return
          }
          currentIndex++
          playNextAudio()
        }

        audio.onended = () => {
          audio.currentTime = 0
          currentIndex++
          if (currentIndex < audioUrls.length) {
            activeMedia.media = audioUrls[currentIndex]
          } else {
            clearMediaState()
          }
          playNextAudio()
        }

        if (timeFragment.start !== null) {
          audio.currentTime = timeFragment.start
        } else if (audio.currentTime > 0) {
          audio.innerHTML = source.outerHTML
        }

        audio.preservesPitch = true
        audio.playbackRate = options.rate
        activeMedia.media = audio
        activeMedia.event = event

        const sendInitialProgress = () => {
          if (audio.duration > 0) {
            sendResponse(
              event,
              'progress',
              JSON.stringify({ current: audio.currentTime, total: audio.duration })
            )
          }
        }

        const response = audio.play()
        if (response !== undefined) {
          response
            .then(sendInitialProgress)
            .catch(e => onError(e.message))
        } else {
          onError("resource couldn't be played")
        }
      }

      sendResponse(event, 'start')
      startProgressInterval(event)
      playNextAudio()
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
    useBrowserTTS = useBrowserTTS === null ? false : useBrowserTTS

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
  browserTTSSpeakArgs = null
  browserTTSIntentionalPause = false
  clearMediaState()

  try {
    const audioRecordings = document.getElementsByClassName(
      AUDIO
    ) as HTMLCollectionOf<HTMLMediaElement>

    for (let i = 0; i < audioRecordings.length; i++) {
      audioRecordings[i].pause()
      audioRecordings[i].currentTime = 0
    }
  } catch (e: any) {
    console.warn('TTS failed to cancel audioRecordings', e.message)
  }

  try {
    const player: any = document.getElementById(VIDEO)
    const videos: HTMLMediaElement[] =
      (Array.from(player?.children as unknown[]) as HTMLMediaElement[]) || []

    for (let i = 0; i < videos.length; i++) {
      videos[i].pause()
      videos[i].currentTime = 0
      videos[i].load()
    }
  } catch (e: any) {
    console.warn('TTS failed to cancel videoRecordings', e.message)
  }

  try {
    EasySpeech.cancel()
  } catch (e) {}

  if (window.responsiveVoice) {
    window.responsiveVoice.cancel()
  }
  responsiveVoiceSpeakArgs = null
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
    onError: e => {
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
      voice = voice.replace('German', 'Deutsch')
    }
    responsiveSpeak(text, voice, options, customHandlers)
  }
}

function easySpeak(
  text: string,
  syncVoice: SpeechSynthesisVoice,
  options: { rate: number; pitch: number },
  handlers: { onStart: () => void; onStop: () => void; onError: (error: any) => void }
) {
  browserTTSSpeakArgs = { text, voice: syncVoice, options, handlers }
  browserTTSIntentionalPause = false

  EasySpeech.speak({
    text,
    voice: syncVoice,
    start: handlers.onStart,
    end: () => {
      if (browserTTSIntentionalPause) {
        // Chrome/Safari fired 'end' due to resume() bug — re-speak from scratch
        browserTTSIntentionalPause = false
        easySpeak(text, syncVoice, options, handlers)
      } else {
        browserTTSSpeakArgs = null
        handlers.onStop()
      }
    },
    error: (e: any) => {
      browserTTSSpeakArgs = null
      browserTTSIntentionalPause = false
      handlers.onError(e)
    },
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
  if (window.responsiveVoice) {
    responsiveVoiceSpeakArgs = { text, voice, options, handlers }
    window.responsiveVoice.speak(text, voice, {
      onstart: handlers.onStart,
      onend: () => {
        responsiveVoiceSpeakArgs = null
        handlers.onStop()
      },
      onerror: (e: any) => {
        responsiveVoiceSpeakArgs = null
        handlers.onError(e)
      },
      pitch: options.pitch,
      rate: options.rate,
    })
  }
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

function baseLang(tag: string): string {
  const base = tag.trim().split(/[-_]/)[0].toLowerCase()
  return LEGACY_LANGUAGE_MAP[base] || base
}

function buildLanguageCandidates(lang: string): string[] {
  const base = baseLang(lang)
  const seen = new Set<string>()
  const result: string[] = []
  for (const candidate of [
    lang,
    base,
    ...(LANGUAGE_FALLBACKS[base] || []),
    'en',
  ]) {
    if (candidate && !seen.has(candidate)) {
      seen.add(candidate)
      result.push(candidate)
    }
  }
  return result
}

function scoreVoice(
  requestedLang: string,
  requestedVoiceName: string,
  voice: SpeechSynthesisVoice
): number {
  const reqBase = baseLang(requestedLang)
  const voiceBase = baseLang(voice.lang)
  const reqNorm = requestedLang.trim().toLowerCase().replace('_', '-')
  const voiceNorm = voice.lang.trim().toLowerCase().replace('_', '-')

  let score: number
  if (reqNorm === voiceNorm) {
    score = 1000 // exact match
  } else if (reqBase === voiceBase) {
    score = 900 // same language, different region
  } else {
    const idx = buildLanguageCandidates(requestedLang).indexOf(voiceBase)
    if (idx < 0) return -Infinity
    score = 700 - idx * 25
  }

  const reqGender = detectGender(requestedVoiceName)
  const voiceGender = detectGender(`${voice.name} ${voice.voiceURI}`)
  if (
    reqGender !== Gender.Unknown &&
    voiceGender !== Gender.Unknown &&
    reqGender === voiceGender
  ) {
    score += 10
  }
  const wanted = requestedVoiceName.trim().toLowerCase()
  const actual = `${voice.name} ${voice.voiceURI}`.trim().toLowerCase()
  if (wanted && actual.includes(wanted)) score += 8
  if (voice.default) score += 3
  if (voice.localService) score += 2
  return score
}

function getVoice(lang: string, voice: string) {
  if (voice.startsWith('Deutsch')) {
    voice = voice.replace('Deutsch', 'German')
  }

  const key = toKey(lang, voice)
  if (browserVoices[key]) {
    return browserVoices[key]
  }

  const voices = EasySpeech.voices()
  if (!voices || voices.length === 0) {
    return null
  }

  const normalizedLang = lang
  let bestFit: SpeechSynthesisVoice | null = null
  let bestScore = -Infinity

  const results: {
    name: string
    lang: string
    normalizedLang: string
    score: number
    gender: string
    default: boolean
  }[] = []

  for (const v of voices) {
    const score = scoreVoice(normalizedLang, voice, v)

    results.push({
      name: v.name,
      lang: v.lang,
      normalizedLang: baseLang(v.lang),
      score,
      gender: Gender[detectGender(`${v.name} ${v.voiceURI}`)],
      default: v.default,
    })

    if (score > bestScore) {
      bestScore = score
      bestFit = v
    }
  }

  results.sort((a, b) => b.score - a.score)
  console.group(`TTS voice selection: "${voice}" / "${lang}"`)
  console.log('Candidates:', buildLanguageCandidates(normalizedLang))
  console.table(results.slice(0, 10))
  console.log('Best match:', bestFit?.name ?? 'none', '(score:', bestScore, ')')
  console.groupEnd()

  if (bestFit) {
    browserVoices[key] = bestFit
  }

  return bestFit
}

function detectGender(voice: string) {
  // Check explicit gender indicators first
  if (voice.match(/female/i)) {
    return Gender.Female
  }

  if (voice.match(/male/i)) {
    return Gender.Male
  }

  // iOS/Safari male voices
  const maleVoices =
    /\b(Albert|Daniel|Eddy|Fred|Grandpa|Jacques|Junior|Maged|Ralph|Reed|Rishi|Rocko|Thomas|Zarvox|Xander)\b/i
  if (voice.match(maleVoices)) {
    return Gender.Male
  }

  // iOS/Safari female voices - comprehensive list
  const femaleVoices =
    /\b(Alice|Alva|Amelie|Amira|Anna|Carmit|Damayanti|Daria|Ellen|Grandma|Ioana|Joana|Kanya|Karen|Kathy|Kyoko|Lana|Laura|Lekha|Lesya|Linh|Luciana|Mariska|Meijia|Melina|Milena|Moira|Monica|Montserrat|Nora|Paulina|Princess|Samantha|Sandy|Sara|Satu|Shelley|Tessa|Tina|Tingting|Yelda|Yuna|Zosia|Zuzana)\b/i
  if (voice.match(femaleVoices)) {
    return Gender.Female
  }

  // Additional generic gender detection for other voices
  if (voice.match(/\b(man|boy|guy|sir|mr\.?|he|him)\b/i)) {
    return Gender.Male
  }

  if (voice.match(/\b(woman|girl|lady|ms\.?|mrs\.?|miss|she|her)\b/i)) {
    return Gender.Female
  }

  // Neutral or non-human voices: Bahh, Bells, Flo, Sinji, Trinoids
  return Gender.Unknown
}

function storeBackgroundVideo(player: HTMLElement, video: HTMLVideoElement) {
  try {
    const background = video.cloneNode(true) as HTMLVideoElement

    background.addEventListener('durationchange', () => {
      if (isFinite(background.duration) && background.duration > 0) {
        background.currentTime = background.duration
      }
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
  } catch (e: any) {
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
  const wordCount = text.split(/\s+/).filter(word => word.length > 0).length

  // Add some padding (10%) for pauses and processing
  const durationSeconds = (wordCount / adjustedWPM) * 60 * 1.1

  // Ensure minimum duration
  return Math.max(2, durationSeconds)
}

export default Service
