# LiaScript/Chat

[LiaScript/Chat](https://github.com/LiaScript/LiaScript/tree/chat) is a special
branch of LiaScript, published as `@liascript/chat`. It is a chat, where every
message is rendered as LiaScript Markdown: quizzes, surveys, executable code,
macros and templates. The chat only displays, all messages (also those of the
user) are pushed by the host application. Interactions are reported back as
events, the whole chat including all states can be exported and restored as
JSON.

The chat runs within an iframe (`dist/app/index.html`), `<lia-chat>` wraps it.

## Installation

```bash
npm install @liascript/chat
```

## Usage

Serve `node_modules/@liascript/chat/dist/` and include the element:

```html
<script src="/lia-chat/element.js"></script>
<lia-chat style="height: 600px"></lia-chat>
```

The iframe app is expected at `app/index.html` relative to `element.js`. If the
element is imported as a module, set it explicitly:
`<lia-chat app="/lia-chat/app/index.html">`. Relative template URLs are resolved
against `base` (default: the host page URL).

```js
const chat = document.querySelector('lia-chat')

// append a message, its id is its position within the chat (0, 1, 2, ...),
// messages cannot be changed or deleted, only the entire chat can be cleared
chat.add({
  user: 'Assistant', // name shown below the message
  icon: 'data:image/svg+xml,…', // optional avatar (url or data-url, 16px)
  time: Date.now(), // optional, shown as local time
  message: 'Which one?\n\n- [( )] A\n- [(X)] B',
})
chat.add({ user: 'You', self: true, message: 'B' }) // right aligned

// the header of a message applies to the entire chat
chat.add({
  user: 'Assistant',
  message: `<!--
import: https://raw.githubusercontent.com/LiaScript/CodeRunner/master/README.md
-->

\`\`\`python
print("hello")
\`\`\`
@LIA.eval(\`["main.py"]\`, \`none\`, \`python3 main.py\`)`,
})

// load templates, scripts, styles or macros without a visible message
chat.define({
  import: ['https://…/template/README.md'],
  script: ['https://…/lib.js'],
  link: ['https://…/style.css'],
  header: '@hello: <b>Hello @0</b>',
})

chat.addEventListener('store', e => console.log(e.detail)) // {table, id, data}
chat.addEventListener('agent', e => console.log(e.detail)) // "agent:…" link

const json = await chat.export()
chat.clear()
chat.load(json)
```

Script outputs (`output="name"` / `` @input(`name`) ``) are scoped to their
message. Element ids are not, the same id in several messages refers to the
first one, render elements as script output (`"HTML: …"`) instead.

## JSON

```json
{
  "version": 1,
  "messages": [
    {
      "user": "Assistant",
      "icon": "…",
      "time": 1760000000000,
      "color": "",
      "message": "…"
    },
    { "user": "You", "self": true, "color": "", "message": "…" }
  ],
  "db": {
    "quiz": [[], null],
    "survey": [],
    "code": [],
    "task": []
  }
}
```

The index within `messages` is the id of a message, `db` holds one array per
table, indexed by the same id (`null` if the message has no such block). The
data per message is the same as for a LiaScript slide (one entry per
quiz/survey/task/code block).

## Development

```bash
npm run watch:chat   # demo at http://localhost:1234/demo.html
npm run build:chat   # dist/element.js + dist/app/
```
