/**
 * Shared sizing/teardown helpers for the iframe comment-video adapters
 * (YouTube, Vimeo, generic).
 */

/** Cover-crop: over-size both axes (16:9) and center, cropping the overflow. */
export function coverIframe(
  iframe: HTMLIFrameElement,
  opts: { pointerEvents?: 'none' | 'auto' } = {}
): void {
  centerAbsolute(iframe)
  iframe.style.width = '177.78%'
  iframe.style.height = '177.78%'
  iframe.style.minWidth = '100%'
  iframe.style.minHeight = '100%'
  if (opts.pointerEvents) iframe.style.pointerEvents = opts.pointerEvents
  clearSizeAttrs(iframe)
}

/** Contain-fit: letterboxed, never mis-cropped (non-16:9 players). */
export function containIframe(
  iframe: HTMLIFrameElement,
  opts: { pointerEvents?: 'none' | 'auto' } = {}
): void {
  centerAbsolute(iframe)
  iframe.style.width = '177.78%'
  iframe.style.height = '56.25%'
  if (opts.pointerEvents) iframe.style.pointerEvents = opts.pointerEvents
  clearSizeAttrs(iframe)
}

function centerAbsolute(el: HTMLElement): void {
  el.style.position = 'absolute'
  el.style.top = '50%'
  el.style.left = '50%'
  el.style.transform = 'translate(-50%, -50%)'
}

function clearSizeAttrs(iframe: HTMLIFrameElement): void {
  iframe.setAttribute('width', '')
  iframe.setAttribute('height', '')
}

/** Remove every child of a container. */
export function clearContainer(container: HTMLElement): void {
  while (container.firstChild) {
    container.removeChild(container.firstChild)
  }
}
