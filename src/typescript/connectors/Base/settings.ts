import Lia from '../../liascript/types/lia.d'
import Port from '../../liascript/types/ports'

export const defaultSettings: Lia.Settings = {
  table_of_contents: window.innerWidth > 768,
  mode: 'Textbook',
  theme: 'default',
  light: true,
  editor: 'dreamweaver',
  font_size: 1,
  sound: true,
  lang: 'en',
}

export function initSettings(
  send: Lia.Send | null,
  data: Lia.Settings = defaultSettings,
  local = false
) {
  if (local) {
    localStorage.setItem(Port.SETTINGS, JSON.stringify(data))
  }

  updateClassName(data)

  if (send) {
    send({
      topic: Port.SETTINGS,
      section: -1,
      message: {
        topic: 'init',
        section: -1,
        message: data,
      },
    })
  }
}

export function updateClassName(data: Lia.Settings) {
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
  } catch (err) {
    console.warn('settings (className): ', err.message)
  }
}
