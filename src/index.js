import "@babel/polyfill"

import { LiaScript } from './javascript/liascript/index.js'
import { Connector } from './javascript/connectors/SCORM1.2/index.js'


let ua = window.navigator.userAgent;

if (ua.indexOf('Trident/') > 0 ||
    ua.indexOf('MSIE ')    > 0 ) {
    console.warn("unsupported browser");
    document.getElementById("IE-message").hidden = false;
} else {
  let debug = false;

  if (process.env.NODE_ENV === 'development') {
    debug = true
  }

  var app = new LiaScript( document.body, new Connector(), debug )
}
