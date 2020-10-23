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


    switch (this.format) {
      case "number":
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
        break

      case "datetime":
        this.option = {
          localeMatcher:            this.get('localeMatcher'),
          timeZone:                 this.get('timeZone'),
          hour12:                   this.get('hour12'),
          hourCycle:                this.get('hourCycle'),
          formatMatcher:            this.get('formatMatcher'),
          weekday:                  this.get('weekday'),
          era:                      this.get('era'),
          year:                     this.get('year'),
          month:                    this.get('month'),
          day:                      this.get('day'),
          hour:                     this.get('hour'),
          minute:                   this.get('minute'),
          second:                   this.get('second'),
          timeZoneName:             this.get('timeZoneName')
        }
        break
      // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/RelativeTimeFormat/RelativeTimeFormat
      case "relativetime":
        this.unit = this.get('unit')
        this.option = {
          localeMatcher:            this.get('localeMatcher'),
          numeric:                  this.get('numeric'),
          style:                    this.get('style')
        }
        break

      case "list":
        this.option = {
          localeMatcher:            this.get('localeMatcher'),
          type:                     this.get('type'),
          style:                    this.get('style')
        }
        break
      case "pluralrules":
        this.option = {
          localeMatcher:            this.get('localeMatcher'),
          type:                     this.get('type'),
          minimumIntegerDigits:     this.get('minimumIntegerDigits'),
          minimumFractionDigits:    this.get('minimumFractionDigits'),
          maximumFractionDigits:    this.get('maximumFractionDigits'),
          minimumSignificantDigits: this.get('minimumSignificantDigits'),
          maximumSignificantDigits: this.get('maximumSignificantDigits')
        }
        break
      default:
        this.option = {}
    }

    this.value_ = this.textContent

    this.view()
  }

  view() {
    let value
    try {
      switch (this.format) {
        case "number":
          value = new Intl.NumberFormat(this.locale, this.option).format(parseFloat(this.value_))
          break
        case "datetime":
          value = new Intl.DateTimeFormat(this.locale, this.option).format(Date.parse(this.value_))
          break
        case "relativetime":
          value = new Intl.RelativeTimeFormat(this.locle, this.option).format(this.value_, this.unit)
          break
        case "list":
          value = new Intl.ListFormat(this.locale, this.option).format(JSON.parse(this.value_))
          break
        case "pluralrules":
          value = new Intl.PluralRules(this.locale, this.option).select(this.value_)
          break
        }
    } catch (e) {
      console.warn("intl-format: ", e.message)
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
