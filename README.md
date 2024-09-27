<!--

author:   André Dietrich
email:    LiaScript@web.de
version:  0.16.0
language: en
narrator: UK English Male

comment:  Main LiaScript Parser project, written in elm.

-->

[![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/course.svg)](https://LiaScript.github.io/course/?https://github.com/LiaScript/docs) [![Gitter](https://badges.gitter.im/LiaScript/community.svg)](https://gitter.im/LiaScript/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

![GitHub contributors](https://img.shields.io/github/contributors/liascript/liascript)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/liascript/liascript)
![GitHub repo size](https://img.shields.io/github/repo-size/liascript/liascript)

# LiaScript

[LiaScript](https://LiaScript.github.io) is an extension to Markdown to support
the creation of free and open online courses, interactive books and thus, Open
Educational Resources (OER). Courses are simple text-files, that can be hosted
and created freely by everyone similar to Open-Source project. This projects
contains the just-in-time compiler that runs directly within your browser.

**Website:** https://LiaScript.github.io

**Extension:**

- Multimedia
- Quizzes
- Text2Speech
- Animations
- Surveys
- Interactive Tables
- ASCII-art
- Online Programming
- Integration of JavaScript
- Mixing HTML with Markdown
- Extendability due to Macros
- Internal event system
- Literal programming
- ...

Furthermore, this project is a
[Progressive Web App (PWA)](https://en.wikipedia.org/wiki/Progressive_web_application)
, which means, if you open your LiaScript document at the project site at
https://LiaScript.github.io/course/ , the document gets stored on your Browser
like in your personal library. The Website can be installed locally and all
states are also stored within your system locally. Thus, you have total access
to your courses even if you are offline. And sharing a course is simply, sharing
the link to the README.md file.

## Docs & Impressions

To get an impression of the [LiaScript](https://LiaScript.github.io)
capabilities see the docs at

- GitHub: https://github.com/LiaScript/docs
- LiaScript: https://LiaScript.github.io/course/?https://github.com/LiaScript/docs

or checkout the videos at:

- Channel: https://www.youtube.com/channel/UCyiTe2GkW_u05HSdvUblGYg
- Elm-Europe 2019: https://www.youtube.com/watch?v=w_CRABsJNKA&list=PL-cYi7I913S_oRLJEpsVbSTq_OOMSXlPD&index=2

## Related Projects

**Editor:** There are currently two plugins available for the GitHub-Editor
[Atom](https://atom.io), that should help to ease the writing process of
LiaScript courses.

- [liascript-preview](https://github.com/andre-dietrich/liascript-preview): Is a tiny
  previewer that, if it was toggled, updates the view on your course each time
  you save your document.

- [liascript-snippets](https://github.com/andre-dietrich/liascript-snippets): If you
  start typing "lia" in your document you switch on a fuzzy search, that
  contains a lot of LiaScript help, examples, and snippets.

Additionally it is also possible to use [VS-Code](https://code.visualstudio.com/Download)
as an editor for creating LiaScript online courses. The packages work similar to the
upper ones, but to enable the preview the Dev-Server is used for the previews in
[VS-Code](https://code.visualstudio.com/Download):

- [liascript-preview](https://marketplace.visualstudio.com/items?itemName=LiaScript.liascript-preview)
- [liascript-snippets](https://marketplace.visualstudio.com/items?itemName=LiaScript.liascript-snippets)
- [liascript-preview-web](https://marketplace.visualstudio.com/items?itemName=LiaScript.liascript-preview-web)

---

**LiaScript-DevServer:** If you your another editor you can also use this
project to run your own LiaScript server that monitors your files and performs
an update of your preview, whenever you save your files...

- Project-Sources:
  https://github.com/LiaScript/LiaScript-DevServer/

- or install directly from
  [npmjs.com](https://www.npmjs.com/package/@liascript/devserver)
  via:

  `npm install -g @liascript/devserver`

---

**CodiMD -> LiaMD:** At the
[#SemesterHack](https://hochschulforumdigitalisierung.de/de/online-hackathon)
we updated the free and open online editor for Markdown (CodiMD) to work with
LiaScript. This can now be used to setup and host your own LiaScript online
editor, and it runs also in docker.

- Project-Sources:
  https://github.com/liascript/codimd

- Result-presentation of the hackathon:
  https://semesterhack.incom.org/project/187

---

**LiaScript-Exporter:** Currently a command-line tool to export
LiaScript-courses to other formats. At the moment SCORM1.2 and SCORM2004 are
supported, which allow to upload a course packed as zip, into nearly every
commonly used Learning Management System (LMS). A list of supported LMS is
contained within the project description. It has been tested with
[Moodle](https://moodle.org) and [OPAL](https://bildungsportal.sachsen.de/opal).
Additionally it is possible to export courses to the IMS-Cartridge format, PDF,
standalone web-projects and Android APKs.

GitHub: https://github.com/LiaScript/LiaScript-Exporter/

---

**Localization:** The project internationalization files are contained at

https://github.com/liaScript/lia-localization/locale

If you want to contribute, add a new translation file ...

## Examples

**Templates:** Since courses can make use of JavaScript, HTML, CSS, ETC, and
encapsulate functionality within Macros, these Macros can be imported by other
courses. A set of importable documents is hosted at
[GitHub](https://github.com). Every document is a self-contained course
describing the usage of Macro and their implementation.

GitHub: https://github.com/topics/liascript-template

**Library:** At the moment there is a collection of some open tutorials and
complete ports of some Wikibooks (about C Programming, Lua, etc.) that are now
interactive.

GitHub: https://github.com/topics/liascript-course

**Further Examples:**

- https://github.com/andre-dietrich/e-Learning-2019
- https://github.com/andre-dietrich/BerLearn-Talk-2019
- https://github.com/andre-dietrich/Tutorial_Regelungstechnik
- https://github.com/andre-dietrich/TensorFlowJS_tutorial
- https://github.com/andre-dietrich/elmeurope-2019
- https://github.com/SebastianZug/CsharpCourse
- https://github.com/SebastianZug/CCourse
- https://github.com/SebastianZug/CodingEventFreiberg
- https://github.com/SebastianZug/WillkommenAufLiaScript
- https://github.com/SebastianZug/Lia_Gatter

## Contribute

Start writing online courses, translate your PowerPoint presentations, Word
documents, LMS courses, etc. into LiaScript Markdown and host them on
[GitHub](https://github.com), but [Dropbox](https://www.dropbox.com) is also
okay. Make your content and notes accessible and searchable on GitHub, so that
it is not lost over time.

If you know some nice JS libraries or services, create a template course, that
can be imported into other courses, to make them even fancier. You can host them
in your own GitHub repository.

LiaScript has a set of connectors to store and retrieve data from different
"Backends". At the moment there are three versions, a basic connector, a pwa
connector that makes use of IndexedDB to store data, and a SCORM1.2 connector.
It would be great to support a wider range of systems and LMS formats (e.g.
AICC, xAPI, cMi5).

It exists an an [editor](https://github.com/liaScript/LiaScript/tree/editor)
branch, that is currently used to connect to Atom via the
[liascript-preview](https://github.com/andre-dietrich/liascript-preview) Plugin.
It would be great, to support also other editors in the future.

Add some more localization files to: https://github.com/liaScript/lia-localization

I could not compile the project so far, that it runs on Internet explorer and
other older Browsers, that are still in use. Is there is an expert on Babel and
Parcel out there, who could help?

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

## Contact

Author: André Dietrich

eMail: LiaScript@web.de

Website: https://LiaScript.github.io
