// import 'katex/dist/katex.min.css';
import katex from 'katex'

customElements.define('katex-formula', class extends HTMLElement {
  constructor () {
    super()
  }

  connectedCallback () {
    const shadowRoot = this.attachShadow({ mode: 'open' })

    let span = document.createElement('span')
    let link = document.createElement('link')
    link.href = 'katex.min.css'
    link.rel = 'stylesheet'

    shadowRoot.appendChild(link)
    shadowRoot.appendChild(span)

    let displayMode = this.getAttribute('displayMode')

    if (!displayMode) {
      displayMode = false
    } else {
      displayMode = JSON.parse(displayMode)
    }

    katex.render(this.textContent, span, {
      throwOnError: false,
      displayMode: displayMode
    })
  }

  disconnectedCallback () {
    if (super.disconnectedCallback) {
      super.disconnectedCallback()
    }
  }
})
