import * as echarts from 'echarts'

import 'echarts/i18n/langDE.js'
import 'echarts/i18n/langEN.js'
import 'echarts/i18n/langES.js'
import 'echarts/i18n/langFI.js'
import 'echarts/i18n/langFR.js'
import 'echarts/i18n/langJA.js'
import 'echarts/i18n/langTH.js'
import 'echarts/i18n/langZH.js'

const style = 'width: 100%; height: 400px; margin-top: -0.2em;'

// TODO: Switching to dark-mode and then performing an external translation does
// not reload the dark-mode properly.

customElements.define('lia-chart', class extends HTMLElement {
  private container: HTMLDivElement

  private chart: null | echarts.ECharts
  private option_: object
  private geoJson: { url: string, data: null | object }
  private locale: string
  private mode: string

  static get observedAttributes() {
    return ['style', 'mode', 'json', 'locale']
  }

  constructor() {
    super()
    const shadowRoot = this.attachShadow({
      mode: 'open'
    })

    this.option_ = {}
    this.chart = null
    this.geoJson = { url: '', data: null }
    this.locale = 'en'
    this.mode = ""
    this.container = document.createElement('div')
    shadowRoot.appendChild(this.container)

    let self = this
    window.addEventListener('resize', function() {
      self.resizeChart()
    })
  }

  connectedCallback() {
    if (!this.chart) {
      this.container.setAttribute('style', style)
      this.chart = echarts.init(this.container, this.mode || '', { renderer: 'svg', locale: this.locale})
      this.option_ = JSON.parse(this.getAttribute('option') || 'null') || this.option_
      this.updateChart()
      this.resizeChart()
    }
  }

  disconnectedCallback() {
    if (this.chart) echarts.dispose(this.chart)

    this.geoJson.data = {}
  }

  attributeChangedCallback(name: string, oldValue: string, newValue: string) {
    if (oldValue === newValue) return

    switch (name) {
      case 'style': {
        this.container.setAttribute('style', style + newValue)
        this.resizeChart()
        break
      }

      case 'locale': {
        if (this.chart && this.locale !== newValue) {
          this.locale = newValue
          echarts.dispose(this.chart)
          this.chart = echarts.init(this.container, this.mode, { renderer: 'svg', locale: this.locale})
          this.updateChart()
        }
      }

      case 'mode': {
        newValue = newValue || ""

        if (this.chart && this.mode !== newValue) {
          this.mode = newValue
          echarts.dispose(this.chart)
          this.chart = echarts.init(this.container, this.mode, { renderer: 'svg', locale: this.locale})
          this.updateChart()
        }
        break
      }

      case 'json': {
        this.geoJson.url = newValue
        this.geoJson.data = null

        if (this.geoJson.url.startsWith('http')) {
          let xmlHttp = new XMLHttpRequest()
          let self = this
          xmlHttp.onreadystatechange = function() {
            if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {
              try {
                if (xmlHttp.responseText) {
                  self.geoJson.data = JSON.parse(xmlHttp.responseText)
                  self.updateChart()
                }
              } catch (e) {
                console.warn('eCharts ... could not load =>', e)
              }
            }
          }

          xmlHttp.open('GET', newValue, true) // true for asynchronous
          xmlHttp.send(null)
        }

        break
      }
    }
  }

  updateChart() {
    if (!this.chart || !this.option_) return

    // this.chart.clear();

    if (this.geoJson.data) {
      echarts.registerMap(this.geoJson.url, this.geoJson.data)
    }

    this.chart.setOption(this.option_, true)
  }

  resizeChart() {
    if (this.chart) this.chart.resize()
  }

  get option() {
    return this.option_
  }

  set option(val) {
    if (val) {
      if (JSON.stringify(val) !== JSON.stringify(this.option_)) {
        this.option_ = val
        this.updateChart()
      }
    }
  }
})
