import '@babel/polyfill'

import LiaScript from '../../typescript/liascript/index'
import { Connector } from '../../typescript/connectors/Base/index'
import TTS from '../../typescript/liascript/tts'

let debug = false

if (process.env.NODE_ENV === 'development') {
  debug = true
}

var app = new LiaScript( document.body, new Connector(), debug )

window.showFootnote = (key) => app.footnote(key);
window.gotoLia = (line) => app.goto(line);
window.jitLia = (code) => app.jit(code);

window.setResponsiveVoiceKey = TTS.inject

window.addEventListener('message', event => {
    // IMPORTANT: check the origin of the data!
    switch (event.data.cmd) {
      case "jit":
        app.jit(event.data.param);
        break
      case "goto":
        app.goto(event.data.param);
        break;
      case "reload":
        window.location.reload()
        break
      case "responsivevoice":
        TTS.inject(event.data.param)
        break
      default:
        console.warn("could not handle event: ", event);
    }
});
