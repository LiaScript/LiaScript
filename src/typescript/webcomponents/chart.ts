import ResizeObserver from 'resize-observer-polyfill'

import * as pdf from 'pdfast'

import { evalError } from '../liascript/service/Script'

// @ts-ignore
import * as echarts from 'echarts'
import 'echarts-wordcloud'
// echarts 6 changed the default colors and layout, v5 keeps the old look and
// theme/dark is the old dark theme, which replaces the new built-in one
import 'echarts/theme/v5'
import 'echarts/theme/dark'

import 'echarts/i18n/langAR.js'
import 'echarts/i18n/langCS.js'
import 'echarts/i18n/langDE.js'
import 'echarts/i18n/langEL.js'
import 'echarts/i18n/langEN.js'
import 'echarts/i18n/langES.js'
import 'echarts/i18n/langFA.js'
import 'echarts/i18n/langFI.js'
import 'echarts/i18n/langFR.js'
import 'echarts/i18n/langHU.js'
import 'echarts/i18n/langIT.js'
import 'echarts/i18n/langJA.js'
import 'echarts/i18n/langKO.js'
import 'echarts/i18n/langLV.js'
import 'echarts/i18n/langnb-NO.js'
import 'echarts/i18n/langNL.js'
import 'echarts/i18n/langPL.js'
import 'echarts/i18n/langPT-br.js'
import 'echarts/i18n/langRO.js'
import 'echarts/i18n/langRU.js'
import 'echarts/i18n/langSI.js'
import 'echarts/i18n/langSV.js'
import 'echarts/i18n/langTH.js'
import 'echarts/i18n/langTR.js'
import 'echarts/i18n/langUK.js'
import 'echarts/i18n/langZH.js'
import * as helper from '../helper'

// LiaScript language codes, whose echarts locale has another name
const LOCALES: { [lang: string]: string } = { nb: 'nb-NO', pt: 'PT-br', sl: 'SI' }

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

// shortcut: echarts has no API to combine or read themes, so the old dark look
// (v5 layout + old dark colors) is read from the private _theme of a probe,
// replace it if echarts ever exports its themes
function themeOf(name: string) {
  const probe = echarts.init(document.createElement('div'), name)
  // @ts-ignore
  const theme = probe._theme
  probe.dispose()
  return theme
}
// the dark background is replaced by the one of the course
echarts.registerTheme('v5-dark', {
  ...echarts.util.merge(themeOf('v5'), themeOf('dark'), true),
  backgroundColor: 'transparent',
})

// Decals are patterns, which distinguish the series not only by their color,
// they can be switched on in the settings (class lia-decals of the html)
function aria() {
  return {
    show: true,
    decal: {
      show: document.documentElement.classList.contains('lia-decals'),
    },
  }
}

customElements.define(
  'lia-chart',
  class extends HTMLElement {
    private container?: HTMLDivElement

    private chart?: echarts.ECharts
    private option_: { aria?: { show: boolean; decal?: { show: boolean } } }

    // the aria-label of the author, otherwise the generated description is used
    private authorLabel: string | null = null
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
      return ['style', 'mode', 'json', 'locale', 'renderer']
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
          return eval('option = ' + option)
        } catch (err) {
          evalError('lia-chart', option, err)
        }
      }

      return null
    }

    connectedCallback() {
      window.addEventListener('lia-decals', this.onDecals)
      window.addEventListener('lia-variant', this.onVariant)

      if (!this.container) {
        this.init()
      }

      if (!this.chart) {
        if (this.container) {
          this.container.setAttribute('style', this.style_)
        }
        this.initChart()

        this.option_ = this.getOption() || this.option_

        this.option_['aria'] = aria()

        // the chart is an image, which is described by the author or by the
        // description generated by eCharts
        this.authorLabel = this.getAttribute('aria-label')
        this.setAttribute('role', 'img')
        if (this.authorLabel === null) {
          // until eCharts has generated a description, or if it fails
          this.setAttribute(
            'aria-label',
            this.getAttribute('data-title') ||
              this.getAttribute('data-label') ||
              'Chart'
          )
        }

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

    // patterns are switched on or off in the settings
    onDecals = () => {
      this.option_['aria'] = aria()
      this.updateChart()
    }

    // charts written by hand have no mode and follow the dark mode of the course
    onVariant = () => {
      if (!this.hasAttribute('mode')) this.reinitChart()
    }

    disconnectedCallback() {
      window.removeEventListener('lia-decals', this.onDecals)
      window.removeEventListener('lia-variant', this.onVariant)
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

        // attributes are usually set before connectedCallback, so always store
        // them and only re-init if the chart already exists
        case 'locale': {
          if (this.locale !== newValue) {
            this.locale = newValue
            this.reinitChart()
          }
          break
        }

        case 'mode': {
          newValue = newValue || ''

          if (this.mode !== newValue) {
            this.mode = newValue
            this.reinitChart()
          }
          break
        }

        case 'renderer': {
          newValue = newValue || 'svg'

          if (this.renderer !== newValue) {
            this.setRenderer(newValue)
            this.reinitChart()
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

      const mode = this.hasAttribute('mode')
        ? this.mode
        : document.documentElement.classList.contains('lia-variant-dark')
          ? 'dark'
          : ''
      const theme = mode === 'dark' ? 'v5-dark' : mode || 'v5'

      this.chart = echarts.init(this.container, theme, {
        renderer: this.renderer,
        locale: LOCALES[this.locale] || this.locale,
        useDirtyRect: false,
      })

      // re-registered on every init, a locale change creates a new chart
      // @ts-ignore
      this.chart.on('finished', () => {
        const generated = this.container?.getAttribute('aria-label')
        if (this.authorLabel === null && generated) {
          this.setAttribute('aria-label', generated)
        }
      })
    }

    reinitChart() {
      if (!this.chart) return

      this.initChart()
      this.updateChart()
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
          val['aria'] = aria()
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
