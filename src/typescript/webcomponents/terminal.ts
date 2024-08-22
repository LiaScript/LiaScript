import ResizeObserver from 'resize-observer-polyfill'

// currently the maximum height of 20rem is used, whenever this value is changed
// within the style, then this max value has to changed accordingly in:
// src/scss/03_elements/_elements.code.scss
const maxHeight = Math.floor(
  20 * parseFloat(getComputedStyle(document.documentElement).fontSize)
)

customElements.define(
  'lia-terminal',
  class extends HTMLElement {
    private resizeObserver: ResizeObserver
    private mutationObserver: MutationObserver
    private height_?: string

    constructor() {
      super()

      let self = this
      this.resizeObserver = new ResizeObserver(function (
        entries: ResizeObserverEntry[]
      ) {
        if (self.style.height) {
          self.height_ = self.style.height
          self.update()
          self.dispatchEvent(new CustomEvent('onchangeheight'))
        } else if (entries?.[0].borderBoxSize?.[0].blockSize >= maxHeight) {
          self.height_ = maxHeight + 'px'
          self.update()
          self.dispatchEvent(new CustomEvent('onchangeheight'))
        }
      })

      this.mutationObserver = new MutationObserver(() => {
        this.update()
      })
    }

    connectedCallback() {
      this.resizeObserver.observe(this)
      this.mutationObserver.observe(this, { childList: true, subtree: false })
    }

    disconnectedCallback() {
      this.resizeObserver.disconnect()
      this.mutationObserver.disconnect()
    }

    update() {
      if (this.height_) {
        this.style.maxHeight = 'none'
        this.style.height = this.height_
      }
      // Scroll to the bottom
      this.scrollTop = this.scrollHeight
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
