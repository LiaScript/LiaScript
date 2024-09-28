import 'katex/dist/katex.min.css'
import katex from 'katex'

var katexStyles: null | string = null

customElements.define(
  'lia-formula',
  class extends HTMLElement {
    private span: HTMLSpanElement
    private formula_: string
    private macros_: { [key: string]: string }

    constructor() {
      super()
      this.span = document.createElement('span')
      this.formula_ = ''
      this.macros = {}
    }

    connectedCallback() {
      const shadowRoot = this.attachShadow({
        mode: 'open',
      })

      let link = document.createElement('link')
      link.rel = 'stylesheet'
      link.href = 'katex.min.css'

      let style = document.createElement('style')
      style.textContent = this.extractKatexStyles()

      shadowRoot.appendChild(link)
      shadowRoot.appendChild(style)
      shadowRoot.appendChild(this.span)

      this.formula_ = this.getAttribute('formula') || ''

      const macros = this.getAttribute('macros')

      if (macros) {
        try {
          this.macros_ = JSON.parse(macros)
        } catch (e) {
          console.warn('formula: reading macros ->', e.message)
        }
      }

      this.render()
    }

    extractKatexStyles() {
      if (katexStyles !== null) {
        return katexStyles
      }

      katexStyles = ''
      const styleSheets = document.styleSheets

      for (let i = 0; i < styleSheets.length; i++) {
        let sheet = styleSheets[i]
        try {
          let rules = sheet.cssRules || sheet.rules
          for (let j = 0; j < rules.length; j++) {
            let rule = rules[j]
            if (
              (rule as CSSStyleRule).selectorText &&
              (rule as CSSStyleRule).selectorText.includes('.katex')
            ) {
              katexStyles += rule.cssText + '\n'
            }
          }
        } catch (e) {
          console.warn('formula: cannot access stylesheets ->', e.message)
        }
      }

      return katexStyles
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
        let macros: { [keys: string]: string } | undefined = undefined

        // somehow the renderer cannot use internal and external macros,
        // which will result in an un-catchable error.
        // if there is no internal macro definition, then the external macros are added
        const match = this.formula_.match(
          /\\(gdef)|(xdef)|(global\\def)(global\\edef)|(global\\let)|(global\\futurelet)\\/g
        )
        if (match === null && Object.keys(this.macros_).length > 0) {
          macros = this.macros_
        }

        try {
          katex.render(this.formula_, this.span, {
            throwOnError: false,
            displayMode: this.displayMode(),
            trust: true, // allow latex like \includegraphics
            macros: macros,
            //  Object.keys(this.macros_).length == 0 ? undefined : this.macros_,
          })
        } catch (e: any) {
          console.warn('formula: render ->', e.message)
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

    get macros() {
      return this.macros_
    }

    set macros(value) {
      if (JSON.stringify(this.macros_) !== JSON.stringify(value)) {
        this.macros_ = value
        this.render()
      }
    }

    disconnectedCallback() {
      this.span.innerHTML = ''
    }
  }
)
