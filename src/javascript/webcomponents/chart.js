import echarts from 'echarts'

var style = 'width: 100%; height: 400px; margin-top: -0.2em;'

customElements.define('lia-chart', class extends HTMLElement {
  static get observedAttributes () {
    return ['style', 'mode', 'json']
  }

  constructor () {
    super()
    const shadowRoot = this.attachShadow({
      mode: 'open'
    })

    let div = document.createElement('div')
    div.style = style
    div.id = 'container'

    shadowRoot.appendChild(div)

    let self = this
    window.addEventListener('resize', function () {
      self.resizeChart()
    })
  }

  connectedCallback () {
    if (!this.chart) {
      let container = this.shadowRoot.querySelector('#container')
      this.data = null
      this.chart = echarts.init(container, this.mode)
      this.option_ = JSON.parse(this.getAttribute('option')) || this.option_

      this.updateChart()
    }
  }

  disconnectedCallback () {
    if (super.disconnectedCallback) {
      super.disconnectedCallback()
    }
    echarts.dispose(this.chart)
    this.data = null
  }

  attributeChangedCallback (name, oldValue, newValue) {
    if (name === 'style') {
      let container = this.shadowRoot.querySelector('#container')
      if (container) {
        container.style = style + newValue
      }
      this.resizeChart()
    } else if (name === 'mode') {
      if (!this.chart) return

      echarts.dispose(this.chart)
      let container = this.shadowRoot.querySelector('#container')
      this.chart = echarts.init(container, newValue)
      this.updateChart()
    } else if (name === 'json') {
      if (typeof newValue === 'string' && newValue !== '') {
        try {
          if (this.data.name === newValue) return
        } catch (e) {}

        let self = this

        let xmlHttp = new XMLHttpRequest()
        xmlHttp.onreadystatechange = function () {
          if (xmlHttp.readyState === 4 && xmlHttp.status === 200) {
            self.updateJson(newValue, xmlHttp.responseText)
          } else {
            console.warn('eCharts ... could not load =>', JSON.stringify(newValue))
          }
        }
        xmlHttp.open('GET', newValue, true) // true for asynchronous
        xmlHttp.send(null)
      } else {
        this.data = null
      }
    }
  }

  updateJson (url, json) {
    this.data = {
      name: url,
      data: json
    }
    this.updateChart()
  }

  updateChart () {
    if (!this.chart || !this.option_) return

    // this.chart.clear();

    let option = this.option_ || {}

    // console.warn(option);

    // this.chart.setOption({},true);

    if (this.data) {
      echarts.registerMap(this.data.name, this.data.data)
    }

    this.chart.setOption(option, true)
    // this.resizeChart()
  }

  resizeChart () {
    if (!this.chart) return

    this.chart.resize()
  }

  get option () {
    return this.option_
  }

  set option (val) {
    if (val) {
      if (JSON.stringify(val) !== JSON.stringify(this.option_)) {
        this.option_ = val
        this.updateChart()
      }
    }
  }

  get mode () {
    if (this.hasAttribute('mode')) {
      return this.getAttribute('mode')
    } else {
      return ''
    }
  }

  set mode (val) {
    if (val) {
      this.setAttribute('mode', val)
    } else {
      this.setAttribute('mode', '')
    }
    this.updateChart()
  }

  get json () {
    if (this.hasAttribute('json')) {
      return this.getAttribute('json')
    } else {
      return ''
    }
  }

  set json (val) {
    if (val) {
      this.setAttribute('json', val)
    } else if (this.data) {
      this.setAttribute('json', '')
    }
    this.updateChart()
  }
})
