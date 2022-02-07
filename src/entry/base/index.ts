import LiaScript from '../../typescript/liascript/index'

import('../../typescript/connectors/Base/index').then(function (Base) {
  let debug = false

  if (process.env.NODE_ENV === 'development') {
    debug = true
  }

  var app = new LiaScript(
    document.body,
    new Base.Connector(),
    false, // allowSync
    debug
  )

  /*
  window.addEventListener('message', event => {
      // IMPORTANT: check the origin of the data!
      switch (event.data.cmd) {
        case "jit":
          app.jit(event.data.param);
          break
        case "goto":
          app.goto(event.data.param);
          break;
        case "reload":
          window.location.reload()
          break
        case "responsivevoice":
          setResponsiveVoiceKey(event.data.param)
          break
        default:
          console.warn("could not handle event: ", event);
      }
  });
  */
})
