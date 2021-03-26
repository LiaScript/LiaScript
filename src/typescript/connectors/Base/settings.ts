import Lia from '../../liascript/types/lia.d'
import Port from '../../liascript/types/ports'

export const defaultSettings: Lia.Settings = {
  table_of_contents: window.innerWidth > 620,
  mode: 'Textbook',
  theme: 'default',
  light: true,
  editor: 'dreamweaver',
  font_size: 100,
  sound: true,
  lang: 'en',
}

export function initSettings(
  send: Lia.Send | null,
  data: Lia.Settings = defaultSettings,
  local = false,
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
    let className = `lia-theme-${data.theme} lia-variant-${
      data.light ? 'light' : 'dark'
    }`

    document.documentElement.className = className
  } catch (err) {
    console.warn('settings (className): ', err.message)
  }
}
