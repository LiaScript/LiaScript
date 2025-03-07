import ResizeObserver from 'resize-observer-polyfill'

import * as pdf from 'pdfast'

// @ts-ignore
import * as echarts from 'echarts'
import 'echarts-wordcloud'

import 'echarts/i18n/langDE.js'
import 'echarts/i18n/langEN.js'
import 'echarts/i18n/langES.js'
import 'echarts/i18n/langFI.js'
import 'echarts/i18n/langFR.js'
import 'echarts/i18n/langJA.js'
import 'echarts/i18n/langTH.js'
import 'echarts/i18n/langZH.js'
import * as helper from '../helper'

const style = 'width: 100%; height: 400px; margin-top: -0.2em;'

// TODO
// - [ ] Switching to dark-mode and then performing an external translation does
//       not reload the dark-mode properly.
// - [ ] Let translator also translate the titles, x-axis, etc.
// - [ ] Check for more appropriate aria labeling.
// - [ ] Make buttons also accessible, no keyboard yet
//
// References:
//
// - ProjectWebsite:
//      https://echarts.apache.org/en/index.html
// - Information on Aria-Support:
//      https://github.com/apache/echarts-doc/blob/master/en/tutorial/aria.md
// - Decals:
//      https://echarts.apache.org/en/option.html#aria.decal.show

customElements.define(
  'lia-chart',
  class extends HTMLElement {
    private container?: HTMLDivElement

    private chart?: echarts.ECharts
    private option_: { aria?: { show: boolean; decal?: boolean } }
    private geoJson: {
      url: string
      data: null | any
    }
    private locale: string
    private mode: string

    private resizeObserver: ResizeObserver

    private style_: string
    private val: string = ''
    private renderer: 'canvas' | 'svg' = 'svg'

    static get observedAttributes() {
      return ['style', 'mode', 'json', 'locale', 'aria-label', 'renderer']
    }

    constructor() {
      super()

      this.option_ = {}
      this.chart = undefined
      this.geoJson = {
        url: '',
        data: null,
      }
      this.locale = 'en'
      this.setRenderer(this.getAttribute('renderer'))
      this.mode = ''

      this.style_ = style
    }

    setRenderer(renderer: any) {
      if (renderer === 'canvas' || renderer === 'svg') {
        this.renderer = renderer
      }
    }

    getOption() {
      let option = this.getAttribute('option')

      if (option) {
        try {
          return JSON.parse(option)
        } catch (e) {
          console.warn(
            'lia-chart: could not parse json, will evaluate =>',
            e.message
          )
        }

        try {
          return eval('option=' + option)
        } catch (e) {
          console.warn('lia-chart: could not eval option => ', e.message)
        }
      }

      return null
    }

    connectedCallback() {
      if (!this.container) {
        this.init()
      }

      if (!this.chart) {
        if (this.container) {
          this.container.setAttribute('style', this.style_)
        }
        this.initChart()

        this.option_ = this.getOption() || this.option_

        this.option_['aria'] = {
          show: true,
        } //, decal: { show: true }}

        let self = this
        // @ts-ignore
        this.chart?.on('finished', function () {
          self.setAttribute(
            'aria-label',
            self.container?.getAttribute('aria-label') || ''
          )
        })
        // TODO: Check for more appropriate roles...
        self.setAttribute('aria-role', 'figure alert')
        self.setAttribute('aria-relevant', 'text')

        // this forces to wait for the chart until geoJson is loaded
        if (!this.geoJson.url) {
          this.updateChart()
          this.resizeChart()
        }

        try {
          if (this.parentElement) {
            this.resizeObserver.observe(this.parentElement)
          }
        } catch (e) {
          console.warn('charts: resize observer =>', e)
        }
      }
    }

    init() {
      const shadowRoot = this.attachShadow({
        mode: 'open',
      })
      this.container = document.createElement('div')
      shadowRoot.appendChild(this.container)

      let self = this
      this.resizeObserver = new ResizeObserver(
        helper.debounce(() => {
          self.resizeChart()
        })
      )
    }

    disconnectedCallback() {
      if (this.chart) echarts.dispose(this.chart)

      this.resizeObserver.disconnect()
      this.geoJson.data = {}
    }

    attributeChangedCallback(name: string, oldValue: string, newValue: string) {
      if (oldValue === newValue) return

      switch (name) {
        case 'style': {
          this.style_ = style + newValue
          this.container?.setAttribute('style', this.style_)
          this.resizeChart()
          break
        }

        case 'locale': {
          if (this.chart && this.locale !== newValue) {
            this.locale = newValue

            this.initChart()
            this.updateChart()
          }
        }

        case 'mode': {
          newValue = newValue || ''

          if (this.chart && this.mode !== newValue) {
            this.mode = newValue

            this.initChart()
            this.updateChart()
          }
          break
        }

        case 'renderer': {
          newValue = newValue || 'svg'

          if (this.chart && this.renderer !== newValue) {
            this.setRenderer(newValue)

            this.initChart()
            this.updateChart()
          }
          break
        }

        case 'json': {
          this.geoJson.url = newValue
          this.geoJson.data = null

          if (helper.allowedProtocol(this.geoJson.url)) {
            let xmlHttp = new XMLHttpRequest()
            let self = this
            xmlHttp.onreadystatechange = function () {
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
        default: {
          console.warn('charts: unknown attribute', name)
        }
      }
    }

    updateChart() {
      if (!this.chart || !this.option_) return

      // this.chart.clear();

      if (this.geoJson.data !== null) {
        echarts.registerMap(this.geoJson.url, this.geoJson.data)
      }

      this.chart.setOption(this.option_, true)
    }

    initChart() {
      if (this.chart) echarts.dispose(this.chart)

      this.chart = echarts.init(this.container, this.mode || '', {
        renderer: this.renderer,
        locale: this.locale,
        useDirtyRect: false,
      })
    }

    resizeChart() {
      if (this.chart) this.chart.resize()
    }

    get option() {
      return this.option_
    }

    set option(val) {
      if (val) {
        //, decal: { show: true }}

        const val_ = JSON.stringify(val)
        if (val_ !== this.val) {
          this.val = val_
          val['aria'] = { show: true }
          if (val['pdf']) {
            const data = pdf.create(val['pdf']['data'], {
              min: val['pdf']['min'],
              max: val['pdf']['max'],
              size: val['pdf']['size'],
              width: val['pdf']['width'],
            })

            const x: number[] = []
            const y: number[] = []

            for (let i = 0; i < data.length; i++) {
              x.push(data[i]['x'])
              y.push(data[i]['y'])
            }

            val['xAxis'].data = x
            val['series'][0].data = y
          }
          this.option_ = val
          this.updateChart()
        }
      }
    }
  }
)
