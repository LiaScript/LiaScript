"use strict";

import ace from 'ace-builds/src-noconflict/ace';
import get_mode from './ace-modes';

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

    this.model = {
      value: null,
      theme: null,
      mode: null,
      shared: null,
      showPrintMargin: true,
      highlightActiveLine: true,
      tabSize: 4,
      useSoftTabs: true,
      useWrapMode: false,
      readOnly: false,
      showCursor: true,
      showGutter: true,
      extensions: [],
      maxLines: Infinity,
      minLines: 1,
      annotations: [],
      fontSize: "12pt",
    };
  }

  set_option(option, value) {
    if(this.model[option] === value)
      return;
    this.model[option] = value;
    if(!this._editor)
      return;
    this._editor.setOption(option, value);
  }

  get value() {
    return this.model.value; }
  set value(value) {
    this.set_option("value", value); }

  get showPrintMargin() {
    return this.model.showPrintMargin; }
  set showPrintMargin(value) {
    this.set_option("showPrintMargin", value);
  }

  get highlightActiveLine() {
    return this.model.highlightActiveLine; }
  set highlightActiveLine(value) {
    this.set_option("highlightActiveLine", value); }

  get readOnly() {
    return this.model.readOnly; }
  set readOnly(value) {
    this.set_option("readOnly", value); }

  get showCursor() {
    return this.model.showCursor; }
  set showCursor(value) {
    this.set_option("showCursor", value); }

  get showGutter() {
    return this.model.showGutter; }
  set showGutter(value) {
    this.set_option("showGutter", value); }

  get fontSize() {
    return this.model.fontSize; }
  set maxLines(value) {
    this.set_option("fontSize", value + "pt" ); }


  get maxLines() {
    return this.model.maxLines; }
  set maxLines(value) {
    this.set_option("maxLines", value < 0 ? Infinity : value ); }

  get minLines() {
    return this.model.minLines; }
  set minLines(value) {
    this.set_option("minLines", value < 0 ? 1 : value ); }

  get useSoftTabs() {
    return this.model.useSoftTabs; }
  set useSoftTabs(value) {
    this.set_option("useSoftTabs", value); }

  get tabSize() {
    return this.model.tabSize; }
  set tabSize(value) {
    this.set_option("tabSize", value); }

  get annotations() {
    return this.model.annotations; }
  set annotations(list) {
    if(this.model.annotations === list)
      return;
    if(list == null)
      this.model.annotations = [];
    else
      this.model.annotations = list;

    if(!this._editor)
      return;

    this._editor.getSession().setAnnotations(this.model.annotations);
  }

  get extensions() {
    return this.model.extensions;
  }
  set extensions(values) {
    if(this.model.extensions === values)
      return;
    this.model.extensions = values;
    if(!this._editor)
      return;
    for (let ext in this.model.extensions) {
      ace.require("ace/ext/" + ext);
    }
  }

  get useWrapMode() {
    return this.model.useWrapMode; }
  set useWrapMode(value) {
    this.set_option("useWrapMode", value); }


  get mode() {
    return this.model.mode; }
  set mode(mode) {
    if(this.model.mode === mode)
      return;
    this.model.mode = mode;
    if(!this._editor)
      return;
    this._editor.setMode(get_mode(mode));
  }

  get theme() {
    return this.model.theme; }
  set theme(theme) {
    if(this.model.theme === theme)
      return;
    this.model.theme = theme;
    if(!this._editor)
      return;
    this._editor.setTheme("ace/theme/" + theme);
  }

  connectedCallback() {
    for (let ext in this.model.extensions) {
      ace.require("ace/ext/" + ext);
    }

    this._editor = ace.edit(this, {
      value:               this.model.value,
      theme:               "ace/theme/" + this.model.theme,
      mode:                get_mode(this.model.mode),
      showPrintMargin:     this.model.showPrintMargin,
      highlightActiveLine: this.model.highlightActiveLine,
      tabSize:             this.model.tabSize,
      useSoftTabs:         this.model.useSoftTabs,
      readOnly:            this.model.readOnly,
      showGutter:          this.model.showGutter,
      minLines:            this.model.minLines,
      maxLines:            this.model.maxLines,
      fontSize:            this.model.fontSize,
    });

    if (!this.model.showCursor)
      this._editor.renderer.$cursorLayer.element.style.display = "none";

    this._editor.getSession().setUseWrapMode(this.model.useWrapMode);

    this._editor.setAutoScrollEditorIntoView(true);

    const runDispatch = debounce(() => {
      this.model.value = this._editor.getValue();
      this.dispatchEvent(new CustomEvent('editorChanged'));
    })

    this._editor.on('change', runDispatch);
  }
})
