import echarts from 'echarts'

customElements.define('e-charts', class extends HTMLElement {
  static get observedAttributes() {
    return ["style", "option"];
  }

  constructor () {
    super()
    const shadowRoot = this.attachShadow({ mode: 'open' })

    let div = document.createElement('div')
    div.style = "width: 100%; height: 400px;"
    div.id = "container"

    shadowRoot.appendChild(div)

    let self = this
    window.onresize = function() {
      self.resizeChart();
    }
  }

  connectedCallback () {
    if (!this.chart) {
      let container = this.shadowRoot.querySelector("#container")
      this.chart = echarts.init(container)
      this.updateChart()
    }
  }

  disconnectedCallback () {
    if (super.disconnectedCallback) {
      super.disconnectedCallback()
    }
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === "option") {
      this.updateChart();
    } else if (name === "style") {
      let container = this.shadowRoot.querySelector("#container");
      if (container) {
        container.style = newValue;
      }
      this.resizeChart();
    }
  }

  updateChart() {
    if (!this.chart) return;

    //this.chart.clear();

    let option = JSON.parse(this.option || "{}");

    console.warn(option);

    //this.chart.setOption({},true);
    this.chart.setOption(option, true);
    //this.resizeChart()
  }

  resizeChart() {
    if (!this.chart) return;

    this.chart.resize()
  }

  get option() {
    if (this.hasAttribute("option")) {
      return this.getAttribute("option");
    } else {
      return "{}";
    }
  }

  set option(val) {
    if (val) {
      this.setAttribute("option", val);
    } else {
      this.setAttribute("option", "{}");
    }
    this.updateChart();
  }
})
