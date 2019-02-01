"use strict";

import ace from 'ace-builds/src-noconflict/ace';
import get_theme from './ace-themes';

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
  set annotations(value) {
    this.set_option("annotations", value); }

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
    this._editor.setOption("mode", "ace/mode/" + mode);
  }

  get theme() {
    return this.model.theme; }
  set theme(theme) {
    if(this.model.theme === theme)
      return;
    this.model.theme = theme;
    if(!this._editor)
      return;
    this._editor.setTheme(get_theme(theme));
  }

  connectedCallback() {
    for (let ext in this.model.extensions) {
      ace.require("ace/ext/" + ext);
    }

    this._editor = ace.edit(this, {
      value:               this.model.value,
      theme:               get_theme(this.model.theme),
      mode:                "ace/mode/" + this.model.mode,
      showPrintMargin:     this.model.showPrintMargin,
      highlightActiveLine: this.model.highlightActiveLine,
      tabSize:             this.model.tabSize,
      useSoftTabs:         this.model.useSoftTabs,
      useWrapMode:         this.model.useWrapMode,
      readOnly:            this.model.readOnly,
      showCursor:          this.model.showCursor,
      showGutter:          this.model.showGutter,
      minLines:            this.model.minLines,
      maxLines:            this.model.maxLines,
      annotations:         this.model.annotations,
      fontSize:            this.model.fontSize,
    });

    this._editor.setAutoScrollEditorIntoView(true);



    const runDispatch = debounce(() => {
      this.model.value = this._editor.getValue();
      this.dispatchEvent(new CustomEvent('editorChanged'));
    })

    this._editor.on('change', runDispatch);
  }
})
