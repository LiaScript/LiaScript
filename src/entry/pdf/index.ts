import * as Lia from '../../typescript/liascript/index'

import('../../typescript/connectors/Base/index').then(function (Base) {
  let debug = false

  var app = new Lia.LiaScript(new Base.Connector(), {
    allowSync: false,
    debug: false,
    fullPage: true,
  })
})
