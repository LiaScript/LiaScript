// import 'katex/dist/katex.min.css';
import katex from 'katex'

customElements.define('lia-formula', class extends HTMLElement {
  private span: HTMLSpanElement
  private formula_: string
  private displayMode: boolean

  constructor() {
    super()
    this.span = document.createElement('span')
    this.formula_ = ''
    this.displayMode = false
  }

  connectedCallback() {
    const shadowRoot = this.attachShadow({
      mode: 'open'
    })

    let link = document.createElement('link')
    link.rel = 'stylesheet'
    link.href = 'katex.min.css'

    shadowRoot.appendChild(link)
    shadowRoot.appendChild(this.span)

    const mode = this.getAttribute('displayMode')

    if (mode) {
      this.displayMode = JSON.parse(mode)
    }

    this.render()
  }

  render() {
    if (this.formula_ && this.span) {
      try {
        katex.render(this.formula_, this.span, {
          throwOnError: false,
          displayMode: this.displayMode
        })
      } catch (e) {
        console.warn('katex', e.message)
      }
    }
  }

  get formula() {
    return this.formula_
  }

  set formula(value) {
    if (this.formula_ !== value) {
      this.formula_ = value
      this.render()
    }
  }

  disconnectedCallback() {
    this.span.innerHTML = ""
  }
})
