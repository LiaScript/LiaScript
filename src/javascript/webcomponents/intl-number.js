customElements.define('intl-number', class extends HTMLElement {
  constructor () {
    super()
  }

  connectedCallback () {
    const shadowRoot = this.attachShadow({ mode: 'open' })
    this.span = document.createElement('span')
    shadowRoot.appendChild(this.span)

    this.locale = this.get('locale')
    this.format = {
      style :                   this.get('localeStyle'),
      currency :                this.get('currency'),
      localeMatcher:            this.get('localeMatcher'),
      useGrouping:              this.get('useGrouping'),
      minimumIntegerDigits:     this.get('minimumIntegerDigits'),
      minimumFractionDigits:    this.get('minimumFractionDigits'),
      maximumFractionDigits:    this.get('maximumFractionDigits'),
      minimumSignificantDigits: this.get('minimumSignificantDigits'),
      maximumSignificantDigits: this.get('maximumSignificantDigits')
    }

    this.value_ = this.get("value")

    this.view()
  }

  view() {
    try {
      this.span.innerText = new Intl.NumberFormat(this.locale, this.format).format(parseFloat(this.value_))
    } catch (e) {
      console.warn("intl-number: ", e.message)
    }
  }

  get(name) {
    return (this.getAttribute(name) || undefined)
  }

  get value() {
    return this.value_
  }
  set value(value) {
    if (this.value_ != value) {
      this.value_ = value
      this.view()
    }
  }

  disconnectedCallback () {
    if (super.disconnectedCallback) {
      super.disconnectedCallback()
    }
  }
})
