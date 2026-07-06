import { CommentMediaController, MediaCapabilities } from './Controller'

/**
 * Controller for a direct-file comment video, wrapping an `<video>`
 * (HTMLMediaElement). This preserves the original TTS.ts behaviour: time
 * fragments (`#t=start,end`), preservesPitch, durationchange-based progress and
 * the per-clip "ended" handler.
 */
export class HtmlMediaController implements CommentMediaController {
  readonly capabilities: MediaCapabilities = {
    duration: true,
    seek: true,
    rate: true,
    mute: true,
  }
  readonly isHtmlMedia = true

  private el: HTMLVideoElement
  private endedCb: (() => void) | null = null
  private errorCb: ((err: any) => void) | null = null
  private fragmentEnd: number | null = null
  private fragmentStart: number | null = null
  private timeUpdateHandler: (() => void) | null = null

  constructor(el: HTMLVideoElement) {
    this.el = el

    const frag = parseTimeFragment(el.src)
    this.fragmentStart = frag.start
    this.fragmentEnd = frag.end

    el.onended = () => {
      if (this.endedCb) this.endedCb()
    }

    el.onerror = () => {
      if (this.errorCb) this.errorCb(el.error)
    }

    // Stop at the fragment end and emit a synthetic "ended".
    if (this.fragmentEnd !== null) {
      this.timeUpdateHandler = () => {
        if (this.el.currentTime >= this.fragmentEnd!) {
          this.el.pause()
          if (this.timeUpdateHandler) {
            this.el.removeEventListener('timeupdate', this.timeUpdateHandler)
            this.timeUpdateHandler = null
          }
          if (this.endedCb) this.endedCb()
        }
      }
      el.addEventListener('timeupdate', this.timeUpdateHandler)
    }
  }

  get mediaElement(): HTMLMediaElement {
    return this.el
  }

  play(): Promise<void> {
    const t = this.el.currentTime || 0
    const outsideFragment =
      (this.fragmentStart !== null && t < this.fragmentStart) ||
      (this.fragmentEnd !== null && t >= this.fragmentEnd)
    if (outsideFragment) {
      this.el.currentTime = this.fragmentStart ?? 0
    }
    this.el.preservesPitch = true
    const r = this.el.play()
    return r ?? Promise.resolve()
  }

  pause(): void {
    this.el.pause()
  }

  isPaused(): boolean {
    return this.el.paused
  }

  seek(seconds: number): void {
    this.el.currentTime = (this.fragmentStart ?? 0) + seconds
  }

  getCurrentTime(): number {
    const t = this.el.currentTime || 0
    return this.fragmentStart !== null ? Math.max(0, t - this.fragmentStart) : t
  }

  getDuration(): number | null {
    if (this.fragmentEnd !== null) {
      return this.fragmentEnd - (this.fragmentStart ?? 0)
    }
    return isFinite(this.el.duration) && this.el.duration > 0
      ? this.el.duration
      : null
  }

  setPlaybackRate(rate: number): void {
    this.el.preservesPitch = true
    this.el.playbackRate = rate
  }

  setMuted(muted: boolean): void {
    this.el.muted = muted
  }

  setVisible(visible: boolean): void {
    this.el.style.display = visible ? 'block' : 'none'
  }

  onEnded(cb: () => void): void {
    this.endedCb = cb
  }

  onError(cb: (err: any) => void): void {
    this.errorCb = cb
  }

  reset(): void {
    this.el.pause()
    this.el.currentTime = 0
    this.el.load()
  }

  destroy(): void {
    if (this.timeUpdateHandler) {
      this.el.removeEventListener('timeupdate', this.timeUpdateHandler)
      this.timeUpdateHandler = null
    }
    this.el.onended = null
    this.el.onerror = null
    this.endedCb = null
    this.errorCb = null
  }
}

export function parseTimeFragment(url: string): {
  start: number | null
  end: number | null
} {
  const result: { start: number | null; end: number | null } = {
    start: null,
    end: null,
  }

  try {
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
