# LiaScript/Editor

[LiaScript/Editor](https://github.com/LiaScript/LiaScript/tree/editor) is a
special branch of LiaScript that can be used to easily create preview-plugins
for different editor.

Current examples are:

- [**liascript-preview**](https://atom.io/packages/liascript-preview): a plugin
  for the [Atom editor](https://atom.io)

  Code: https://github.com/andre-dietrich/liascript-preview

- [**CodiLIA**](https://github.com/liascript/codilia): a fork of the
  collaborative Markdown [CodiMD](https://github.com/hackmdio/codimd)

  Code: https://github.com/liascript/codilia

## Installation

install via npm:

`npm i @liascript/editor`

> **Note:** The version information might look a bit different e.g.
> `1.0.4--0.9.25`. The second version mirrors current version of LiaScript,
> while the first number is referring to the changes of the editor-branch.

## HowTo

The project itself is a fully fledged LiaScript interpreter that runs on a
website. Thus, if you have installed the editor version via npm, you can
directly call the index.hml and add the url of your file to preview as a
parameter:

`node_modules/@liascript/editor/dist/index.html?file://..../Readme.md`

It is recommended to use a separate webview or iframe for this task

`<webview src="...index.html?file://.../Readme.md">`

`<iframe src="...index.html?file://.../Readme.md">`

Whenever you want to trigger a reload, probably every time the the user saves
the document, you only have to trigger a page reload and the entire content is
parsed again.

> **Note:** Since LiaScript also evaluates JavaScript code, it is always the
> most secure way of using iframes and webviews, since they decouple your editor
> from the LiaScript-view, furthermore webviews run within their own thread, so
> that your IDE does not have to share resources for editing and rendering.

However there are two additional features, that can also be used in conjunction
with this branch...

### Navigation

To enable editor to preview navigation, you will have to identify the current
line-position within the editor that you want to see also on the preview.
Ideally this is triggered by **(1)** subscribing for a double-click event,
**(2)** identify the current cursor-position, **(3.1)** post a message to the
webview or iframe **(3.2)** or directly call `liaGoto`.

```javascript
let line = editor_.getCursorBufferPosition().row + 1

// 3.1
webview.contentWindow.postMessage({ cmd: 'goto', param: line })

// 3.2
webview.contentWindow.gotoLia(line)
```

The other way around works similar, you will have to overwrite internally
exposed global function `liaGoto` and move your cursor to the provided line:

```javascript
webview.contentWindow.liaGoto = function (line) {
  editor.setCursor({ line: line, ch: 0 })
  editor.focus()
}
```

### Just-in-Time compilation

Instead of forcing the preview to reload all content, you can also use the
experimental Just-in-Time compilation feature, to update the preview while
typing.

It is recommended to load your document, as it was done initially in section
[Usage](#usage), to wait for the ready signal and then to apply an additional
debouncer to minimize the update overhead and increase performance 😏

Similar to the previous example, there are two ways of updating the code, either
by messaging or by calling the exposed function `jitLia`. `isReady` will be
called by LiaScript if everything is set-up and the first instance of the course
was loaded and parsed.

```javascript
let isReady = false
window.liaReady = function() {
  isReady = true
}

let jit = function () {
  webview.contentWindow.postMessage({cmd: "jit", param: editor_.getText()});
}

let jit = function () {
  webview.contentWindow.jitLia(editor_.getText())
}

// atom example of a subscription to editor changes
this.subscriptions.add(
  this.editor.getBuffer().onDidChange(
    if (isReady) {
      debounce(jit, 500)
    }
  )
);
```

> Calling `jit` applies some form of dynamic parsing to increase the parsing
> speed and to minimize computational overhead. Thus, it is a bit tricky at the
> moment, if you are working with javascript that gets reevaluted on every
> change (for the visible slide).
>
> I would recommend two modes: **load on save** and **jit** and let the user
> decide, if possible.

### Text2Speech output

Unfortunately, there is currently no general browser support for text2speech
output. [responsivevoice](https://responsivevoice.org) is applied by LiaScript
as the default text2speech engine. It is free for non-profit & educational
projects. However, you will have to provide a key for your project/website.

There are multiple ways s of injecting code, one way is to dynamically insert
a new script to your document, as it is depicted below.
_(But you can also edit the index.html and add a script manually)_

```javascript
window.onload = function () {
  let responsiveVoiceKey = '*******'

  var script = document.createElement('script')
  script.src =
    'https://code.responsivevoice.org/responsivevoice.js?key=' +
    responsiveVoiceKey

  document.body.appendChild(script)

  // IMPORTANT: This is mandatory, otherwise responsiveVoice
  // might not be initialized correctly!!!
  script.onload = () => {
    window.responsiveVoice.init()
  }
}
```

However, you can also use one of the following methods:

```javascript
webview.contentWindow.postMessage({ cmd: 'responsivevoice', param: 'YOUR_KEY' })

webview.contentWindow.setResponsiveVoiceKey('YOUR_KEY')
```

## Contact

Author: André Dietrich

eMail: LiaScript@web.de

Website: https://LiaScript.github.io
