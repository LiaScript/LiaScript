import katex from 'katex'
import renderA11yString from './a11y/index.ts'
import 'katex/contrib/mhchem/mhchem.js'

var katexStyles: null | string = null

customElements.define(
  'lia-formula',
  class extends HTMLElement {
    private span: HTMLSpanElement
    private label: HTMLSpanElement
    private formula_: string
    private macros_: { [key: string]: string } = {}

    constructor() {
      super()
      this.span = document.createElement('span')
      this.label = document.createElement('span')
      this.label.style.display = 'none'
      this.label.setAttribute('aria-hidden', 'true')

      this.formula_ = ''
    }

    connectedCallback() {
      const shadowRoot = this.attachShadow({
        mode: 'open',
      })

      let style = document.createElement('style')
      style.textContent = this.extractKatexStyles()

      shadowRoot.appendChild(style)
      shadowRoot.appendChild(this.span)
      this.appendChild(this.label)

      // Elm sets the formula as a property, before the element is connected
      this.formula_ = this.getAttribute('formula') || this.formula_

      const macros = this.getAttribute('macros')

      if (macros) {
        try {
          this.macros_ = JSON.parse(macros)
        } catch (err) {
          console.warn(
            'formula: reading macros ->',
            err instanceof Error ? err.message : String(err)
          )
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
          console.warn(
            'formula: cannot access stylesheets ->',
            e instanceof Error ? e.message : String(e)
          )
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

    // somehow the renderer cannot use internal and external macros,
    // which will result in an un-catchable error.
    // if there is no internal macro definition, then the external macros are added
    courseMacros(): { [keys: string]: string } | undefined {
      const match = this.formula_.match(
        /\\(gdef)|(xdef)|(global\\def)(global\\edef)|(global\\let)|(global\\futurelet)\\/g
      )
      if (match === null && Object.keys(this.macros_).length > 0) {
        return this.macros_
      }
    }

    // The text to read out, the TTS asks for it in the language of its voice
    speech(lang: string = document.documentElement.lang): string {
      const label = this.getAttribute('aria-label')
      if (label !== null) return label

      try {
        return renderA11yString(
          this.formula_,
          // a copy, \gdef in the formula would change the course macros
          { displayMode: this.displayMode(), macros: { ...this.courseMacros() } },
          lang
        )
      } catch (e) {
        console.warn(
          'formula: render a11y ->',
          e instanceof Error ? e.message : String(e)
        )
        return this.formula_
      }
    }

    render() {
      if (this.formula_ && this.span) {
        const macros = this.courseMacros()

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

        // the generated description or the aria-label of the author
        const label = this.speech()
        this.span.setAttribute('aria-label', label)
        this.label.textContent = label

        // descriptions are generated in English and German only, others fall
        // back to English, which must not be read with another pronunciation
        const lang = (document.documentElement.lang || 'en').slice(0, 2)
        if (this.getAttribute('aria-label') === null && lang !== 'en' && lang !== 'de') {
          this.span.setAttribute('lang', 'en')
        } else {
          this.span.removeAttribute('lang')
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
