import { Capacitor, registerPlugin } from '@capacitor/core'

// Native Capacitor TTS. Registered directly + typed locally because the git
// dependency ships no JS layer.

interface NativeTTSOptions {
  text: string
  lang?: string
  rate?: number
  pitch?: number
  volume?: number
  voice?: number
}

interface NativeTextToSpeechPlugin {
  speak(options: NativeTTSOptions): Promise<void>
  stop(): Promise<void>
  getSupportedVoices(): Promise<{ voices: SpeechSynthesisVoice[] }>
  // onRangeStart: start/end are char offsets into the utterance text.
  addListener(
    eventName: 'onRangeStart',
    listenerFunc: (info: { start: number; end: number; spokenWord: string }) => void
  ): Promise<{ remove: () => Promise<void> }>
}

type Handlers = {
  onStart: () => void
  onStop: () => void
  onError: (e: any) => void
}

const NativeTTS = registerPlugin<NativeTextToSpeechPlugin>('TextToSpeech')

export const isNative = Capacitor.isNativePlatform()

// Active native utterance. Pause = stop; resume re-speaks from `offset`
// (last word boundary), since Android TTS has no native pause/resume.
type NativeTTSState = {
  fullText: string
  options: { rate: number; pitch: number; lang: string }
  handlers: Handlers
  offset: number
  paused: boolean
  // Bumped on every speak() so a stale (paused/cancelled) promise can't fire.
  gen: number
} | null

var state: NativeTTSState = null
var rangeListenerAttached = false
// Char offset that onRangeStart values are relative to (start of current slice).
var base = 0

// True while a native utterance is active (speaking or paused).
export function nativeActive(): boolean {
  return state !== null
}

export function nativePaused(): boolean {
  return state !== null && state.paused
}

// Attaches the onRangeStart listener once; records the char offset of the
// currently spoken word (rebased onto the full text) so resume can continue.
function attachRangeListener() {
  if (rangeListenerAttached) return
  rangeListenerAttached = true
  NativeTTS.addListener('onRangeStart', (info) => {
    if (state && !state.paused) {
      state.offset = base + info.start
    }
  }).catch((e) => console.warn('TTS: onRangeStart listener failed', e))
}

export function nativeSpeak(
  text: string,
  lang: string,
  options: { rate: number; pitch: number },
  handlers: Handlers
) {
  attachRangeListener()
  state = {
    fullText: text,
    options: { rate: options.rate, pitch: options.pitch, lang: lang || 'en-US' },
    handlers,
    offset: 0,
    paused: false,
    gen: 0,
  }
  speakFrom(0)
}

// Speaks state.fullText starting at char `from`.
function speakFrom(from: number) {
  const s = state
  if (!s) return

  base = from
  s.offset = from
  s.paused = false
  const gen = ++s.gen
  // A stale promise (its speak() superseded by pause/cancel/resume) is ignored.
  const isCurrent = () => state === s && s.gen === gen

  s.handlers.onStart()

  NativeTTS.speak({
    text: s.fullText.slice(from),
    lang: s.options.lang,
    rate: s.options.rate,
    pitch: s.options.pitch,
    volume: 1.0,
  })
    .then(() => {
      // stop() rejects rather than resolves, so reaching here means the
      // utterance finished naturally.
      if (isCurrent()) {
        state = null
        s.handlers.onStop()
      }
    })
    .catch((e) => {
      if (!isCurrent()) return
      state = null
      s.handlers.onError(e)
    })
}

// Pauses by stopping; offset is preserved for resume. Returns false if nothing
// was speaking.
export function nativePause(): boolean {
  if (!state || state.paused) return false
  state.paused = true
  NativeTTS.stop().catch(() => {})
  return true
}

// Resumes from the last word boundary. Returns false if not paused.
export function nativeResume(): boolean {
  if (!state || !state.paused) return false
  speakFrom(state.offset)
  return true
}

export function nativeCancel() {
  state = null
  NativeTTS.stop().catch(() => {})
}
