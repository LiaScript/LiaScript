/**
 * Abstraction over a single comment-video player.
 *
 * Spoken-comment videos historically are `HTMLMediaElement`s (direct .mp4/.webm
 * files), which TTS.ts drives directly (play/pause/seek/rate/muted + media
 * events). Embeddable platform videos (YouTube, Vimeo, …) are iframes that do
 * NOT expose the media-element API, so each provider needs its own adapter
 * behind this common interface.
 *
 * `capabilities` lets the caller degrade gracefully: a provider that cannot
 * report duration returns `getDuration() === null` and `capabilities.duration
 * === false`, which disables TTS rate-matching, seeking and progress reporting
 * for that clip.
 */
export interface MediaCapabilities {
  duration: boolean
  seek: boolean
  rate: boolean
  mute: boolean
}

export interface CommentMediaController {
  /** Begin (or resume) playback. */
  play(): Promise<void>

  /** Pause playback without resetting position. */
  pause(): void

  /** Whether playback is currently paused. */
  isPaused(): boolean

  /** Seek to an absolute time in seconds (no-op if `capabilities.seek` is false). */
  seek(seconds: number): void

  /** Current playback position in seconds (0 if unknown). */
  getCurrentTime(): number

  /** Total duration in seconds, or null if unknown/not reportable. */
  getDuration(): number | null

  /** Set playback rate (no-op / best-effort where unsupported). */
  setPlaybackRate(rate: number): void

  /** Mute or unmute (used for translation mode). */
  setMuted(muted: boolean): void

  /** Show/hide this player within the comment overlay. */
  setVisible(visible: boolean): void

  /** Register the "playback finished" callback. Replaces any previous one. */
  onEnded(cb: () => void): void

  /** Register an error callback. */
  onError(cb: (err: any) => void): void

  /** Reset position to 0 and stop. */
  reset(): void

  /** What this provider can actually do. */
  readonly capabilities: MediaCapabilities

  /** True for direct HTMLMediaElement players (enables background-frame preview). */
  readonly isHtmlMedia: boolean

  /** The underlying HTMLMediaElement, if this is a direct-file player. */
  readonly mediaElement: HTMLMediaElement | null

  /** Tear down listeners / players. */
  destroy(): void
}
