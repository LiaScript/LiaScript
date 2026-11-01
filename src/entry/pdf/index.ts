import * as Lia from '../../typescript/liascript/index'

// Paper cannot be clicked, so every <details> is printed expanded.
new MutationObserver(() =>
  document
    .querySelectorAll('details:not([open])')
    .forEach((details) => details.setAttribute('open', '')),
).observe(document.body, { childList: true, subtree: true })

import('../../typescript/connectors/Base/index').then(function (Base) {
  let debug = false

  var app = new Lia.LiaScript(new Base.Connector(), {
    allowSync: false,
    debug: false,
    fullPage: true,
  })
})
