// Focus handling for all modals rendered by `Lia.Utils.modal`: move the focus
// into the dialog when it opens, keep Tab inside of it and return the focus to
// the element that opened it when it closes.

const FOCUSABLE =
  'a[href],button:not([disabled]),input:not([disabled]),select:not([disabled]),' +
  'textarea:not([disabled]),[tabindex]:not([tabindex="-1"])'

// Elm can make the background inert before the modal gets attached, which
// already removes the focus from the opener
let lastFocused: HTMLElement | null = null
document.addEventListener(
  'focusin',
  (event) => (lastFocused = event.target as HTMLElement),
  true
)

function focus(element: HTMLElement | null) {
  if (!element || !document.body.contains(element)) return false

  element.focus()
  return document.activeElement === element
}

customElements.define(
  'lia-modal',
  class extends HTMLElement {
    // the opener and, if it is part of a submenu, the toggle of this menu,
    // since the submenu and its content might get removed meanwhile
    private opener: HTMLElement | null = null
    private toggle: HTMLElement | null = null

    constructor() {
      super()
      this.trap = this.trap.bind(this)
    }

    connectedCallback() {
      const active = document.activeElement as HTMLElement | null
      this.opener = active && active !== document.body ? active : lastFocused
      this.toggle =
        this.opener?.closest('li')?.querySelector('[aria-expanded]') || null

      this.addEventListener('keydown', this.trap)

      // the content is rendered by Elm after the element got attached
      setTimeout(() => {
        if (!this.contains(document.activeElement)) {
          focus(this.querySelector('#lia-modal__close'))
        }
      }, 0)
    }

    disconnectedCallback() {
      this.removeEventListener('keydown', this.trap)

      const { opener, toggle } = this
      this.opener = null
      this.toggle = null

      // the background is still inert while Elm removes the modal
      setTimeout(() => focus(opener) || focus(toggle), 0)
    }

    // Tab and Shift+Tab cycle through the focusable elements of the modal
    trap(event: KeyboardEvent) {
      if (event.key !== 'Tab') return

      const elements = Array.prototype.filter.call(
        this.querySelectorAll(FOCUSABLE),
        (e: HTMLButtonElement) => !e.disabled && e.getClientRects().length > 0
      ) as HTMLElement[]

      event.preventDefault()

      if (elements.length === 0) return

      const index = elements.indexOf(document.activeElement as HTMLElement)
      const next = event.shiftKey
        ? index <= 0
          ? elements.length - 1
          : index - 1
        : (index + 1) % elements.length

      elements[next].focus()
    }
  }
)
