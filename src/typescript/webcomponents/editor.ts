import ace from 'ace-builds/src-noconflict/ace'
import getMode from './editor-modes'


type RequestIdleCallbackHandle = any;
type RequestIdleCallbackOptions = {
  timeout: number;
};
type RequestIdleCallbackDeadline = {
  readonly didTimeout: boolean;
  timeRemaining: (() => number);
};

declare global {
  interface Window {
    requestIdleCallback: ((
      callback: ((deadline: RequestIdleCallbackDeadline) => void),
      opts?: RequestIdleCallbackOptions,
    ) => RequestIdleCallbackHandle);
    cancelIdleCallback: ((handle: RequestIdleCallbackHandle) => void);
  }
}

function debounce(func: any) {
  // this is required since, safari and opera do not provide this interfaces ...
  if (!window.cancelIdleCallback || !window.requestIdleCallback) return func

  let token: any
  return function() {
    const later = () => {
      token = null
      func.apply(null, arguments)
    }
    window.cancelIdleCallback(token)
    token = window.requestIdleCallback(later)
  }
}

function markerStyle(name: string): string {
  if (typeof name === 'string') {
    name = 'ace_color_' + name.replace(/ /g, '')
      .replace(/\./g, '')
      .replace(/,/g, '_')
      .replace(/\(/g, '')
      .replace(/\)/g, '')
  }
  return name
}

function addMarker(color: string, name?: string | undefined) {
  if (!color) return

  const id = markerStyle(name || color)

  if (!document.head.querySelector('style#' + id)) {
    let node = document.createElement('style')
    // node.type ='text/css'
    node.id = id
    node.appendChild(document.createTextNode(
      `.${id} {
        position:absolute;
        background:${color};
        z-index:20
      }`
    ))
    document.getElementsByTagName('head')[0].appendChild(node)
  }
}

