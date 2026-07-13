import { CommentMediaController, MediaCapabilities } from './Controller'
import { parseTimeFragment } from './HtmlMediaController'
import { coverIframe, clearContainer } from './iframe-utils'

/**
 * Controller for a Vimeo comment video, driven through the Vimeo Player SDK.
 * The Elm view renders an empty placeholder `<div>` (with `data-embed-url`);
 * this adapter loads the SDK once, mounts a player into the placeholder and
 * maps the common interface onto the Vimeo `Player` methods.
 *
 * Unlike YouTube, Vimeo exposes continuous playback rates and a Promise-based
 * API, so it gets full sync capabilities. The SDK reports time/duration
 * asynchronously, so we keep a cached current-time updated on `timeupdate`
 * (TTS.ts polls `getCurrentTime()` synchronously).
 */

// Minimal ambient typing for the Vimeo SDK surface we use.
declare global {
  interface Window {
    Vimeo?: any
  }
}

const VIMEO_API_SRC = 'https://player.vimeo.com/api/player.js'

let apiReady: Promise<void> | null = null

function loadApi(): Promise<void> {
  if (apiReady) return apiReady

  apiReady = new Promise<void>((resolve, reject) => {
    if (window.Vimeo && window.Vimeo.Player) {
      resolve()
      return
    }

    const existing = document.querySelector(
      `script[src="${VIMEO_API_SRC}"]`
    ) as HTMLScriptElement | null

    if (existing) {
      existing.addEventListener('load', () => resolve())
      existing.addEventListener('error', () =>
        reject(new Error('Vimeo SDK failed to load'))
      )
      return
    }

    const script = document.createElement('script')
    script.src = VIMEO_API_SRC
    script.async = true
    script.onload = () => resolve()
    script.onerror = () => reject(new Error('Vimeo SDK failed to load'))
    document.head.appendChild(script)
  })

  return apiReady
}

/** Extract the Vimeo video id from an embed URL (…/video/VIDEO_ID?…). */
function extractVideoId(url: string): string | null {
  const m = url.match(/\/video\/(\d+)/)
  return m ? m[1] : null
}

export class VimeoController implements CommentMediaController {
  readonly capabilities: MediaCapabilities = {
    duration: true,
    seek: true,
    rate: true,
    mute: true,
  }
  readonly isHtmlMedia = false
  readonly mediaElement = null

  private container: HTMLElement
  private embedUrl: string
  private player: any = null
  private ready: Promise<void>
  private endedCb: (() => void) | null = null
  private errorCb: ((err: any) => void) | null = null
  private pendingRate: number | null = null
  private pendingMuted: boolean | null = null
  private startAt: number | null
  private endAt: number | null
  private endedFired = false

  // Vimeo reports time/duration/paused through Promises; TTS polls
  // synchronously, so we cache the latest values seen via the SDK events.
  private currentTime = 0
  private duration: number | null = null
  private paused = true

  constructor(container: HTMLElement, embedUrl: string) {
    this.container = container
    this.embedUrl = embedUrl

    const frag = parseTimeFragment(embedUrl)
    this.startAt = frag.start
    this.endAt = frag.end

    this.ready = this.mount()
  }

  private mount(): Promise<void> {
    return loadApi().then(() => {
      // Start from a clean container.
      clearContainer(this.container)

      // A dedicated child element so we never wipe the placeholder's attrs.
      const mountPoint = document.createElement('div')
      mountPoint.style.width = '100%'
      mountPoint.style.height = '100%'
      mountPoint.style.position = 'relative'
      mountPoint.style.overflow = 'hidden'
      this.container.appendChild(mountPoint)

      const videoId = extractVideoId(this.embedUrl)

      // Vimeo's SDK serializes the options object into its oembed request, so
      // pass EITHER `id` (numeric) OR `url` — never both.
      const options: any = {
        autoplay: false,
        controls: false,
      }
      if (videoId) options.id = Number(videoId)
      else options.url = this.embedUrl

      this.player = new window.Vimeo.Player(mountPoint, options)

      this.coverContainer(mountPoint)

      this.player.on('timeupdate', (data: any) => {
        if (typeof data?.seconds === 'number') this.currentTime = data.seconds
        if (typeof data?.duration === 'number') this.duration = data.duration

        // Stop at the fragment end and emit a synthetic "ended", since Vimeo
        // only fires its own 'ended' event at the actual end of the file.
        if (
          this.endAt !== null &&
          !this.endedFired &&
          this.currentTime >= this.endAt
        ) {
          this.endedFired = true
          this.pause()
          if (this.endedCb) this.endedCb()
        }
      })

      this.player.on('play', () => {
        this.paused = false
      })
      this.player.on('pause', () => {
        this.paused = true
      })

      this.player.on('ended', () => {
        this.paused = true
        if (this.endedCb) this.endedCb()
      })

      this.player.on('error', (err: any) => {
        if (this.errorCb) this.errorCb(err)
      })

      return this.player.ready().then(() => {
        // Re-apply in case the iframe wasn't present synchronously at construct.
        this.coverContainer(mountPoint)
        return this.player
          .getDuration()
          .then((d: number) => {
            if (isFinite(d) && d > 0) this.duration = d
          })
          .catch(() => {})
          .then(() => {
            if (this.pendingRate !== null) {
              this.applyRate(this.pendingRate)
              this.pendingRate = null
            }
            if (this.pendingMuted !== null) {
              this.applyMuted(this.pendingMuted)
              this.pendingMuted = null
            }
          })
      })
    })
  }

