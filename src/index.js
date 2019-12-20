import "babel-polyfill"

import { LiaScript } from './javascript/liascript/index.js'


if (document.getElementById('lia')) {
  var app = new LiaScript(
    document.getElementById('lia'),
    process.env.NODE_ENV !== 'production'
  )
}
