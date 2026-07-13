import { CommentMediaController, MediaCapabilities } from './Controller'
import { parseTimeFragment } from './HtmlMediaController'

/**
 * Controller for a YouTube comment video, driven through the YouTube IFrame
 * Player API. The Elm view renders an empty placeholder `<div>` (with
 * `data-embed-url`); this adapter loads the API once, mounts a player into the
 * placeholder and maps the common interface onto the YT player methods.
 */

// Minimal ambient typing for the YT IFrame API surface we use.
declare global {
  interface Window {
    YT?: any
    onYouTubeIframeAPIReady?: () => void
  }
}

const YT_API_SRC = 'https://www.youtube.com/iframe_api'
const ENDED = 0 // YT.PlayerState.ENDED

let apiReady: Promise<void> | null = null

function loadApi(): Promise<void> {
  if (apiReady) return apiReady

  apiReady = new Promise<void>((resolve) => {
    if (window.YT && window.YT.Player) {
      resolve()
      return
    }

    // Chain onto any previously-registered ready handler.
    const prev = window.onYouTubeIframeAPIReady
    window.onYouTubeIframeAPIReady = () => {
      if (prev) {
        try {
          prev()
        } catch (e) {}
      }
      resolve()
    }

    if (!document.querySelector(`script[src="${YT_API_SRC}"]`)) {
      const script = document.createElement('script')
      script.src = YT_API_SRC
      script.async = true
      document.head.appendChild(script)
    }
  })

  return apiReady
}