  /**
   * Make the Vimeo iframe cover the (circular) comment container instead of letterboxing.
   */
  private coverContainer(mountPoint: HTMLElement): void {
    const iframe = mountPoint.querySelector('iframe')
    if (!iframe) return
    coverIframe(iframe)
  }

  private applyRate(rate: number): void {
    try {
      // Vimeo accepts continuous rates in [0.5, 2].
      const clamped = Math.max(0.5, Math.min(2, rate))
      this.player.setPlaybackRate(clamped).catch(() => {})
    } catch (e) {
      console.warn('Vimeo setPlaybackRate failed:', e)
    }
  }

  private applyMuted(muted: boolean): void {
    try {
      this.player.setMuted(muted).catch(() => {})
    } catch (e) {
      console.warn('Vimeo setMuted failed:', e)
    }
  }

  play(): Promise<void> {
    return this.ready.then(() => {
      try {
        const t = this.currentTime || 0
        const outsideFragment =
          (this.startAt !== null && t < this.startAt) ||
          (this.endAt !== null && t >= this.endAt)
        if (outsideFragment) {
          this.endedFired = false
          this.player.setCurrentTime(this.startAt ?? 0).catch(() => {})
        }
        this.paused = false
        const r = this.player.play()
        return r && typeof r.catch === 'function'
          ? r.catch((e: any) => {
              console.warn('Vimeo play failed:', e)
            })
          : undefined
      } catch (e) {
        console.warn('Vimeo play failed:', e)
      }
    })
  }

  pause(): void {
    this.paused = true
    try {
      this.player?.pause()?.catch?.(() => {})
    } catch (e) {}
  }

  isPaused(): boolean {
    // Vimeo's paused state is async-only, so we track it synchronously from the
    // SDK's play/pause events and our own play()/pause() calls.
    return this.player == null || this.paused
  }

  seek(seconds: number): void {
    try {
      const absolute = (this.startAt ?? 0) + seconds
      this.player?.setCurrentTime(absolute)?.catch?.(() => {})
      this.currentTime = absolute
      this.endedFired = false
    } catch (e) {}
  }

  getCurrentTime(): number {
    const t = this.currentTime || 0
    return this.startAt !== null ? Math.max(0, t - this.startAt) : t
  }

  getDuration(): number | null {
    if (this.endAt !== null) {
      return this.endAt - (this.startAt ?? 0)
    }
    return this.duration !== null && isFinite(this.duration) && this.duration > 0
      ? this.duration
      : null
  }

  setPlaybackRate(rate: number): void {
    if (!this.player) {
      this.pendingRate = rate
      return
    }
    this.applyRate(rate)
  }

  setMuted(muted: boolean): void {
    if (!this.player) {
      this.pendingMuted = muted
      return
    }
    this.applyMuted(muted)
  }

  setVisible(visible: boolean): void {
    this.container.style.display = visible ? 'block' : 'none'
  }

  onEnded(cb: () => void): void {
    this.endedCb = cb
  }

  onError(cb: (err: any) => void): void {
    this.errorCb = cb
  }

  reset(): void {
    this.paused = true
    try {
      this.player?.pause()?.catch?.(() => {})
      this.player?.setCurrentTime(this.startAt ?? 0)?.catch?.(() => {})
      this.currentTime = this.startAt ?? 0
      this.endedFired = false
    } catch (e) {}
  }

  destroy(): void {
    try {
      this.player?.destroy?.()
    } catch (e) {}
    this.player = null
    this.endedCb = null
    this.errorCb = null
    // Remove any leftover mount point / iframe so a fresh controller built on
    // the same placeholder starts from a clean container.
    try {
      clearContainer(this.container)
    } catch (e) {}
  }
}
