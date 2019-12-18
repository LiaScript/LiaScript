import "babel-polyfill"


import { LiaScript } from './javascript/liascript/index.js'

if (document.getElementById('lia')) {
  if (process.env.NODE_ENV !== 'production') {
    var app = new LiaScript(document.getElementById('lia'), false)
  } else {
    var app = new LiaScript(document.getElementById('lia'), false)
  }
}
