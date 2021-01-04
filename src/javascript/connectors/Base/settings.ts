import Lia from '../../liascript/types.d'

export const SETTINGS = 'settings'

export const defaultSettings: Lia.Settings = {
      table_of_contents: true,
      mode: 'Slides',
      theme: 'default',
      light: true,
      editor: 'dreamweaver',
      font_size: 100,
      sound: true,
      lang: 'en'
    }

export function initSettings (send: Lia.Send | null, data: Lia.Settings = defaultSettings, local = false) {
  if (local) {
    localStorage.setItem(SETTINGS, JSON.stringify(data))
  }

  if (send) {
    send({
      topic: SETTINGS,
      section: -1,
      message: {
        topic: 'init',
        section: -1,
        message: data
      }
    })
  }
};
