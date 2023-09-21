// @ts-ignore
import ace from 'ace-builds/src-min-noconflict/ace'
import * as EDITOR from './editor-modes'

import * as AceCollabExt from '@convergencelabs/ace-collab-ext'
import '@convergencelabs/ace-collab-ext/dist/css/ace-collab-ext.min.css'

type Update = {
  action: 'insert' | 'remove'
  index: number
  content: string
}

type Position = {
  row: number
  column: number
}

type Selection = [] | [number, number, number, number]

type Cursor = {
  id: string
  color: string
  position: Position
  selection: Selection
}

function markerStyle(name: string): string {
  if (typeof name === 'string') {
    name =
      'ace_color_' +
      name
        .replace(/ /g, '')
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
    node.appendChild(
      document.createTextNode(
        `.${id} {
        position:absolute;
        background:${color};
        z-index:20
      }`
      )
    )
    document.getElementsByTagName('head')[0].appendChild(node)
  }
}

function throttle(
  cb: (
    change: Update[],
    cursor?: { position: Position; selection: Selection }
  ) => void,
  delay: number = 500
) {
  let storedChange: Update[] = []
  let storedCursor

  let timerID: number | null = null

  function checkStoredArgs() {
    if (storedChange.length > 0 || storedCursor) {
      cb(storedChange, storedCursor)
      storedChange = []
      storedCursor = undefined
    }

    timerID = null
  }

  return (
    change: Update | null,
    cursor?: { position: Position; selection: Selection }
  ) => {
    if (timerID) {
      window.clearTimeout(timerID)
    }

    if (change !== null) storedChange.push(change)
    if (cursor) {
      storedCursor = cursor
    }
    timerID = window.setTimeout(checkStoredArgs, delay)
  }
}

/*
function debounce(cb: (_: any) => void, delay: number = 1000) {
  let storedArg: any | undefined
  let timerID: number | null = null

  function checkStoredArgs() {
    if (storedArg !== undefined) {
      cb(storedArg)
      storedArg = undefined
    }

    timerID = null
  }

  return (arg: any) => {
    if (timerID) {
      window.clearTimeout(timerID)
    }

    storedArg = arg
    timerID = window.setTimeout(checkStoredArgs, delay)
  }
}
*/

