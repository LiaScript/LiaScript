import '@babel/polyfill'

import {
  LiaScript
} from '../../javascript/liascript/index.js'
import {
  Connector
} from '../../javascript/connectors/Base/index.js'

let debug = false

if (process.env.NODE_ENV === 'development') {
  debug = true
}

var app = new LiaScript( document.body, new Connector(), debug )

window.showFootnote = (key) => app.footnote(key);
window.gotoLia = (line) => app.goto(line);
window.jitLia = (code) => app.jit(code);

/*
window.liaGoto = function(line) {
  window.top.postMessage({cmd: "goto", param: line});
}

window.liaLog = function(e) {
  window.top.postMessage({cmd: "log", param: e});
}
*/

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
      default:
        console.warn("could not handle event: ", event);
    }
});
