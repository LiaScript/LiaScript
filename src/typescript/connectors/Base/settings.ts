import * as Lia from '../../liascript/types/lia.d'

const defaultSettings: Lia.Settings = {
  table_of_contents: window.innerWidth > 768,
  mode: Lia.Mode.Textbook,
  theme: 'default',
  light: true,
  editor: 'dreamweaver',
  font_size: 1,
  sound: true,
  lang: 'en',

  tooltips: false,
  preferBrowserTTS: true,
  hideVideoComments: false,
  audio: { pitch: 1, rate: 1 },
}

export const Settings = {
  PORT: 'settings',

  data: defaultSettings,

  storage: function (_: Lia.Settings) {},

  init: function (
    data: Lia.Settings | null,
    local = false,
    storage?: (data: Lia.Settings) => void
  ) {
    if (storage) {
      this.storage = storage
    }

    if (!data) {
      data = defaultSettings
      this.update(data, local)
    }

    this.data = data

    if (window.LIA) {
      window.LIA.settings = this
    }

    return data
  },

  update: function (data: Lia.Settings, storeLocally: boolean = true) {
    if (storeLocally) {
      localStorage.setItem(this.PORT, JSON.stringify(data))
    }

    this.updateClassName(data)
    this.data = data
  },

  updateClassName: function (data: Lia.Settings) {
    try {
      let fontSize = 1

      switch (data.font_size) {
        case 2:
          fontSize = 2
          break
        case 3:
          fontSize = 3
          break
        default:
          fontSize = 1
      }

      let className = `lia-theme-${data.theme} lia-variant-${
        data.light ? 'light' : 'dark'
      } lia-font-scale-${fontSize}`

      document.documentElement.className = className
    } catch (err: any) {
      console.warn('settings (className): ', err.message)
    }
  },

  setter: function (
    name:
      | 'table_of_contents'
      | 'mode'
      | 'theme'
      | 'light'
      | 'editor'
      | 'font_size'
      | 'sound'
      | 'tooltip'
      | 'preferBrowserTTS'
      | 'hideVideoComments'
      | 'audio',
    value: any
  ) {
    if (JSON.stringify(value) !== JSON.stringify(this.data[name])) {
      this.data[name] = value
      this.storage(this.data)

      this.updateClassName(this.data)

      if (window.LIA.send) {
        window.LIA.send({
          reply: true,
          track: [[this.PORT, -1]],
          service: this.PORT,
          message: {
            cmd: 'init',
            param: this.data,
          },
        })
      }
    }
  },

  get table_of_contents(): boolean {
    return this.data.table_of_contents
  },
  set table_of_contents(value: boolean) {
    this.setter('table_of_contents', value)
  },

  get mode(): Lia.Mode {
    return this.data.mode
  },
  set mode(value: Lia.Mode) {
    this.setter('mode', value)
  },

  get theme(): string {
    return this.data.theme
  },
  set theme(value: string) {
    this.setter('theme', value)
  },

  get light(): boolean {
    return this.data.light
  },
  set light(value: boolean) {
    this.setter('light', value)
  },

  get editor(): string {
    return this.data.editor
  },
  set editor(value: string) {
    this.setter('editor', value)
  },

  get font_size(): number {
    return this.data.font_size
  },
  set font_size(value: number) {
    this.setter('font_size', value)
  },

  get sound(): boolean {
    return this.data.sound
  },
  set sound(value: boolean) {
    this.setter('sound', value)
  },

  get tooltips(): boolean {
    return this.data.tooltips
  },
  set tooltips(value: boolean) {
    this.setter('tooltips', value)
  },

  get preferBrowserTTS(): boolean {
    return this.data.preferBrowserTTS
  },
  set preferBrowserTTS(value: boolean) {
    this.setter('preferBrowserTTS', value)
  },

  get hideVideoComments(): boolean {
    return this.data.hideVideoComments
  },
  set hideVideoComments(value: boolean) {
    this.setter('hideVideoComments', value)
  },
  set audio(value: { rate: number; pitch: number }) {
    this.data.audio = value
    this.setter('audio', value)
  },
  get audio() {
    return this.data.audio
  },
}
