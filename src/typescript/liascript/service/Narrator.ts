/**
 * Narrator hook for external templates.
 *
 * The TTS service reads narrator comments (`--{{n}}--`) either with a speech
 * synthesis, or plays their audio or video recordings. This module publishes
 * what is currently spoken, such that templates can react on it, e.g. by
 * animating an avatar:
 *
 * ```js
 * window.addEventListener('lia-narrator', (e) => console.log(e.detail))
 * ```
 *
 * Additionally, a template can register a custom element as narrator avatar.
 * LiaScript renders it within the draggable overlay of the video comments,
 * whenever the current animation step has comments, but no video recordings:
 *
 * ```js
 * customElements.define('my-avatar', class extends HTMLElement { ... })
 * window.LIA.narrator.registerAvatar('my-avatar')
 * ```
 *
 * The element gets the narrator (`data-voice`), the animation step
 * (`data-step`) and all `data-*` annotations of the current comments, e.g.
 * `<!-- data-speaker="anna" -->` in front of `--{{1}}--`, as attributes.
 */

export const EVENT = 'lia-narrator'

export type Source = 'tts' | 'audio' | 'video'

export type Status = 'idle' | 'speaking' | 'paused'

export type EventType =
  | 'start'
  | 'stop'
  | 'pause'
  | 'resume'
  | 'boundary'
  | 'progress'
  | 'media'
  | 'error'

export type State = {
  status: Status
  source: Source | null
  /** class of the comments, e.g. `lia-tts-3`, `null` for inline playback */
  id: string | null
  /** the comment elements that are read out */
  elements: HTMLElement[]
  text: string
  voice: string
  lang: string
  /** the course is translated and the comments are read in another language */
  translated: boolean
  /** the audio or video element, that is currently played */
  media: HTMLMediaElement | null
}

export type Detail = State & {
  type: EventType
  /** word boundaries of the speech synthesis */
  charIndex?: number
  charLength?: number
  /** progress of audio or video recordings in seconds */
  current?: number
  total?: number
  error?: string
}

type Context = Omit<State, 'status' | 'media'>

const IDLE: Context = {
  source: null,
  id: null,
  elements: [],
  text: '',
  voice: '',
  lang: '',
  translated: false,
}

let context: Context = IDLE
let status: Status = 'idle'
let media: HTMLMediaElement | null = null

// The event that started the current playback. Late responses of a previous,
// already canceled playback (e.g. an 'end' of a canceled utterance) must not
// stop the current one.
let owner: object | null = null
const started = new WeakSet<object>()

let elmSend: ((tag: string | null) => void) | null = null
let avatar: string | null | undefined = undefined

function state(): State {
  return { ...context, status, media }
}

function dispatch(type: EventType, extra: Partial<Detail> = {}) {
  try {
    window.dispatchEvent(
      new CustomEvent<Detail>(EVENT, { detail: { ...state(), ...extra, type } })
    )
  } catch (e) {
    console.warn('Narrator: failed to dispatch', type, e)
  }
}

/**
 * Define what is about to be spoken, called before the playback starts.
 */
export function begin(
  event: object,
  ctx: Partial<Context> & { source: Source }
) {
  owner = event
  started.add(event)
  context = { ...IDLE, ...ctx }
  media = null
}

/**
 * The audio or video element that is currently played has changed.
 */
export function setMedia(element: HTMLMediaElement | null) {
  if (media === element) return

  media = element
  if (status !== 'idle' && element) {
    dispatch('media')
  }
}

export function boundary(charIndex: number, charLength?: number) {
  if (status === 'speaking') {
    dispatch('boundary', { charIndex, charLength })
  }
}

export function stop() {
  if (status === 'idle') return

  status = 'idle'
  dispatch('stop')
  reset()
}

function reset() {
  context = IDLE
  media = null
  owner = null
}

/**
 * Translates the responses of the TTS service into narrator events. Responses
 * to a former playback are ignored.
 */
export function response(event: object, cmd: string, param: any) {
  if (started.has(event) && event !== owner) return

  switch (cmd) {
    case 'start': {
      if (status === 'speaking') return

      const type = status === 'paused' ? 'resume' : 'start'
      status = 'speaking'
      dispatch(type)
      break
    }

    case 'stop': {
      stop()
      break
    }

    case 'paused': {
      if (status !== 'speaking') return

      status = 'paused'
      dispatch('pause')
      break
    }

    case 'progress': {
      if (status === 'idle') return

      try {
        const { current, total } = JSON.parse(param)
        dispatch('progress', { current, total })
      } catch (e) {}
      break
    }

    case 'error': {
      if (status === 'idle') return

      status = 'idle'
      dispatch('error', { error: String(param) })
      reset()
      break
    }
  }
}

/**
 * Custom element names must contain a hyphen and start with a lowercase
 * letter, see https://html.spec.whatwg.org/#valid-custom-element-name
 */
function isCustomElementName(tag: string) {
  return /^[a-z][a-z0-9._-]*-[a-z0-9._-]*$/.test(tag)
}

export function registerAvatar(tag: string | null) {
  if (tag !== null && !isCustomElementName(tag)) {
    console.warn('Narrator: avatar has to be a custom element name ->', tag)
    return
  }

  avatar = tag
  if (elmSend) {
    elmSend(tag)
  }
}

/**
 * Connect to the internal LiaScript, a previously registered avatar is send
 * directly.
 */
export function init(send: (tag: string | null) => void) {
  elmSend = send

  if (avatar !== undefined) {
    send(avatar)
  }
}

/**
 * Public interface, accessible via `window.LIA.narrator`.
 */
export const api = {
  EVENT,

  registerAvatar,

  get avatar() {
    return avatar || null
  },

  get state() {
    return state()
  },
}

export type API = typeof api
