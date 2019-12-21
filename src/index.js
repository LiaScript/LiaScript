import "@babel/polyfill"

import { LiaScript } from './javascript/liascript/index.js'

let ua = window.navigator.userAgent;

if (ua.indexOf('Trident/') > 0 ||
    ua.indexOf('MSIE ')    > 0) {
    console.warn("unsupported browser");
    document.getElementById("IE-message").hidden = false;
} else if (document.getElementById('lia')) {
  var app = new LiaScript(
    document.getElementById('lia'),
    false //process.env.NODE_ENV !== 'production'
  )
}