customElements.define(
  'lia-editor',
  class extends HTMLElement {
    private _editor: any
    private _focus: boolean
    private _ariaLabel: string
    private _blockUpdate: boolean = false

    private _blockEvents: boolean = false

    private cursorManager: any
    private selectManager: any
    private _cursors: Cursor[] = []
    private _catchCursorUpdates: boolean = false
    private cursorPosition?: Position

    private model: {
      value: string
      theme: string
      mode: string
      shared: null | string
      showPrintMargin: boolean
      highlightActiveLine: boolean
      firstLineNumber: number
      tabSize: number
      useSoftTabs: boolean
      useWrapMode: boolean
      readOnly: boolean
      showCursor: boolean
      showGutter: boolean
      extensions: string[]
      maxLines: number
      marker: string
      minLines: number
      annotations: string[]
      fontSize: string
      fontFamily: string
      enableKeyboardAccessibility: boolean
    }

    constructor() {
      super()

      // ace.config.set('basePath', 'editor/')

      this._focus = false
      this._ariaLabel = 'editor'

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
        fontSize: '1.5rem',
        fontFamily: 'var(--global-font-mono,)',
        enableKeyboardAccessibility: true,
      }

      let markers = {
        error: 'rgba(255,0,0,0.3)',
        warn: 'rgba(255,255,102,0.3)',
        debug: 'rgba(100,100,100,0.3)',
        info: 'rgba(0,255,0,0.3)',
        log: 'rgba(0,0,255,0.3)',
      }

      try {
        Object.entries(markers).forEach((entry) => {
          const [name, color] = entry
          addMarker(color, name)
        })
      } catch (e) {
        console.warn('ace.js => ', e)
      }
    }

    connectedCallback() {
      this.setExtension()

      this._editor = ace.edit(this, {
        value: this.model.value,
        theme: 'ace/theme/' + this.model.theme,
        mode: EDITOR.getMode(this.model.mode),
        showPrintMargin: this.model.showPrintMargin,
        highlightActiveLine: this.model.highlightActiveLine,
        firstLineNumber: this.model.firstLineNumber,
        tabSize: this.model.tabSize,
        useSoftTabs: this.model.useSoftTabs,
        readOnly: this.model.readOnly,
        showGutter: this.model.showGutter,
        minLines: this.model.minLines,
        maxLines: this.model.maxLines,
        fontSize: this.model.fontSize,
        fontFamily: this.model.fontFamily,
        enableKeyboardAccessibility: this.model.enableKeyboardAccessibility,
      })

      if (!this.model.showCursor) {
        this._editor.renderer.$cursorLayer.element.style.display = 'none'
      }

      this._editor.renderer.setScrollMargin(8, 8, 0, 0)

      this._editor.getSession().setUseWrapMode(this.model.useWrapMode)

      this._editor.setAutoScrollEditorIntoView(true)

      const input = this._editor.textInput.getElement()

      const dispatchUpdateEvent = throttle(
        (
          changes: Update[],
          cursor?: { position: Position; selection: Selection }
        ) => {
          if (changes.length > 0)
            this.dispatchEvent(
              new CustomEvent('editorUpdateEvent', {
                detail: changes,
              })
            )

          if (cursor)
            this.dispatchEvent(
              new CustomEvent('editorUpdateCursor', {
                detail: cursor,
              })
            )
        }
      )

      input.setAttribute('role', 'application')
      if (!this.model.readOnly) {
        const runDispatch = (event: any) => {
          if (this._blockEvents) {
            return
          }

          this.model.value = this._editor.getValue()

          this.dispatchEvent(
            new CustomEvent('editorUpdate', {
              detail: this.model.value,
            })
          )

          if (!this.blockUpdate) {
            dispatchUpdateEvent({
              action: event.action,
              index: this._editor
                .getSession()
                .doc.positionToIndex(event.start, 0),
              content: event.lines.join('\n'),
            })
          }
        }

        const cursorDispatch = () => {
          if (this.catchCursorUpdates && this._editor) {
            const { start, end } = this._editor.getSelectionRange()
            const selection: Selection =
              start.row == end.row && start.column == end.column
                ? []
                : [start.row, start.column, end.row, end.column]

            this.cursorPosition = this._editor.selection.getCursor()

            if (this.cursorPosition) {
              dispatchUpdateEvent(null, {
                position: this.cursorPosition,
                selection,
              })
            }
          }
        }

        this._editor.on('change', runDispatch)
        this._editor.session.selection.on('changeCursor', cursorDispatch)

        const self = this
        this._editor.commands.addCommand({
          name: 'Ctrl-Enter',
          bindKey: { win: 'Ctrl-Enter', mac: 'Command-Enter' },
          exec: function (editor) {
            self.dispatchEvent(new CustomEvent('editorCtrlEnter'))
          },
          readOnly: false, // false if this command should not apply in readOnly mode
        })

        input.setAttribute(
          'aria-label',
          'Code-editor in ' + this.model.mode + ' mode'
        )
      } else {
        input.setAttribute(
          'aria-label',
          'Code-block in ' + this.model.mode + ' mode'
        )
      }

      let self = this
      this._editor.on('focus', function () {
        self._focus = true
        self.dispatchEvent(new CustomEvent('editorFocus'))
      })

      this._editor.on('blur', function () {
        self._focus = false
        self.dispatchEvent(new CustomEvent('editorFocus'))
        self._editor.clearSelection()
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
            e.toString()
          )
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

    get enableKeyboardAccessibility() {
      return this.model.enableKeyboardAccessibility
    }

    set enableKeyboardAccessibility(value: boolean) {
      if (this.model.enableKeyboardAccessibility !== value) {
        this.model.enableKeyboardAccessibility = value
        this.setOption('enableKeyboardAccessibility', value)
      }
    }

    setMarker() {
      let Range = ace.require('ace/range').Range
      let value = this.model.marker
        .replace('\n', '')
        .split(';')
        .filter((e) => e !== '')

      for (let i = 0; i < value.length; i++) {
        let m = value[i]
          .trim()
          .split(' ')
          .map((e) => e.trim())
          .filter((e) => e !== '')

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
        this._editor.getSession().setMode(EDITOR.getMode(mode))
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

    async setValue(value: string) {
      const session = await this.getSession()

      this._blockEvents = true
      this.blockUpdate = true

      this.model.value = value

      const cursor = this._editor.getCursorPosition()

      session.setValue(value)

      this._editor.moveCursorToPosition(cursor)

      this._blockEvents = false
      this.blockUpdate = false
    }

    set value(value: string) {
      if (this.model.value !== value) {
        this.setValue(value)
      }
    }

    get blockUpdate() {
      //console.warn('Getting block of ->', this._blockUpdate)
      return this._blockUpdate
    }

    set blockUpdate(value: boolean) {
      //console.warn('Setting block to ->', value)
      this._blockUpdate = value
    }

    get catchCursorUpdates() {
      //console.warn('Getting block of ->', this._blockUpdate)
      return this._catchCursorUpdates
    }

    set catchCursorUpdates(value: boolean) {
      if (this._catchCursorUpdates !== value) {
        this._catchCursorUpdates = value
        this.setCursors()
      }
    }

    async getSession() {
      if (this._editor) {
        return Promise.resolve(this._editor.getSession()) // object already exists, return it immediately
      }

      const self = this
      return new Promise((resolve, reject) => {
        let elapsed = 0
        const checkExistence = setInterval(() => {
          elapsed += 100
          if (self._editor) {
            // check if the object exists
            clearInterval(checkExistence) // stop checking
            resolve(self._editor.getSession()) // return the object
          } else if (elapsed >= 1000) {
            clearInterval(checkExistence) // stop checking
            reject(null) // return null if object is not created after maxDelay
          }
        }, 100)
      })
    }

    /**
     * Initialize the collaborative cursors, if collaborative is set to true, otherwise delete the cursorManager.
     */
    async setCursors() {
      if (this._catchCursorUpdates) {
        if (!this.cursorManager) {
          const session = await this.getSession()
          this.cursorManager = new AceCollabExt.AceMultiCursorManager(session)

          this.selectManager = new AceCollabExt.AceMultiSelectionManager(
            session
          )

          for (let { id, color, position } of this._cursors) {
            this.cursorManager.addCursor(id, '', color, position)
          }
        }
      } else {
        if (this.cursorManager) {
          this.cursorManager.removeAll()
          this.selectManager.removeAll()
          delete this.cursorManager
        }
      }
    }

    get cursors() {
      return this._cursors
    }
    set cursors(value: Cursor[]) {
      if (this.cursorManager) {
        try {
          // delete all not existing cursors
          for (let oldCursor of this._cursors) {
            let remove = true
            for (let newCursor of value) {
              if (oldCursor.id == newCursor.id) {
                remove = false
                break
              }
            }

            if (remove) {
              this.cursorManager.removeCursor(oldCursor.id)
              try {
                this.selectManager.clearSelection(oldCursor.id)
              } catch (e) {}
              try {
                this.selectManager.removeSelection(oldCursor.id)
              } catch (e) {}
            }
          }

          for (let newCursor of value) {
            let add = true

            for (let oldCursor of this._cursors) {
              if (oldCursor.id == newCursor.id) {
                add = false
                break
              }
            }

            if (add) {
              this.cursorManager.addCursor(
                newCursor.id,
                '',
                newCursor.color,
                newCursor.position
              )

              this.selectManager.addSelection(
                newCursor.id,
                '',
                newCursor.color,
                this.toRange(newCursor.selection)
              )
            } else {
              this.cursorManager.setCursor(newCursor.id, newCursor.position)
              try {
                this.selectManager.clearSelection(newCursor.id)
              } catch (e) {}
              this.selectManager.setSelection(
                newCursor.id,
                this.toRange(newCursor.selection)
              )
            }
          }
        } catch (e) {
          console.warn('ace error:', e.message)
        }
      }

      this._cursors = value
    }

    toRange(selection: [] | [number, number, number, number]) {
      if (selection.length === 0) return []

      let Range = ace.require('ace/range').Range
      const [start1, end1, start2, end2] = selection

      return [new Range(start1, end1, start2, end2)]
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
        console.log('Problem Ace: focus => ', e.toString())
      }
    }
  }
)
