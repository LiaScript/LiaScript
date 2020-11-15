const SETTINGS = 'settings'

function initSettings(send, data, local = false) {

  if (data == null) {
    data = {
      table_of_contents: true,
      mode: 'Slides',
      theme: 'default',
      light: true,
      editor: 'dreamweaver',
      font_size: 100,
      sound: true,
      land: 'en'
    }
  }

  if (local) {
    localStorage.setItem(SETTINGS, JSON.stringify(data))
  }

  send({
    topic: SETTINGS,
    section: -1,
    message: {
      topic: 'init',
      section: -1,
      message: data
    }
  })
};

export {
  initSettings,
  SETTINGS
}