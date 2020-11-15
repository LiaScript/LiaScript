import "@babel/polyfill"

import {
  LiaScript
} from '../../javascript/liascript/index.js'
import {
  Connector
} from '../../javascript/connectors/Base/index.js'


let debug = false;

if (process.env.NODE_ENV === 'development') {
  debug = true
}

var app = new LiaScript(document.body, new Connector(), debug)