import Lia from '../../liascript/types/lia.d'
import Port from '../../liascript/types/ports'


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

export function initSettings(send: Lia.Send | null, data: Lia.Settings = defaultSettings, local = false) {
  if (local) {
    localStorage.setItem(Port.SETTINGS, JSON.stringify(data))
  }

  if (send) {
    send({
      topic: Port.SETTINGS,
      section: -1,
      message: {
        topic: 'init',
        section: -1,
        message: data
      }
    })
  }
};
