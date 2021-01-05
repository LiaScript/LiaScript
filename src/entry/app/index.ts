import "@babel/polyfill"

import LiaScript from '../../javascript/liascript/index'
import { Connector } from '../../javascript/connectors/Browser/index'

const ua = window.navigator.userAgent

if (ua.indexOf('Trident/') > 0 ||
  ua.indexOf('MSIE ') > 0) {
  console.warn('unsupported browser')

  const elem = document.getElementById('IE-message')

  if (elem) elem.hidden = false
} else {
  let debug = false

  if (process.env.NODE_ENV === 'development') {
    debug = true
  }

  const app = new LiaScript(document.body, new Connector(), debug)
}
