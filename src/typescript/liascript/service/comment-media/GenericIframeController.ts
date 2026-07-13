import { CommentMediaController, MediaCapabilities } from './Controller'

/**
 * Best-effort controller for embeddable platform videos that expose no usable
 * JavaScript player API (Dailymotion, PeerTube, TeacherTube, TU-Freiberg, and
 * the unknown `generic` fallback). These are plain iframes, so we can only
 * influence them through the embed URL's query params.
 */

export class GenericIframeController implements CommentMediaController {
  readonly capabilities: MediaCapabilities = {
    duration: false,
    seek: false,
    rate: false,
    mute: false,
  }
  readonly isHtmlMedia = false
  readonly mediaElement = null

  private container: HTMLElement
  private embedUrl: string
  private provider: string
  private iframe: HTMLIFrameElement | null = null
  private endedCb: (() => void) | null = null
  private errorCb: ((err: any) => void) | null = null
  private started = false

  constructor(container: HTMLElement, embedUrl: string, provider: string = 'generic') {
    this.container = container
    this.embedUrl = embedUrl
    this.provider = provider
  }

  /** Build the embed URL with `autoplay=1` so it starts on mount. */
  private autoplayUrl(): string {
    try {
      const [base, query] = this.embedUrl.split('#')[0].split('?')
      const params = new URLSearchParams(query || '')
      params.set('autoplay', '1')
      const hash = this.embedUrl.includes('#')
        ? '#' + this.embedUrl.split('#').slice(1).join('#')
        : ''
      return `${base}?${params.toString()}${hash}`
    } catch (e) {
      return this.embedUrl
    }
  }

  private mount(): void {
    // Start from a clean container, anchored to the (circular) clip box.
    while (this.container.firstChild) {
      this.container.removeChild(this.container.firstChild)
    }
    this.container.style.position = 'absolute'
    this.container.style.top = '0'
    this.container.style.left = '0'
    this.container.style.width = '100%'
    this.container.style.height = '100%'
    this.container.style.overflow = 'hidden'

    const iframe = document.createElement('iframe')
    iframe.src = this.autoplayUrl()
    iframe.setAttribute('allow', 'autoplay; fullscreen')
    iframe.setAttribute('frameborder', '0')
    iframe.setAttribute('allowfullscreen', '')
    iframe.style.position = 'absolute'
    iframe.style.border = '0'

    // Dailymotion/PeerTube render a plain 16:9 frame, so cover-crop those
    // like the YouTube/Vimeo adapters. TeacherTube/TU-Freiberg (Video.js
    // players) aren't reliably 16:9, so cover-cropping misplaces their video —
    // contain-fit those (and any unknown generic embed) instead, accepting
    // letterboxing.
    const coverCrop = this.provider === 'dailymotion' || this.provider === 'peertube'
    iframe.style.top = '50%'
    iframe.style.left = '50%'
    iframe.style.transform = 'translate(-50%, -50%)'
    iframe.style.width = '177.78%'
    iframe.style.height = coverCrop ? '177.78%' : '56.25%'
    if (coverCrop) {
      iframe.style.minWidth = '100%'
      iframe.style.minHeight = '100%'
    }

    // TeacherTube/TU-Freiberg ignore the `autoplay` URL param, so the user
    // must click their native play button.
    const needsNativeClick = this.provider === 'teachertube' || this.provider === 'tu-freiberg'
    iframe.style.pointerEvents = needsNativeClick ? 'auto' : 'none'
    iframe.onerror = () => {
      if (this.errorCb) this.errorCb('iframe failed to load')
    }

    this.container.appendChild(iframe)
    this.iframe = iframe
  }

  play(): Promise<void> {
    // (Re)mount the iframe with autoplay; there is no resume API, so a second
    // call restarts the clip from the beginning.
    this.mount()
    this.started = true
    return Promise.resolve()
  }

  pause(): void {
    // No pause API — drop the iframe so the clip stops making sound.
    this.teardownIframe()
  }

  isPaused(): boolean {
    return !this.started || this.iframe === null
  }

  // No-ops: this provider exposes none of these controls.
  seek(_seconds: number): void {}

  getCurrentTime(): number {
    return 0
  }

  getDuration(): number | null {
    return null
  }

  setPlaybackRate(_rate: number): void {}

  setMuted(_muted: boolean): void {}

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
    this.teardownIframe()
    this.started = false
  }

  private teardownIframe(): void {
    if (this.iframe) {
      try {
        // Blank the src first to stop playback before removal.
        this.iframe.src = 'about:blank'
      } catch (e) {}
      try {
        this.iframe.remove()
      } catch (e) {}
      this.iframe = null
    }
  }

  destroy(): void {
    this.teardownIframe()
    this.endedCb = null
    this.errorCb = null
    try {
      while (this.container.firstChild) {
        this.container.removeChild(this.container.firstChild)
      }
    } catch (e) {}
  }
}
