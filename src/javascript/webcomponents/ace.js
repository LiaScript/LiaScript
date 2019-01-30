"use strict";

import ace from 'ace-builds/src-noconflict/ace';


const debounce = (func) => {
  let token
  return function() {
    const later = () => {
      token = null
      func.apply(null, arguments)
    };
    cancelIdleCallback(token)
    token = requestIdleCallback(later)
  }
}

customElements.define('code-editor', class extends HTMLElement {

  constructor() {
    super();

    ace.config.set('basePath', '/editor/')

    this._value = "";
  }

  get value() {
    return this._value;
  }
  set value(value) {
    if(this._value === value)
      return;

    this._value = value;

    if(!this._editor)
      return;

    this._editor.setValue(value);
  }

  connectedCallback() {
    let div = document.createElement('div');

    this.appendChild(div);

    this._editor = ace.edit(div, {
      maxLines: 50,
      minLines: 10,
      value: this._value,
      mode: "ace/mode/javascript"
    });

    const runDispatch = debounce(() => {
      this._value = this._editor.getValue();
      this.dispatchEvent(new CustomEvent('editorChanged'));
    })

    this._editor.on('change', runDispatch);
  }
})