customElements.define('lia-editor', class extends HTMLElement {

  private _editor: any
  private _focus: boolean
  private model: {
    value: string,
    theme: string,
    mode: string,
    shared: null | string,
    showPrintMargin: boolean,
    highlightActiveLine: boolean,
    firstLineNumber: number,
    tabSize: number,
    useSoftTabs: boolean,
    useWrapMode: boolean,
    readOnly: boolean,
    showCursor: boolean,
    showGutter: boolean,
    extensions: string[],
    maxLines: number,
    marker: string,
    minLines: number,
    annotations: string[],
    fontSize: string
  }

  constructor() {
    super()

    ace.config.set('basePath', 'editor/')

    this._focus = false

    this.model = {
      value: '',
      theme: '',
      mode: 'text',
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
      marker: '',
      minLines: 1,
      annotations: [],
      fontSize: '12pt'
    }

    let markers = {
      error: 'rgba(255,0,0,0.3)',
      warn: 'rgba(255,255,102,0.3)',
      debug: 'rgba(100,100,100,0.3)',
      info: 'rgba(0,255,0,0.3)',
      log: 'rgba(0,0,255,0.3)'
    }

    try {
      Object.entries(markers).forEach(entry => {
        const [name, color] = entry;
        addMarker(color, name)
      });
    } catch (e) {
      console.warn('ace.js => ', e)
    }
  }

  connectedCallback() {
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
    this._editor.on('focus', function() {
      self._focus = true
      self.dispatchEvent(new CustomEvent('editorFocus'))
    })

    this._editor.on('blur', function() {
      self._focus = false
      self.dispatchEvent(new CustomEvent('editorFocus'))
    })

    this.setMarker()

    if (this._focus) {
      this.setFocus()
    }
  }

  disconnectedCallback() {
    // todo
  }

  setOption(option: string, value: any) {
    /*if ((this.model[option] as any) == value) return

    this.model[option] = value
    */
    if (this._editor) {
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
  }

  get annotations() {
    return this.model.annotations
  }

  set annotations(list) {
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

  get extensions() {
    return this.model.extensions
  }

  set extensions(values) {
    if (this.model.extensions === values) return

    this.model.extensions = values

    if (!this._editor) return

    this.setExtension()
  }

  setExtension() {
    for (const ext in this.model.extensions) {
      try {
        ace.require('ace/ext/' + ext)
      } catch (e) {
        console.log('Problem Ace: require ', ext, ' => ', e.toString())
      }
    }
  }

  get fontSize() {
    return this.model.fontSize
  }

  set fontSize(value: string) {
    if (this.model.fontSize !== value) {
      this.model.fontSize = value
      this.setOption('fontSize', value)
    }
  }

  setMarker() {
    let Range = ace.require('ace/range').Range
    let value = this.model.marker.replace('\n', '').split(';').filter(e => e !== '')

    for (let i = 0; i < value.length; i++) {
      let m = value[i]
        .trim()
        .split(' ')
        .map(e => e.trim())
        .filter(e => e !== '')

      addMarker(m[4])

      this._editor.session.addMarker(
        new Range(
          parseInt(m[0]),
          parseInt(m[1]),
          parseInt(m[2]),
          parseInt(m[3])
        ),
        markerStyle(m[4]),
        m[5] ? m[5] : 'fullLine'
      )
    }
  }

  get marker() {
    return this.model.marker
  }

  set marker(value) {
    this.model.marker = value
  }

  get firstLineNumber() {
    return this.model.firstLineNumber
  }

  set firstLineNumber(value: number) {
    if (this.model.firstLineNumber !== value) {
      this.model.firstLineNumber = value
      this.setOption('firstLineNumber', value)
    }
  }

  get highlightActiveLine() {
    return this.model.highlightActiveLine
  }

  set highlightActiveLine(value) {
    if (this.model.highlightActiveLine !== value) {
      this.model.highlightActiveLine = value
      this.setOption('highlightActiveLine', value)
    }
  }

  get maxLines() {
    return this.model.maxLines
  }

  set maxLines(value: number) {
    value = value < 0 ? Infinity : value
    if (this.model.maxLines !== value) {
      this.model.maxLines = value
      this.setOption('maxLines', value)
    }
  }

  get minLines() {
    return this.model.minLines
  }

  set minLines(value: number) {
    value = value < 0 ? 1 : value
    if (this.model.minLines !== value) {
      this.model.minLines = value
      this.setOption('minLines', value)
    }
  }

  get mode() {
    return this.model.mode
  }

  set mode(mode) {
    if (this.model.mode === mode) return

    this.model.mode = mode

    if (!this._editor) return

    try {
      this._editor.getSession().setMode(getMode(mode))
    } catch (e) {
      console.log('Problem Ace: setMode(', mode, ') => ', e.toString())
    }
  }

  get readOnly() {
    return this.model.readOnly
  }

  set readOnly(value: boolean) {
    if (this.model.readOnly !== value) {
      this.model.readOnly = value
      this.setOption('readOnly', value)
    }
  }

  get showCursor() {
    return this.model.showCursor
  }

  set showCursor(value: boolean) {
    if (this.model.showCursor !== value) {
      this.model.showCursor = value
      this.setOption('showCursor', value)
    }
  }

  get showGutter() {
    return this.model.showGutter
  }

  set showGutter(value: boolean) {
    if (this.model.showGutter !== value) {
      this.model.showGutter = value
      this.setOption('showGutter', value)
    }
  }

  get showPrintMargin() {
    return this.model.showPrintMargin
  }

  set showPrintMargin(value: boolean) {
    if (this.model.showPrintMargin !== value) {
      this.model.showPrintMargin = value
      this.setOption('showPrintMargin', value)
    }
  }

  get tabSize() {
    return this.model.tabSize
  }

  set tabSize(value: number) {
    if (this.model.tabSize !== value) {
      this.model.tabSize = value
      this.setOption('tabSize', value)
    }
  }

  get theme() {
    return this.model.theme
  }

  set theme(theme: string) {
    if (this.model.theme === theme) return

    this.model.theme = theme

    if (!this._editor) return

    this._editor.setTheme('ace/theme/' + theme)
  }

  get useSoftTabs() {
    return this.model.useSoftTabs
  }

  set useSoftTabs(value: boolean) {
    if (this.model.useSoftTabs !== value) {
      this.model.useSoftTabs = value
      this.setOption('useSoftTabs', value)
    }
  }

  get useWrapMode() {
    return this.model.useWrapMode
  }

  set useWrapMode(value) {
    if (this.model.useWrapMode !== value) {
      this.model.useWrapMode = value
      this.setOption('useWrapMode', value)
    }
  }

  get value() {
    return this.model.value
  }

  set value(value: string) {
    if (this.model.value !== value) {
      this.model.value = value
      this.setOption('value', value)
    }
  }

  get focusing() {
    return this._focus
  }

  set focusing(value) {
    this._focus = value

    if (value) {
      this.setFocus()
    }
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
