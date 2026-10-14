/**
 * `<lia-chat app="…/app/index.html">` embeds the LiaScript chat as an iframe.
 *
 *    chat.add({ user: 'AI', message: '# Hello\n\n[[x]] LiaScript' })
 *    chat.define({ import: ['https://…/CodeRunner/README.md'] })
 *    const json = await chat.export()
 *    chat.load(json)
 *
 * Events: `store` (quiz, survey, task, code changes) and `agent` (agent:-links).
 */

// the position within the chat (0, 1, 2, ...) is the id of a message, messages
// can only be appended, not changed or deleted
export type Message = {
  message: string // LiaScript Markdown
  user?: string // the name of the sender
  icon?: string // url (or data-url) of an avatar
  self?: boolean // own messages are right aligned
  time?: number // ms since 1970, shown as local time
  color?: string
}

// only defined for classic scripts, modules have to set the `app` attribute
const SCRIPT = (document.currentScript as HTMLScriptElement | null)?.src

export class LiaChat extends HTMLElement {
  private iframe = document.createElement('iframe')
  private ready = false
  private queue: any[] = []
  private ref = 0
  private exports = new Map<number, (json: any) => void>()

  connectedCallback() {
    const app = new URL(
      this.getAttribute('app') || 'app/index.html',
      SCRIPT || location.href
    )
    app.searchParams.set('base', this.getAttribute('base') || location.href)

    this.iframe.src = app.href
    // same-origin is required for the Web Worker of the Script service
    this.iframe.sandbox.add(
      'allow-scripts',
      'allow-same-origin',
      'allow-popups',
      'allow-downloads'
    )
    this.iframe.style.cssText =
      'width:100%;height:100%;border:none;display:block'
    this.style.display ||= 'block'

    window.addEventListener('message', this.receive)
    this.appendChild(this.iframe)
  }

  disconnectedCallback() {
    window.removeEventListener('message', this.receive)
    this.ready = false
  }

  /** Append messages, the message is LiaScript Markdown. */
  add(...messages: Message[]) {
    this.post('add', messages)
  }

  /** Load templates, scripts, styles or a header with macros for the chat. */
  define(def: {
    import?: string[]
    script?: string[]
    link?: string[]
    header?: string
  }) {
    const lines = [
      ...(def.import || []).map(url => 'import: ' + url),
      ...(def.script || []).map(url => 'script: ' + url),
      ...(def.link || []).map(url => 'link: ' + url),
      def.header || '',
    ]
    this.add({ message: '<!--\n' + lines.join('\n') + '\n-->' })
  }

  clear() {
    this.post('clear')
  }

  /** Restore a chat with all states, as returned by `export`. */
  load(json: { messages: Message[]; db: any }) {
    this.post('load', json)
  }

  /** All messages and states (quiz, survey, task, code) as JSON. */
  export(): Promise<{ version: number; messages: Message[]; db: any }> {
    const ref = ++this.ref
    return new Promise(resolve => {
      this.exports.set(ref, resolve)
      this.post('export', undefined, ref)
    })
  }

  private post(cmd: string, param?: any, ref?: number) {
    const msg = { cmd, param, ref }
    if (this.ready) this.iframe.contentWindow?.postMessage(msg, '*')
    else this.queue.push(msg)
  }

  private receive = ({ source, data }: MessageEvent) => {
    if (source !== this.iframe.contentWindow || !data) return

    switch (data.type) {
      case 'ready':
        this.ready = true
        this.queue.forEach(msg =>
          this.iframe.contentWindow?.postMessage(msg, '*')
        )
        this.queue = []
        break

      case 'export':
        this.exports.get(data.ref)?.(data.param)
        this.exports.delete(data.ref)
        break

      case 'store':
        this.dispatchEvent(new CustomEvent('store', { detail: data.record }))
        break

      case 'agent':
        this.dispatchEvent(new CustomEvent('agent', { detail: data.href }))
        break
    }
  }
}

if (!customElements.get('lia-chat')) customElements.define('lia-chat', LiaChat)
