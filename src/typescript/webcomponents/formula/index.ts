import katexCssUrl from 'katex/dist/katex.min.css'
import katex from 'katex'
import renderA11yString from './render-a11y-strings'

var katexStyles: null | string = null

customElements.define(
  'lia-formula',
  class extends HTMLElement {
    private span: HTMLSpanElement
    private label: HTMLSpanElement
    private formula_: string
    private macros_: { [key: string]: string }

    constructor() {
      super()
      this.span = document.createElement('span')
      this.label = document.createElement('span')
      this.label.style.display = 'none'
      this.label.setAttribute('aria-hidden', 'true')

      this.formula_ = ''
      this.macros = {}
    }

    connectedCallback() {
      const shadowRoot = this.attachShadow({
        mode: 'open',
      })

      let link = document.createElement('link')
      link.rel = 'stylesheet'
      link.href = katexCssUrl // 'katex.min.css'

      let style = document.createElement('style')
      style.textContent = this.extractKatexStyles()

      shadowRoot.appendChild(link)
      shadowRoot.appendChild(style)
      shadowRoot.appendChild(this.span)
      this.appendChild(this.label)

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
            output: 'htmlAndMathml',
            //  Object.keys(this.macros_).length == 0 ? undefined : this.macros_,
          })
        } catch (e: any) {
          console.warn('formula: render ->', e.message)
        }

        this.span.setAttribute('role', 'math')

        if (this.getAttribute('aria-label') === null) {
          let label = this.formula_

          try {
            label = renderA11yString(label)
          } catch (e) {
            console.warn('formula: render a11y ->', e.message)
          }

          this.span.setAttribute('aria-label', label)
          this.label.innerHTML = label
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
      this.label.innerHTML = ''
    }
  }
)
