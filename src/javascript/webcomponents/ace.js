import ace from 'ace-builds/src-noconflict/ace'
import getMode from './ace-modes'

const debounce = (func) => {
  let token
  return function () {
    const later = () => {
      token = null
      func.apply(null, arguments)
    }
    cancelIdleCallback(token)
    token = requestIdleCallback(later)
  }
}

function markerStyle(name) {
  if (typeof name == "string") {
    name = "ace_color_" + name.replace(/ /g, "")
                              .replace(/\./g, "")
                              .replace(/,/g, "_")
                              .replace(/\(/g, "")
                              .replace(/\)/g, "")
  }
  return name
}

function addMarker(color, name=null) {

  if (!color)
    return

  name = markerStyle( name ? name : color )

  if (!document.head.getElementsByTagName("style")[name]) {
    let node = document.createElement('style')
    node.type = 'text/css';
    node.id = name
    node.appendChild(document.createTextNode(
      `.${name} {
        position:absolute;
        background:${ color };
        z-index:20
      }`
    ))
    document.getElementsByTagName('head')[0].appendChild(node)
  }
}


customElements.define('code-editor', class extends HTMLElement {
  constructor () {
    super()

    ace.config.set('basePath', 'editor/')

    this.model = {
      value: null,
      theme: null,
      mode: null,
      shared: null,
      showPrintMargin: true,
      highlightActiveLine: true,
      firstLineNumber: 1,
      tabSize: 4,
      useSoftTabs: true,
      useWrapMode: false,
      readOnly: false,
      showCursor: true,
      showGutter: true,
      extensions: [],
      maxLines: Infinity,
      marker: "",
      minLines: 1,
      annotations: [],
      fontSize: '12pt'
    }

    let markers = {
      "error":  "rgba(255,0,0,0.3)",
      "warn":   "rgba(255,255,102,0.3)",
      "debug":  "rgba(100,100,100,0.3)",
      "info":   "rgba(0,255,0,0.3)",
      "log":    "rgba(0,0,255,0.3)",
    }

    try {
      let keys = Object.keys(markers)

      for (let i=0; i<keys.length; i++) {
        addMarker(markers[keys[i]], keys[i])
      }
    } catch(e) {
      console.warn("ace.js => ", e);
    }

    this.focus_ = false
  }

  connectedCallback () {
    this.setExtension()

    this._editor = ace.edit(this, {
      value: this.model.value,
      theme: 'ace/theme/' + this.model.theme,
      mode: getMode(this.model.mode),
      showPrintMargin: this.model.showPrintMargin,
      highlightActiveLine: this.model.highlightActiveLine,
      firstLineNumber: this.model.firstLineNumber,
      tabSize: this.model.tabSize,
      useSoftTabs: this.model.useSoftTabs,
      readOnly: this.model.readOnly,
      showGutter: this.model.showGutter,
      minLines: this.model.minLines,
      maxLines: this.model.maxLines,
      fontSize: this.model.fontSize
    })

    if (!this.model.showCursor) {
      this._editor.renderer.$cursorLayer.element.style.display = 'none'
    }

    this._editor.renderer.setScrollMargin(8, 8, 0, 0)

    this._editor.getSession().setUseWrapMode(this.model.useWrapMode)

    this._editor.setAutoScrollEditorIntoView(true)

    if (!this.model.readOnly) {
      const runDispatch = debounce(() => {
        this.model.value = this._editor.getValue()
        this.dispatchEvent(new CustomEvent('editorChanged'))
      })

      this._editor.on('change', runDispatch)
    }

    let self = this
    this._editor.on("focus", function(){
      self.focus_ = true
      self.dispatchEvent(new CustomEvent('editorFocus'))
    })

    this._editor.on("blur",  function(){
      self.focus_ = false
      self.dispatchEvent(new CustomEvent('editorFocus'))
    })

    this.setMarker()

    if(this.focus_)
      this.setFocus()

  }

  disconnectedCallback () {
    if (super.disconnectedCallback) {
      super.disconnectedCallback()
    }
  }

  setOption (option, value) {
    if (this.model[option] === value) return

    this.model[option] = value

    if (!this._editor) return

    try {
      this._editor.setOption(option, value)
    } catch (e) {
      console.log(
        'Problem Ace: setOption ',
        option,
        value,
        ' => ',
        e.toString())
    }
  }

  get annotations () {
    return this.model.annotations
  }
  set annotations (list) {
    if (this.model.annotations === list) return

    if (list == null) this.model.annotations = []
    else this.model.annotations = list

    if (!this._editor) return

    try {
      this._editor.getSession().setAnnotations(this.model.annotations)
    } catch (e) {
      console.log(
        'Problem Ace: setAnnotations ',
        this.model.annotations,
        ' => ',
        e.toString()
      )
    }
  }

  get extensions () {
    return this.model.extensions
  }
  set extensions (values) {
    if (this.model.extensions === values) return

    this.model.extensions = values

    if (!this._editor) return

    this.setExtension()
  }
  setExtension () {
    for (let ext in this.model.extensions) {
      try {
        ace.require('ace/ext/' + ext)
      } catch (e) {
        console.log('Problem Ace: require ', ext, ' => ', e.toString())
      }
    }
  }

  get fontSize () {
    return this.model.fontSize
  }
  set fontSize (value) {
    this.setOption('fontSize', value)
  }


  setMarker () {
    let Range = ace.require('ace/range').Range
    let value = this.model.marker.split(";")

    for (let i=0; i<value.length; i++) {
      let m = value[i].split(" ").filter( e => e != "")

      addMarker(m[4])

      this._editor.session.addMarker(
        new Range (
          parseInt(m[0]),
          parseInt(m[1]),
          parseInt(m[2]),
          parseInt(m[3])
        ),
        markerStyle(m[4]),
        m[5] ? m[5] : "fullLine"
      )
    }
  }
  get marker () {
    return this.model.marker
  }
  set marker (value) {
    this.model.marker = value
  }

  get firstLineNumber () {
    return this.model.firstLineNumber
  }
  set firstLineNumber (value) {
    this.setOption('firstLineNumber', value)
  }

  get highlightActiveLine () {
    return this.model.highlightActiveLine
  }
  set highlightActiveLine (value) {
    this.setOption('highlightActiveLine', value)
  }

  get maxLines () {
    return this.model.maxLines
  }
  set maxLines (value) {
    this.setOption('maxLines', value < 0 ? Infinity : value)
  }

  get minLines () {
    return this.model.minLines
  }
  set minLines (value) {
    this.setOption('minLines', value < 0 ? 1 : value)
  }

  get mode () {
    return this.model.mode
  }
  set mode (mode) {
    if (this.model.mode === mode) return

    this.model.mode = mode

    if (!this._editor) return

    try {
      this._editor.getSession().setMode(getMode(mode))
    } catch (e) {
      console.log('Problem Ace: setMode(', mode, ') => ', e.toString())
    }
  }

  get readOnly () {
    return this.model.readOnly
  }
  set readOnly (value) {
    this.setOption('readOnly', value)
  }

  get showCursor () {
    return this.model.showCursor
  }
  set showCursor (value) {
    this.setOption('showCursor', value)
  }

  get showGutter () {
    return this.model.showGutter
  }
  set showGutter (value) {
    this.setOption('showGutter', value)
  }

  get showPrintMargin () {
    return this.model.showPrintMargin
  }
  set showPrintMargin (value) {
    this.setOption('showPrintMargin', value)
  }

  get tabSize () {
    return this.model.tabSize
  }
  set tabSize (value) {
    this.setOption('tabSize', value)
  }

  get theme () {
    return this.model.theme
  }
  set theme (theme) {
    if (this.model.theme === theme) return

    this.model.theme = theme

    if (!this._editor) return

    this._editor.setTheme('ace/theme/' + theme)
  }

  get useSoftTabs () {
    return this.model.useSoftTabs
  }
  set useSoftTabs (value) {
    this.setOption('useSoftTabs', value)
  }

  get useWrapMode () {
    return this.model.useWrapMode
  }
  set useWrapMode (value) {
    this.setOption('useWrapMode', value)
  }

  get value () {
    return this.model.value
  }
  set value (value) {
    this.setOption('value', value)
  }

  get focus() {
    return this.focus_
  }
  set focus(value) {
    this.focus_ = value

    if (value)
      this.setFocus()
  }

  setFocus() {
    if (!this._editor) return

    try {
        this._editor.focus()
    } catch (e) {
      console.log(
        'Problem Ace: focus => ',
        e.toString())
    }
  }
})
