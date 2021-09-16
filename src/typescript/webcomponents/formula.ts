import 'katex/dist/katex.min.css'
// @ts-ignore
import katex from 'katex'

customElements.define(
  'lia-formula',
  class extends HTMLElement {
    private span: HTMLSpanElement
    private formula_: string

    constructor() {
      super()
      this.span = document.createElement('span')
      this.formula_ = ''
    }

    connectedCallback() {
      const shadowRoot = this.attachShadow({
        mode: 'open',
      })

      let link = document.createElement('link')
      link.rel = 'stylesheet'
      link.href = 'katex.min.css'

      shadowRoot.appendChild(link)
      shadowRoot.appendChild(this.span)

      this.formula_ = this.getAttribute('formula') || ''

      this.render()
    }

    displayMode(): boolean {
      try {
        const mode = this.getAttribute('displayMode') || 'false'

        let ret = JSON.parse(mode)

        return ret ? true : false
      } catch (e) {}

      return false
    }

    render() {
      if (this.formula_ && this.span) {
        try {
          katex.render(this.formula_, this.span, {
            throwOnError: false,
            displayMode: this.displayMode(),
            trust: true, // allow latex like \includegraphics
          })
        } catch (e: any) {
          console.warn('katex', e.message)
        }

        this.setAttribute('role', 'math')
        this.setAttribute('aria-label', this.formula_)
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
      this.span.innerHTML = ''
    }
  }
)
