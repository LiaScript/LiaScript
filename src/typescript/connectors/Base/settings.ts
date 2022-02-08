import Lia from '../../liascript/types/lia.d'

const defaultSettings: Lia.Settings = {
  table_of_contents: window.innerWidth > 768,
  mode: 'Textbook',
  theme: 'default',
  light: true,
  editor: 'dreamweaver',
  font_size: 1,
  sound: true,
  lang: 'en',

  tooltips: false,
}

export const Settings = {
  PORT: 'settings',

  default: defaultSettings,

  init: function (data: Lia.Settings | null, local = false) {
    if (!data) {
      data = defaultSettings

      if (local) {
        localStorage.setItem(this.PORT, JSON.stringify(data))
      }

      this.updateClassName(data)
    }
    return data
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
}
