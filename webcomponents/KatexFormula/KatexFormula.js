const currentDocument = document.currentScript.ownerDocument;


class KatexFormula extends HTMLElement {
  constructor() {
    // If you define a constructor, always call super() first as it is required by the CE spec.
    super();

    this.formula = this.childNodes[0].data;

    //this.innerHTML = '';
  }

  render(formula, displayMode) {
    let element = this.shadowRoot.querySelector('.formula__katex-formula-container');

    katex.render(formula, element, {
    throwOnError: false,
    displayMode: displayMode
    });
  }

  // Called when element is inserted in DOM
  connectedCallback() {
    const shadowRoot = this.attachShadow({mode: 'open'});

    // Select the template and clone it. Finally attach the cloned node to the shadowDOM's root.
    // Current document needs to be defined to get DOM access to imported HTML
    const template = currentDocument.querySelector('#katex-formula-template');
    const instance = template.content.cloneNode(true);
    shadowRoot.appendChild(instance);

    let displayMode = this.getAttribute('displayMode');
    if(!displayMode) {
        displayMode = false;
    }

    this.render(this.formula, displayMode);
  }
}

customElements.define('katex-formula', KatexFormula);
