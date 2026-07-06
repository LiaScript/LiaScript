import { CommentMediaController } from './Controller'
import { HtmlMediaController } from './HtmlMediaController'
import { YouTubeController } from './YouTubeController'
import { VimeoController } from './VimeoController'
import { GenericIframeController } from './GenericIframeController'

export { CommentMediaController } from './Controller'
export { parseTimeFragment } from './HtmlMediaController'

/**
 * Build a controller for a single comment-video element inside `#lia-tts-videos`.
 *
 * - `<video>` → HtmlMediaController (direct file, full sync).
 * - `div.lia-tts-embed[data-embed-provider]` → provider adapter.
 *
 * Returns null for unsupported embed providers.
 */
export function createController(
  el: Element
): CommentMediaController | null {
  if (el.tagName === 'VIDEO') {
    return new HtmlMediaController(el as HTMLVideoElement)
  }

  if (
    el instanceof HTMLElement &&
    el.classList.contains('lia-tts-embed')
  ) {
    const provider = el.getAttribute('data-embed-provider') || 'generic'
    const url = el.getAttribute('data-embed-url') || ''

    switch (provider) {
      case 'youtube':
        return new YouTubeController(el, url)

      case 'vimeo':
        return new VimeoController(el, url)

      default:
        return new GenericIframeController(el, url)
    }
  }

  return null
}

/** Build controllers for every child of the player container, skipping unsupported ones. */
export function createControllers(
  player: HTMLElement
): CommentMediaController[] {
  const controllers: CommentMediaController[] = []
  for (const child of Array.from(player.children)) {
    const c = createController(child)
    if (c) controllers.push(c)
  }
  return controllers
}