/** Extract the YouTube video id from an embed URL (…/embed/VIDEO_ID?…). */
function extractVideoId(url: string): string | null {
  const m = url.match(/\/embed\/([^?&#/]+)/)
  return m ? m[1] : null
}

/** Read a numeric query param (e.g. start / end) from the embed URL. */
function numParam(url: string, name: string): number | null {
  try {
    const q = url.split('?')[1]
    if (!q) return null
    const params = new URLSearchParams(q)
    const v = params.get(name)
    if (v === null) return null
    const n = parseFloat(v)
    return isNaN(n) ? null : n
  } catch (e) {
    return null
  }
}

export class YouTubeController implements CommentMediaController {
  readonly capabilities: MediaCapabilities = {
    duration: true,
    seek: true,
    rate: true, // discrete steps only
    mute: true,
  }
  readonly isHtmlMedia = false
  readonly mediaElement = null

  private container: HTMLElement
  private videoId: string
  private startAt: number | null
  private endAt: number | null
  private player: any = null
  private ready: Promise<void>
  private endedCb: (() => void) | null = null
  private errorCb: ((err: any) => void) | null = null
  private endWatcher: ReturnType<typeof setInterval> | null = null
  private pendingRate: number | null = null
  private pendingMuted: boolean | null = null

  constructor(container: HTMLElement, embedUrl: string) {
    this.container = container
    this.videoId = extractVideoId(embedUrl) || ''

    // `?start=`/`?end=` (YouTube player params) take precedence; fall back to
    // the Media Fragments `#t=start,end` convention used by direct video files.
    const frag = parseTimeFragment(embedUrl)
    this.startAt = numParam(embedUrl, 'start') ?? frag.start
    this.endAt = numParam(embedUrl, 'end') ?? frag.end

    this.ready = this.mount()
  }

  private mount(): Promise<void> {
    return loadApi().then(
      () =>
        new Promise<void>((resolve) => {
          // Start from a clean container.
          while (this.container.firstChild) {
            this.container.removeChild(this.container.firstChild)
          }

          // Anchor the clip box to the placeholder.
          this.container.style.position = 'absolute'
          this.container.style.top = '0'
          this.container.style.left = '0'
          this.container.style.width = '100%'
          this.container.style.height = '100%'
          
          const mountPoint = document.createElement('div')
          mountPoint.style.position = 'absolute'
          mountPoint.style.top = '0'
          mountPoint.style.left = '0'
          mountPoint.style.width = '100%'
          mountPoint.style.height = '100%'
          mountPoint.style.overflow = 'hidden'
          this.container.appendChild(mountPoint)

          const inner = document.createElement('div')
          mountPoint.appendChild(inner)

          this.player = new window.YT.Player(inner, {
            videoId: this.videoId,
            playerVars: {
              autoplay: 0,
              controls: 0,
              modestbranding: 1,
              rel: 0,
              playsinline: 1,
              start: this.startAt ?? undefined,
              end: this.endAt ?? undefined,
            },
            events: {
              onReady: () => {
                this.coverContainer()
                if (this.pendingRate !== null) {
                  this.applyRate(this.pendingRate)
                  this.pendingRate = null
                }
                if (this.pendingMuted !== null) {
                  this.applyMuted(this.pendingMuted)
                  this.pendingMuted = null
                }
                resolve()
              },
              onStateChange: (e: any) => {
                if (e.data === ENDED && this.endedCb) this.endedCb()
              },
              onError: (e: any) => {
                if (this.errorCb) this.errorCb(e?.data ?? 'youtube error')
              },
            },
          })
        })
    )
  }

  /**
   * Cover the (circular) comment container with the YouTube iframe. Over-sizing
   * the height to 177.78% (16:9) and centering it both fills the box AND pushes
   * YouTube's top title strip above the visible area, where the mountPoint's
   * `overflow:hidden` crops it off.
   */
  private coverContainer(): void {
    const iframe = this.container.querySelector('iframe')
    if (!iframe) return
    iframe.style.position = 'absolute'
    iframe.style.top = '50%'
    iframe.style.left = '50%'
    iframe.style.transform = 'translate(-50%, -50%)'
    iframe.style.width = '100%'
    iframe.style.height = '177.78%'
    iframe.style.minWidth = '100%'
    iframe.style.minHeight = '100%'
    // Blocking pointer events stops YouTube's hover chrome (title bar / controls) from appearing.
    iframe.style.pointerEvents = 'none'
    iframe.setAttribute('width', '')
    iframe.setAttribute('height', '')
  }

  private applyRate(rate: number): void {
    try {
      const available: number[] = this.player.getAvailablePlaybackRates?.() || [
        1,
      ]
      // Snap to the closest allowed discrete rate.
      const closest = available.reduce((best, r) =>
        Math.abs(r - rate) < Math.abs(best - rate) ? r : best
      )
      this.player.setPlaybackRate(closest)
    } catch (e) {
      console.warn('YouTube setPlaybackRate failed:', e)
    }
  }

  play(): Promise<void> {
    return this.ready.then(() => {
      try {
        this.player.playVideo()
      } catch (e) {
        console.warn('YouTube playVideo failed:', e)
      }
    })
  }

  pause(): void {
    try {
      this.player?.pauseVideo()
    } catch (e) {}
  }

  isPaused(): boolean {
    try {
      // 1 = PLAYING, 3 = BUFFERING
      const s = this.player?.getPlayerState?.()
      return s !== 1 && s !== 3
    } catch (e) {
      return true
    }
  }

  seek(seconds: number): void {
    try {
      this.player?.seekTo((this.startAt ?? 0) + seconds, true)
    } catch (e) {}
  }

  getCurrentTime(): number {
    try {
      const t = this.player?.getCurrentTime?.() || 0
      return this.startAt !== null ? Math.max(0, t - this.startAt) : t
    } catch (e) {
      return 0
    }
  }

  getDuration(): number | null {
    if (this.endAt !== null) {
      return this.endAt - (this.startAt ?? 0)
    }
    try {
      const d = this.player?.getDuration?.()
      return isFinite(d) && d > 0 ? d : null
    } catch (e) {
      return null
    }
  }

  setPlaybackRate(rate: number): void {
    if (!this.player || !this.player.setPlaybackRate) {
      this.pendingRate = rate
      return
    }
    this.applyRate(rate)
  }

  private applyMuted(muted: boolean): void {
    try {
      if (muted) this.player.mute()
      else this.player.unMute()
    } catch (e) {
      console.warn('YouTube setMuted failed:', e)
    }
  }

  setMuted(muted: boolean): void {
    // The player may not be ready yet. So defer the mute until ready.
    if (!this.player || !this.player.mute) {
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
      this.player?.stopVideo?.()
      this.player?.seekTo?.(this.startAt ?? 0, true)
    } catch (e) {}
  }

  destroy(): void {
    if (this.endWatcher) {
      clearInterval(this.endWatcher)
      this.endWatcher = null
    }
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
