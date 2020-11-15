// import 'katex/dist/katex.min.css';
import katex from 'katex'

customElements.define('katex-formula', class extends HTMLElement {
  constructor() {
    super()
  }


  connectedCallback() {
    const shadowRoot = this.attachShadow({
      mode: 'open'
    })

    let link = document.createElement('link')
    link.rel = 'stylesheet'
    link.href = 'katex.min.css'

    this.span = document.createElement('span')

    shadowRoot.appendChild(link)
    shadowRoot.appendChild(this.span)

    this.displayMode = this.getAttribute('displayMode')

    if (!this.displayMode) {
      this.displayMode = false
    } else {
      this.displayMode = JSON.parse(this.displayMode)
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
        console.warn("katex", e.message)
      }
    }
  }

  get formula() {
    return this.formula_
  }

  set formula(value) {
    if (this.formula_ != value) {
      this.formula_ = value
      this.render()
    }
  }

  disconnectedCallback() {
    if (super.disconnectedCallback) {
      super.disconnectedCallback()
    }
  }
})