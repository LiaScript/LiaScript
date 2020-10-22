customElements.define('intl-format', class extends HTMLElement {
  constructor () {
    super()
    this.span = document.createElement('span')
  }

  connectedCallback () {
    const shadowRoot = this.attachShadow({ mode: 'open' })

    shadowRoot.appendChild(this.span)

    this.locale = this.get('locale')

    this.format = this.get('format')


    if (this.format == "number") {
      this.option = {
        style:                    this.get('localeStyle'),
        currency:                 this.get('currency'),
        localeMatcher:            this.get('localeMatcher'),
        useGrouping:              this.get('useGrouping'),
        minimumIntegerDigits:     this.get('minimumIntegerDigits'),
        minimumFractionDigits:    this.get('minimumFractionDigits'),
        maximumFractionDigits:    this.get('maximumFractionDigits'),
        minimumSignificantDigits: this.get('minimumSignificantDigits'),
        maximumSignificantDigits: this.get('maximumSignificantDigits')
      }
    } else if (this.format == "datetime") {
      this.option = {
        localeMatcher: this.get('localeMatcher'),
        timeZone:      this.get('timeZone'),
        hour12:        this.get('hour12'),
        hourCycle:     this.get('hourCycle'),
        formatMatcher: this.get('formatMatcher'),
        weekday:       this.get('weekday'),
        era:           this.get('era'),
        year:          this.get('year'),
        month:         this.get('month'),
        day:           this.get('day'),
        hour:          this.get('hour'),
        minute:        this.get('minute'),
        second:        this.get('second'),
        timeZoneName:  this.get('timeZoneName')
      }
    } else {
      this.option = {}
    }

    this.value_ = this.textContent

    this.view()
  }

  view() {


    let value
    try {
      if (this.format == "number") {
        value = new Intl.NumberFormat(this.locale, this.option).format(parseFloat(this.value_))
      } else if (this.format == "datetime") {
        value = new Intl.DateTimeFormat(this.locale, this.option).format(Date.parse(this.value_))
      }
    } catch (e) {
      console.warn("intl-number: ", e.message)
    }

    this.span.innerText = value ? value : this.value_
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
