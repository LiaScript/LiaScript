import CodeMirror from 'codemirror'
import './codemirror_modes'


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
    this._value = '';
    this._mode = '';
    this._tabSize = 4;
    this._lineNumbers = true;
    this._theme = 'shadowfox';
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

  get mode() {
    return this._mode;
  }  
  set mode(value) {
    if(this._mode === value)
      return;

    this._mode = value;

    if(!this._editor)
      return;

    this._editor.setOption('mode', value)
  }
  
  get tabSize() {
    return this._tabSize
  }
  set tabSize(value) {
    if (value === null) value = 4
    if (value === this._tabSize) return
    this._tabSize = value
    if (!this._editor) return
    this._editor.setOption('indentWidth', this._tabSize)
    this._editor.setOption('tabSize', this._tabSize)
    this._editor.setOption('indentUnit', this._tabSize)
  }

  connectedCallback() {
    this._editor = CodeMirror(this, {
      indentWidth: this._tabSize,
          tabSize: this._tabSize,
       indentUnit: this._tabSize,
             mode: this._mode,
      lineNumbers: this._lineNumbers,
            value: this._value,
            theme: this._theme
    });
    
    this._editor.setSize(null, "80%");
    
    const runDispatch = debounce(() => {
      this._value = this._editor.getValue();
      this.dispatchEvent(new CustomEvent('editorChanged'));
    })

    this._editor.on('changes', runDispatch);
  }
})
