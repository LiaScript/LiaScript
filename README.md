<!--

author:   André Dietrich
email:    LiaScript@web.de
version:  0.16.3
language: en
narrator: UK English Male

comment:  Main LiaScript Parser project, written in elm.

-->

[![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/course.svg)](https://LiaScript.github.io/course/?https://github.com/LiaScript/docs) [![Gitter](https://badges.gitter.im/LiaScript/community.svg)](https://gitter.im/LiaScript/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

![GitHub contributors](https://img.shields.io/github/contributors/liascript/liascript)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/liascript/liascript)
![GitHub repo size](https://img.shields.io/github/repo-size/liascript/liascript)

# LiaScript📝🚀

**Create fully interactive, offline-capable online courses using Markdown – perfect for educators, NGOs, and developers.**

[![Try Live](https://img.shields.io/badge/Try%20Live-Demo%20in%20Browser-brightgreen)](https://liascript.github.io/LiveEditor/?/show/file/https://raw.githubusercontent.com/LiaScript/Hello-LiaScript/refs/heads/main/README.md)
[![License: BSD3](https://img.shields.io/badge/license-BSD3-blue.svg)](LICENSE)
[![Made with Markdown](https://img.shields.io/badge/Made%20with-Markdown-blueviolet)](https://github.com/LiaScript)
[![GitHub issues](https://img.shields.io/github/issues/LiaScript/LiaScript)](https://github.com/LiaScript/LiaScript/issues)
[![Twitter Follow](https://img.shields.io/twitter/follow/LiaScript)](https://twitter.com/LiaScript)


## 🚀 What is LiaScript?

**LiaScript** is an open-source interpreter that turns static Markdown files into fully interactive learning experiences – rendered directly in the browser, even offline. It’s built for:

- 🎓 **Educators**: Craft structured lessons with quizzes, animations, TTS, and live code.
- 🌍 **NGOs**: Distribute multilingual, low-bandwidth-friendly content, globally and for free.
- 💻 **Developers**: Document APIs or teach programming with executable code and narration.

https://github.com/user-attachments/assets/7cab2d61-5858-4b62-87bf-0598e44af2e7


## ✨ Features

- ✅ **Plain Markdown-compatible** with educational extensions
- ❓ **Quizzes, cloze tests, and surveys**
- 🗣️ **Text-to-Speech (TTS)** in multiple languages
- 💻 **Live Code execution** (JavaScript, Python via Pyodide, MicroPython, etc.)
- 📊 **ASCII diagrams, charts, and tables**
- 📲 **PWA support** – works completely offline
- 📤 **Export to PDF, SCORM, IMS**
- 🔌 **Plugin system and macros**
- 👥 **Peer-to-Peer mode** for offline-first collaboration
- much more ...

## 🧪 Get Started in 60 Seconds

1. Create a Markdown file:

   ```markdown
   # Hello LiaScript

   {{|>}}
   Welcome to this interactive course.

   What is 2 + 2?

   - [( )] 3
   - [(X)] 4
   - [( )] 5
   ```

2. Host it (e.g., on GitHub)

   📦 Example: https://github.com/yourname/my-course/README.md

3. Open it in your browser:

   `https://liascript.github.io/course/?https://github.com/yourname/my-course/README.md`

### Alternatively

1. Open the [LiveEditor](https://liascript.github.io/LiveEditor/?/show/code/H4sIAAAAAAAAA1NW8EjNyclX8MlMDE4uyiwo4eKqrq6xq63lCk/NSc7PTVUoyVcoycgsVsjMK0ktSkwuySxLVUjOLy0qTtXj4grPSCxRAEoaKWgrGNlzcekqRGsoaMYqGINZEUCWCVzMFADtbaoFbAAAAA==)

2. Change the example and click on parsing

3. Export it to GitHub gist, Nostr, or share it directly as a data-URI (only within the URL).

## 📚 Resources & Showcase

| Resource                                                                                            | Description                                             |
| --------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| [Blog](https://LiaScript.github.io)                                                                 | News, features, tutorials, examples and more            |
| [LiveEditor](https://liascript.github.io/LiveEditor/examples.html)                                  | Online & browser only editor for LiaScript              |
| [Docs](https://liascript.github.io/course/?https://github.com/LiaScript/docs)                       | Full documentation, syntax, tutorials                   |
| [YouTube Channel](https://www.youtube.com/@liascript4180)                                           | Video guides & examples                                 |
| [Exporter-CLI](https://github.com/LiaScript/LiaScript-Exporter)                                     | PDF/SCORM/IMS/WEP/Project exporter                      |
| [Markdownify JSON -> LiaScript](https://github.com/LiaScript/markdownify)                           | AI-compatible JSON course generator                     |
| [VSCode Preview Plugin](https://liascript.github.io/blog/install-visual-studio-code-with-liascript) | Live Preview courses in VSCode                          |
| [VSCode Web-Preview Plugin](https://liascript.github.io/vscode-web)                                 | Live Preview courses in VSCode-Web (https://github.dev) |
| [Atom Preview Plugin](https://liascript.github.io/blog/install-atom-with-liascript)                 | Live Preview courses in Atom                            |
| [Development Server](https://liascript.github.io/development-server)                                | Lvve Preview courses with any editor                    |

---

## 👩‍💻 Join the Community

### 💬 Engage

* Ask questions in [GitHub Discussions](https://github.com/LiaScript/LiaScript/discussions)
* See what others are building in [LiaScript Courses](https://github.com/topics/liascript-course)
* Create your own extensions and share them [LiaScript Templates](https://github.com/topics/liascript-template)
* Found a bug or have an idea? → [Open an issue](https://github.com/LiaScript/LiaScript/issues)
* Extend the internationalization: [Create or correct a Translation](https://github.com/liaScript/lia-localization/locale)

## 🌍 For NGOs & OER Projects

We welcome collaborations with:

* 📚 Open Education Initiatives
* 🌱 Non-profit training programs
* 🏫 Teachers & universities worldwide

> Let’s build a global library of interactive knowledge.

## ⚙️ Dev Tools & Automation

* Use our [Exporter-CLI](https://liascript.github.io/exporter/) to export courses to PDF/SCORM/IMS/Index/Web
* Automate deployment with GitHub Actions [(Examples)](https://liascript.github.io/categories/automation)
* Convert AI-generated JSON to Markdown using [Markdownify](https://github.com/LiaScript/markdownify)

## 📜 License

Licensed under the BSD3 License – 100% free and open.

## 📣 Stay in Touch


* ✉️ Newsletter: [Typeform](https://liascript.github.io/newsletter)
* 💬 Twitter: [@LiaScript](https://twitter.com/LiaScript)
* 📫 Email: [LiaScript@web.de](mailto:liascript@web.de)

---

*“Markdown is just text – LiaScript turns it into learning.”*


## Build

Use the following commands to download the LiaScript source-code and to build it locally.

```bash
git clone https://github.com/liascript/liascript

cd liascript

npm i

npm run watch  # develop in watch-mode

npm run build  # build to dist
```

After your first build, you can run the following commands, this will download additional
elm-patches and apply them:

```bash
git submodule update --init --recursive

cd patches

make

cd .. # go back

rm -rf elm-stuff .parcel-cache # remove all cached stuff

npm run build # force an entire rebuild of the project
```

This will apply the following four patches:

- elm-break-dom: allows browser extensions such as screen-readers to change the
  nodes of the app, without crashing the app

- elm-patch/url: enables the file-protocol, which is only required when building
  Desktop-apps

- elm-patch/dom: enable onclick events as well as innerHTML

- Dexie: this will allow only LiaScript to access indexedDB, which increases the
  security, by restricting the access. This way information about user states,
  visited courses, etc. cannot be leaked or spied by other JavaScript modules.

## Preview

If you want to add a preview-link for the course to your site, simply add the
following script to the head of your website and place the custom webcomponent
`preview-lia` anyone in your document, with `src` pointing to your LiaScript
course.

```html
<html>
  <head>
    ...
    <!-- add preview-lia tag support to display all course related information -->
    <script
      type="text/javascript"
      src="https://liascript.github.io/course/preview-lia.js"
    ></script>
    ...
  </head>
  <body>
    ...
    <preview-lia
      src="https://raw.githubusercontent.com/liaScript/docs/master/README.md"
    ></preview-lia>
    ...
  </body>
</html>
```

## Badges

Simply replace `URL` at the end of the snippet below with your desired GitHub
repository (and the main README.md of your master-branch will be used) or
directly point to any Markdown-file anywhere within the web.

**Badges:**

- course:

  [![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/course.svg)](https://LiaScript.github.io/course/?https://github.com/LiaScript/docs)

  `[![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/course.svg)](https://LiaScript.github.io/course/?URL)`

- learn more:

  [![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/learn_more.svg)](https://LiaScript.github.io/course/?https://raw.githubusercontent.com/LiaScript/docs/master/README.md)

  `[![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/learn_more.svg)](https://LiaScript.github.io/course/?URL)`
