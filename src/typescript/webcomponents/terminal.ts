customElements.define(
  'lia-terminal',
  class extends HTMLElement {
    private resizeObserver: ResizeObserver
    private height_?: string

    constructor() {
      super()

      let self = this
      this.resizeObserver = new ResizeObserver(function (e) {
        if (self.style.height) {
          self.height_ = self.style.height
          self.update()
          self.dispatchEvent(new CustomEvent('onchangeheight'))
        }
      })
    }

    connectedCallback() {
      this.resizeObserver.observe(this)
    }

    disconnectedCallback() {
      this.resizeObserver.disconnect()
    }

    update() {
      if (this.height_) {
        this.style.maxHeight = 'none'
        this.style.height = this.height_
      }
    }

    get height() {
      return this.height_
    }

    set height(val) {
      if (this.height_ != val) {
        this.height_ = val
        this.update()
      }
    }
  }
)
