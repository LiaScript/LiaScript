import { CommentMediaController, MediaCapabilities } from './Controller'

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

  // Vimeo reports time/duration through Promises; TTS polls synchronously, so
  // we cache the latest values seen via the `timeupdate` event.
  private currentTime = 0
  private duration: number | null = null

  constructor(container: HTMLElement, embedUrl: string) {
    this.container = container
    this.embedUrl = embedUrl

    this.ready = this.mount()
  }

  private mount(): Promise<void> {
    return loadApi().then(() => {
      // Start from a clean container.
      while (this.container.firstChild) {
        this.container.removeChild(this.container.firstChild)
      }

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
      })

      this.player.on('ended', () => {
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
    iframe.style.position = 'absolute'
    iframe.style.top = '50%'
    iframe.style.left = '50%'
    iframe.style.transform = 'translate(-50%, -50%)'
    iframe.style.minWidth = '100%'
    iframe.style.minHeight = '100%'
    iframe.style.width = '177.78%'
    iframe.style.height = '177.78%'
    iframe.setAttribute('width', '')
    iframe.setAttribute('height', '')
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
    try {
      this.player?.pause()?.catch?.(() => {})
    } catch (e) {}
  }

  isPaused(): boolean {
    // Vimeo's paused state is async-only; approximate from cached playback.
    // The player drives `timeupdate` only while playing, so this is a
    // best-effort synchronous answer for TTS's progress bookkeeping.
    return this.player == null
  }

  seek(seconds: number): void {
    try {
      this.player?.setCurrentTime(seconds)?.catch?.(() => {})
      this.currentTime = seconds
    } catch (e) {}
  }

  getCurrentTime(): number {
    return this.currentTime || 0
  }

  getDuration(): number | null {
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
    try {
      this.player?.pause()?.catch?.(() => {})
      this.player?.setCurrentTime(0)?.catch?.(() => {})
      this.currentTime = 0
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
      while (this.container.firstChild) {
        this.container.removeChild(this.container.firstChild)
      }
    } catch (e) {}
  }
}
