const currentDocument = document.currentScript.ownerDocument;


class KatexFormula extends HTMLElement {
  constructor() {
    // If you define a constructor, always call super() first as it is required by the CE spec.
    super();
  }

  render(element, formula, displayMode) {
    //let element = this.shadowRoot.get;

    console.log(formula)

    katex.render(formula, element, {
    throwOnError: false,
    displayMode: displayMode
    });
  }

  // Called when element is inserted in DOM
  connectedCallback() {
    const shadowRoot = this.attachShadow({mode: 'open'});

    let formula = this.innerHTML;

    let span = currentDocument.createElement('span');
    let link = currentDocument.createElement('link');
    link.href = "https://cdn.jsdelivr.net/npm/katex@0.10.0/dist/katex.min.css";
    link.rel = "stylesheet";

    shadowRoot.appendChild(link);
    shadowRoot.appendChild(span);

    let displayMode = this.getAttribute('displayMode');

    if(!displayMode) {
        displayMode = false;
    } else {
        displayMode = JSON.parse(displayMode);
    }

    katex.render(formula, span, {
        throwOnError: false,
        displayMode: displayMode
    });
  }
}

customElements.define('katex-formula', KatexFormula);
