import '@babel/polyfill'

import LiaScript from '../../typescript/liascript/index.ts'
import {
  Connector
} from '../../typescript/connectors/SCORM1.2/index.js'

const ua = window.navigator.userAgent

if (ua.indexOf('Trident/') > 0 ||
  ua.indexOf('MSIE ') > 0) {
  console.warn('unsupported browser')
  document.getElementById('IE-message').hidden = false
} else {
  let debug = false

  if (process.env.NODE_ENV === 'development') {
    debug = true
  }

  const app = new LiaScript(document.body, new Connector(), debug)
}
