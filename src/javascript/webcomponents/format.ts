declare namespace Intl {
  class RelativeTimeFormat {
    constructor(locale: string | undefined, options: object);
    format(value: string, unit: string | undefined): string;
  }
  class ListFormat {
    constructor(locale: string | undefined, options: object);
    format(value: string[]): string;
  }
}

enum Format {
  DateTime = 'datetime',
  List = 'list',
  Number = 'number',
  PluralRules = 'pluralrules',
  RelativeTime = 'relativetime'
}


customElements.define('lia-format', class extends HTMLElement {
  private span: HTMLSpanElement

  private value_: string
  private locale: string | undefined
  private format: string | undefined
  private option: object
  private unit: string | undefined

  constructor() {
    super()
    this.span = document.createElement('span')
    this.option = {}
    this.value_ = ''
    //this.unit
    this.format
    this.locale
  }

  connectedCallback() {
    const shadowRoot = this.attachShadow({
      mode: 'open'
    })

    shadowRoot.appendChild(this.span)

    this.locale = this.get('locale') || undefined

    this.format = this.get('format') || undefined

    switch (this.format) {
      case 'number':
        this.option = {
          compactDisplay: this.get('compactDisplay'),
          currency: this.get('currency'),
          currencyDisplay: this.get('currencyDisplay'),
          currencySign: this.get('currencySign'),
          localeMatcher: this.get('localeMatcher'),
          maximumFractionDigits: this.get('maximumFractionDigits'),
          maximumSignificantDigits: this.get('maximumSignificantDigits'),
          minimumFractionDigits: this.get('minimumFractionDigits'),
          minimumIntegerDigits: this.get('minimumIntegerDigits'),
          minimumSignificantDigits: this.get('minimumSignificantDigits'),
          notation: this.get('notation'),
          numberingSystem: this.get('numberingSystem'),
          signDisplay: this.get('signDisplay'),
          style: this.get('localeStyle'),
          unit: this.get('unit'),
          unitDisplay: this.get('unitDisplay'),
          useGrouping: this.get('useGrouping')
        }

        break

      case 'datetime':
        this.option = {
          calendar: this.get('calendar'),
          dateStyle: this.get('dateStyle'),
          day: this.get('day'),
          dayPeriod: this.get('dayPeriod'),
          era: this.get('era'),
          formatMatcher: this.get('formatMatcher'),
          fractionalSecondDigits: this.get('fractionalSecondDigits'),
          hour: this.get('hour'),
          hour12: this.get('hour12'),
          hourCycle: this.get('hourCycle'),
          localeMatcher: this.get('localeMatcher'),
          minute: this.get('minute'),
          month: this.get('month'),
          numberingSystem: this.get('numberingSystem'),
          second: this.get('second'),
          timeStyle: this.get('timeStyle'),
          timeZone: this.get('timeZone'),
          timeZoneName: this.get('timeZoneName'),
          weekday: this.get('weekday'),
          year: this.get('year')
        }
        break
      // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/RelativeTimeFormat/RelativeTimeFormat
      case 'relativetime':
        this.unit = this.get('unit') || undefined
        this.option = {
          localeMatcher: this.get('localeMatcher'),
          numeric: this.get('numeric'),
          style: this.get('localeStyle')
        }
        break

      case 'list':
        this.option = {
          localeMatcher: this.get('localeMatcher'),
          style: this.get('localeStyle'),
          type: this.get('type')
        }
        break
      case 'pluralrules':
        this.option = {
          localeMatcher: this.get('localeMatcher'),
          maximumFractionDigits: this.get('maximumFractionDigits'),
          maximumSignificantDigits: this.get('maximumSignificantDigits'),
          minimumFractionDigits: this.get('minimumFractionDigits'),
          minimumIntegerDigits: this.get('minimumIntegerDigits'),
          minimumSignificantDigits: this.get('minimumSignificantDigits'),
          type: this.get('type')
        }
        break
      default:
        this.option = {}
    }

    this.value_ = this.textContent || ''

    this.view()
  }

  view() {
    let value = ''
    try {
      switch (this.format) {
        case Format.Number:
          value = new Intl.NumberFormat(this.locale, this.option).format(parseFloat(this.value_))
          break
        case Format.DateTime:
          value = new Intl.DateTimeFormat(this.locale, this.option).format(Date.parse(this.value_))
          break
        case Format.RelativeTime:
          value = new Intl.RelativeTimeFormat(this.locale, this.option).format(this.value_, this.unit)
          break
        case Format.List:
          value = new Intl.ListFormat(this.locale, this.option).format(JSON.parse(this.value_))
          break
        case Format.PluralRules:
          value = new Intl.PluralRules(this.locale, this.option).select(parseFloat(this.value_))
          break
      }
    } catch (e) {
      console.warn('intl-format: ', e.message)
    }

    this.span.innerText = value || this.value_
  }

  get(name: string) {
    return this.getAttribute(name)
  }

  get value() {
    return this.value_
  }

  getFormat(): Format | null {
    switch (this.get('format')) {
      case Format.DateTime:
        return Format.DateTime
      case Format.List:
        return Format.List
      case Format.Number:
        return Format.Number
      case Format.PluralRules:
        return Format.PluralRules
      case Format.RelativeTime:
        return Format.RelativeTime
    }
    return null
  }

  set value(value) {
    if (this.value_ !== value) {
      this.value_ = value
      this.view()
    }
  }

  disconnectedCallback() {
  }
})
