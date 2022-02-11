import LiaScript from '../../typescript/liascript/index'

import('../../typescript/connectors/Base/index').then(function (Base) {
  let debug = false

  var app = new LiaScript(
    document.body,
    new Base.Connector(),
    false, // allowSync
    false, // debug
    true // fullPage
  )
})
