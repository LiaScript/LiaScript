customElements.define('intl-datetime', class extends HTMLElement {
  constructor () {
    super()
  }

  connectedCallback () {
    const shadowRoot = this.attachShadow({ mode: 'open' })
    this.span = document.createElement('span')
    shadowRoot.appendChild(this.span)

    this.locale = this.get('locale')
    this.format = {
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

    this.value_ = this.get("value")

    this.view()
  }

  view() {
    alert(this.value_)

    try {
      this.span.innerText = new Intl.DateTimeFormat(this.locale, this.format).format(Date.parse(this.value_))
    } catch (e) {
      console.warn("intl-datetime: ", e.message)
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
