import 'katex/dist/katex.min.css';
import katex from 'katex';

customElements.define('katex-formula', class extends HTMLElement {

  constructor() {
    super();
  }

  connectedCallback() {
    let span = document.createElement('span');

    let displayMode = this.getAttribute('displayMode');

    if(!displayMode) {
        displayMode = false;
    } else {
        displayMode = JSON.parse(displayMode);
    }

    katex.render(this.innerHTML, this, {
        throwOnError: false,
        displayMode: displayMode
    });
  }

  disconnectedCallback() {
    if (super.disconnectedCallback) {
      super.disconnectedCallback();
    }
  }
})
