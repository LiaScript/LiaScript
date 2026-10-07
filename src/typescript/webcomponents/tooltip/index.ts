// @ts-ignore
import * as EMBED from '../embed/index'
import * as PREVIEW from '../preview-lia'
import * as HTML from './html'

/**
 * Tooltips are presented in one single div that is attached to the very end of
 * the DOM, it is created on first use.
 */
const TOOLTIP_ID = 'lia-tooltip'

/**
 * Links to LiaScript courses, only the part after "/course/?..." is extracted
 * and only if it ends with ".md".
 *
 * TODO: URL-substitution as it is done internally by LiaScript has to be added
 */
const LIASCRIPT_PATTERN =
  /(?:https?:)(?:\/\/)liascript\.github\.io\/course\/\?(.+\.md)/i

/**
 * Wikimedia projects (Wikipedia, Wiktionary, ...) offer a summary API, the
 * groups are language, project and page title.
 */
const WIKIMEDIA_PATTERN =
  /\/\/([a-z-]+)(?:\.m)?\.(wikipedia|wiktionary|wikibooks|wikinews|wikiquote|wikisource|wikiversity|wikivoyage|wikimedia|wikidata)\.org\/wiki\/([^#?\s]+)/i

/** total width of the tooltip in px, including the padding */
const WIDTH = 455

/** time in ms to move the mouse from the link onto the tooltip */
const HIDE_DELAY = 300

/**
 * there is no fallback for tooltips, the card is cached and shown on the next
 * hover, so waiting longer for the slow proxy is fine
 */
const PROXY_TIMEOUT = 30000

type Meta = {
  title?: string
  description?: string
  image?: string
  image_alt?: string
}

/** one card per url, shared by all links, failed loads resolve to null */
const cards = new Map<string, Promise<HTMLElement | null>>()

let container: HTMLDivElement | undefined
let hideTimer = 0

/** the link that currently owns the tooltip, late loads of others are dropped */
let active: PreviewLink | null = null

/**
 * Tooltip-webcomponent, which is added to the HTML-DOM by:
 *
 * ```html
 * <preview-link src="url">
 *    <a href="url">...</a>
 * </preview-link>
 * ```
 *
 * The doubling of `src` and `href` is required, since the internal element can
 * also be something else. The property `light` switches between light and
 * dark mode.
 */
class PreviewLink extends HTMLElement {
  public light = true

  /**
   * set on click or tap, it prevents the next activation, which is triggered
   * when the focus returns from the opened tab
   */
  private clicked = false

  connectedCallback() {
    // listeners are bound to the element itself, so `this` is the PreviewLink
    // and adding them again on a reconnect is a no-op
    this.addEventListener('mouseenter', this.activate)
    this.addEventListener('focusin', this.activate)
    this.addEventListener('mouseleave', this.deactivate)
    this.addEventListener('focusout', this.deactivate)
    this.addEventListener('click', this.handleClick)
  }

  activate() {
    if (this.clicked) {
      this.clicked = false
      return
    }

    const src = this.getAttribute('src')?.replace(/\/$/, '')
    if (!src) return

    clearTimeout(hideTimer)
    active = this
    this.cursor('progress')

    load(src).then((card) => {
      this.cursor('')
      if (card && active === this) show(card, this)
    })
  }

  deactivate() {
    if (active === this) active = null
    this.cursor('')
    scheduleHide()
  }

  handleClick() {
    this.clicked = true
    this.deactivate()
    hide()
  }

  /** the inner link defines its own cursor, so it has to be set there */
  cursor(value: string) {
    const child = this.firstElementChild as HTMLElement | null
    if (child) child.style.cursor = value
  }
}

function load(url: string): Promise<HTMLElement | null> {
  // ponytail: failures stay cached as null, a reload retries
  if (!cards.has(url)) {
    cards.set(
      url,
      fetchMeta(url)
        .then((meta) => toCard(url, meta))
        .catch(() => null)
    )
  }
  return cards.get(url)!
}

/**
 * LiaScript courses are parsed directly, Wikimedia pages use their summary
 * API, everything else tries oEmbed first and then the page itself.
 */
function fetchMeta(url: string): Promise<Meta> {
  const lia = url.match(LIASCRIPT_PATTERN)
  if (lia) {
    return new Promise((resolve, reject) =>
      PREVIEW.fetch(
        lia[1],
        (_, meta) =>
          resolve({
            title: meta.title,
            description: meta.description,
            image: meta.logo,
            image_alt: meta.logo_alt,
          }),
        reject
      )
    )
  }

  const page = () =>
    EMBED.extract(url, {})
      .then((data) => ({ title: data.title, image: data.thumbnail_url }))
      .catch(() =>
        EMBED.fetchText(url, true, PROXY_TIMEOUT).then((html) =>
          HTML.parse(url, html)
        )
      )

  const wiki = url.match(WIKIMEDIA_PATTERN)
  return wiki ? wikimedia(wiki).catch(page) : page()
}

async function wikimedia([, lang, project, title]: RegExpMatchArray) {
  // decode first to avoid double encoding (e.g. '%28' becomes '(')
  try {
    title = decodeURIComponent(title)
  } catch (_) {}

  const response = await fetch(
    `https://${lang}.${project}.org/api/rest_v1/page/summary/${encodeURIComponent(
      title
    )}`,
    { headers: { Accept: 'application/json' } }
  )
  if (!response.ok) throw new Error(`wikimedia: ${response.status}`)

  const data = await response.json()
  return {
    title: data.title,
    description: data.extract,
    image: data.thumbnail?.source,
  }
}

/**
 * Build the tooltip card. Every value comes from a foreign website, thus it is
 * only inserted as text or attribute, never as HTML.
 *
 * ```
 * +-------------+
 * |    image    |
 * |-------------|
 * | title       |
 * | description |
 * | url         |
 * +-------------+
 * ```
 */
function toCard(url: string, meta: Meta): HTMLElement | null {
  if (!meta.title && !meta.description && !meta.image) return null

  const card = document.createElement('div')

  if (meta.image) {
    try {
      const img = append(card, 'img')
      img.src = new URL(meta.image, url).href
      if (meta.image_alt) img.alt = meta.image_alt
      // the light background is required for transparent images in dark mode
      img.style.cssText = 'background-color:white; margin-bottom:1.5rem'
    } catch (_) {}
  }

  if (meta.title) append(card, 'h4').textContent = meta.title
  if (meta.description) append(card, 'p').textContent = meta.description

  append(card, 'hr').style.cssText = 'border:0; height:1px; background:#888'

  const a = append(card, 'a')
  a.href = url
  a.target = '_blank'
  a.rel = 'noopener noreferrer'
  a.textContent = url
  a.style.cssText = 'font-size:x-small; display:block'

  return card
}

function append<K extends keyof HTMLElementTagNameMap>(
  parent: HTMLElement,
  tag: K
): HTMLElementTagNameMap[K] {
  return parent.appendChild(document.createElement(tag))
}

/** position the tooltip below or above the link and display the card */
function show(card: HTMLElement, link: PreviewLink) {
  const tooltip = getContainer()
  const box = link.getBoundingClientRect()
  const x = box.left + box.width / 2
  const y = box.top + box.height / 2
  const width = Math.min(WIDTH, window.innerWidth - 20)

  // the tooltip is shifted to the left, proportionally to the link position
  tooltip.style.width = `${width}px`
  tooltip.style.left = `${(x * (window.innerWidth - width)) / window.innerWidth}px`

  if (y * 1.5 > window.innerHeight) {
    tooltip.style.top = ''
    tooltip.style.bottom = `${window.innerHeight - y + 10}px`
  } else {
    tooltip.style.top = `${y + 10}px`
    tooltip.style.bottom = ''
  }

  tooltip.style.background = link.light ? 'white' : '#202020'
  tooltip.style.boxShadow = link.light
    ? '0 30px 90px -20px rgba(0, 0, 0, 0.3)'
    : '0 30px 90px -20px rgba(120, 120, 120, 0.3)'

  tooltip.textContent = ''
  tooltip.appendChild(card)
  tooltip.style.display = 'block'
}

function hide() {
  clearTimeout(hideTimer)
  if (container) container.style.display = 'none'
}

/** hiding is delayed, so that the mouse can move onto the tooltip */
function scheduleHide() {
  clearTimeout(hideTimer)
  hideTimer = window.setTimeout(hide, HIDE_DELAY)
}

function getContainer() {
  if (!container) {
    container = document.createElement('div')
    container.id = TOOLTIP_ID
    container.setAttribute('role', 'tooltip')
    // LiaScript modals can have a z-index larger than 10000
    container.style.cssText =
      'position:fixed; z-index:20000; display:none; box-sizing:border-box; padding:15px; max-height:480px; overflow:auto'

    container.addEventListener('mouseenter', () => clearTimeout(hideTimer))
    container.addEventListener('mouseleave', scheduleHide)

    document.body.appendChild(container)
  }
  return container
}

// dismiss the tooltip with Escape, also when the link is only hovered
document.addEventListener('keyup', (event) => {
  if (event.key === 'Escape') {
    active = null
    hide()
  }
})

customElements.define('preview-link', PreviewLink)
