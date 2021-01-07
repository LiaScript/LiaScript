import '@babel/polyfill'

import LiaScript from '../../typescript/liascript/index'
import { Connector } from '../../typescript/connectors/Base/index'

let debug = false

if (process.env.NODE_ENV === 'development') {
  debug = true
}

const app = new LiaScript(document.body, new Connector(), debug)
