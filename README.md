<!--

author:   André Dietrich
email:    LiaScript@web.de
version:  0.6.4
language: en
narrator: UK English Male

comment:  Main LiaScript Parser project, written in elm.

-->

[![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/course.svg)](https://LiaScript.github.io/course/?https://github.com/LiaScript/docs) [![Gitter](https://badges.gitter.im/LiaScript/community.svg)](https://gitter.im/LiaScript/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

# LiaScript

[LiaScript](https://LiaScript.github.io) is an extension to Markdown to support
the creation of free and open online courses, interactive books and thus, Open
Educational Resources (OER). Courses are simple textfiles, that can be hosted
and created freely by everyone similar to Open-Source project. This projects
contains the just-in-time compiler that runs directly within your browser.

__Website:__ https://LiaScript.github.io

__Extension:__

* Multimedia
* Quizzes
* Text2Speech
* Animations
* Surveys
* Interactive Tables
* ASCII-art
* Online Programming
* Integration of JavaScript
* Mixing HTML with Markdown
* Extentendability due to Macros
* Internal event system
* Literal programming
* ...

Furthermore, this project is a
[Progressive Web App (PWA)](https://en.wikipedia.org/wiki/Progressive_web_application)
, which means, if you open your LiaScript document at the project site at
https://LiaScript.github.io/course/ , the document gets stored on your Browser
linke in your personal library. The Website can be installed localy and all
states are also stored within your system locally. Thus, you have total access
to your courses even if you are offline. And sharing a cours is simply, sharing
the link to the README.md file.


## Docs & Impressions

To get an im pression of the [LiaScript](https://LiaScript.github.io)
capabilities see the docs at

* GitHub: https://github.com/LiaScript/docs
* LiaScript: https://LiaScript.github.io/course/?https://github.com/LiaScript/docs

or checkout the videos at:

* Channel: https://www.youtube.com/channel/UCyiTe2GkW_u05HSdvUblGYg
* Elm-Europe 2019: https://www.youtube.com/watch?v=w_CRABsJNKA&list=PL-cYi7I913S_oRLJEpsVbSTq_OOMSXlPD&index=2


## Related Projects

__Editor:__ There are currently two plugins available for the GitHub-Editor
[Atom](https://atom.io), that should help to ease the writing process of
LiaScript courses.

* [liascript-preview](https://atom.io/packages/liascript-preview): Is a tiny
  previewer that, if it was toggled, updates the view on your course each time
  you save your document.

  GitHub: https://github.com/andre-dietrich/liascript-preview

* [liascript-snippets](https://atom.io/packages/liascript-snippets): If you
  start typing "lia" in your document you switch on a fuzzy search, that
  contains a lot of LiaScript help, examples, and snippets.

  GitHub: https://github.com/andre-dietrich/liascript-snippets

--------------------------------------------------------------------------------


__CodiMD -> LiaMD:__ At the
[#SemesterHack](https://hochschulforumdigitalisierung.de/de/online-hackathon)
we updated the free and open online editor for Markdown (CodiMD) to work with
LiaScript. This can now be used to setup and host your own LiaScript online
editor, and it runs also in docker.

* Project-Sources:
  https://github.com/liascript/codimd

* Result-presentation of the hackathon:
  https://semesterhack.incom.org/project/187

--------------------------------------------------------------------------------


__LiaScript-Exporter:__ Currently a command-line tool to export
LiaScript-courses to other formats. At the moment SCORM1.2 is supported that
allows to upload a course packed as zip, into nearly every commonly used
Learning Management System (LMS). A list of supported LMS is contained within
the project description. It has been tested with [moodle](https://moodle.org)
and [OPAL](https://bildungsportal.sachsen.de/opal).

GitHub: https://github.com/LiaScript/LiaScript-Exporter/

--------------------------------------------------------------------------------


__Localization:__ The project internationlization files are contained at

https://github.com/liaScript/lia-localization/locale

If you want to contribute, add a new translation file ...


## Examples

__Templates:__ Since courses can make use of JavaScript, HTML, CSS, ETC, and
encapsulate functionality within Macros, these Macros can be imported by other
courses. A set of importable documents is hosted at
[GitHub](https://github.com). Every document is a self-contained course
describing the usage of Macro and their implementation.

GitHub: https://github.com/LiaTemplates

__Library:__ At the moment there is a collection of some open tutorials and
complete ports of some Wikibooks (about C Programming, Lua, etc.) that are now
interactive.

GitHub: https://github.com/LiaBooks

__Further Examples:__

* https://github.com/andre-dietrich/e-Learning-2019
* https://github.com/andre-dietrich/BerLearn-Talk-2019
* https://github.com/andre-dietrich/Tutorial_Regelungstechnik
* https://github.com/andre-dietrich/TensorFlowJS_tutorial
* https://github.com/andre-dietrich/elmeurope-2019
* https://github.com/SebastianZug/CsharpCourse
* https://github.com/SebastianZug/CCourse
* https://github.com/SebastianZug/CodingEventFreiberg
* https://github.com/SebastianZug/WillkommenAufLiaScript
* https://github.com/SebastianZug/Lia_Gatter

## Contribute

Start writing online courses, translate your PowerPoint presentations, Word
documents, LMS courses, etc. into LiaScript Markdown and host them on
[GitHub](https://github.com), but [Dropbox](https://www.dropbox.com) is also
okay. Make your content and notes accessable and searchable on GitHub, so that
it is not lost over time.

If you know some nice JS libraries or services, create a template course, that
can be imported into other courses, to make them even fancier. You can host them
in your own GitHub repository.

LiaScript has a set of connectors to store and retrive data from different
"Backends". At the moment there are three versions, a basic connector, a pwa
connector that makes use of indexeddb to store data, and a SCORM1.2 connector.
It would be great to support a wider range of systems and LMS formats (e.g.
SCORM2004, AICC, xAPI, cMi5, IMS Cartridge).

It existis an an [editor](https://github.com/liaScript/LiaScript/tree/editor)
branch, that is currently used to connect to Atom via the
[liascript-preview](https://github.com/andre-dietrich/liascript-preview) Plugin.
It would be great, to support also other editors in the future.

Add some more localization files to: https://github.com/liaScript/lia-localization

I could not compile the project so far, that it runs on Internet explorer and
other older Browsers, that are still in use. Is there is an expert on Babel and
Parcel out there, who could help?

## Preview

If you want to add a preview-link for the course to your site, simply add the
follwing script to the head of your website and place the custom webcomponent
`preview-lia` anyone in your document, with `src` pointing to your LiaScript
course.

``` html
<html>
  <head>
  ...
  <!-- add preview-lia tag support to display all course related information -->
  <script type="text/javascript" src="https://liascript.github.io/course/preview-lia.js">
  </script>
  ...
  </head>
  <body>
  ...
  <preview-lia src="https://raw.githubusercontent.com/liaScript/docs/master/README.md">
  </preview-lia>
  ...
  </body>
</html>
```

## Badges

Simply replace `URL` at the end of the snippet below with your desired GitHub
repository (and the main README.md of your master-branch will be used) or
directly point to any Markdown-file anywhere within the web.

__Badges:__

* course:

  [![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/course.svg)](https://LiaScript.github.io/course/?https://github.com/LiaScript/docs)

  `[![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/course.svg)](https://LiaScript.github.io/course/?URL)`

* learn more:

  [![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/learn_more.svg)](https://LiaScript.github.io/course/?https://raw.githubusercontent.com/LiaScript/docs/master/README.md)

  `[![LiaScript](https://raw.githubusercontent.com/LiaScript/LiaScript/master/badges/learn_more.svg)](https://LiaScript.github.io/course/?URL)`


## Version-Changes

* Moved from JavaScript to Typescript
* Optimized internal message-handling
* Scripts can now also create Quizzes, Code, Surveys, etc.
  (scripts cannot create scripts)
* Updated debug-information
* ASCII-art blocks now have a verbatim environment, that is surrounded by either
  single or double quotation marks:

  ````
  ``` ascii
  +------------------------------------+
  |"$$                                "|   Single
  |"   \sum_{i=1}^\infty\frac{1}{n^2} "|   quote
  |"        =\frac{\pi^2}{6}          "|   verbatim
  |"$$                                "|   block
  +------------------------------------+
                   |
                   V
  +------------------------------------+
  |""```js                           ""|   Double quoute
  |""let str = "Hello World!         ""|   verbatim block
  |""alert(str)                      ""|   -
  |""```                             ""|   can contain
  |""<script>@input</script>         ""|   single quotes
  +------------------------------------+
  ```
  ````

__0.8.12__ (08/12/2020)

* better handling of incorrect and incomplete HTML-comments
* inline code does now preserve whitespaces
* table-cells can now also be styled with a starting HTML comment

__0.8.11__ (05/12/2020)

* parsing everything can be difficult, fixed issues with + and - that resulted
  from the last list updates.
* footnotes are clickable again and with multiline support

__0.8.10__ (04/12/2020)

* fixed issues with ordered and unordered lists, as well as quotes...

__0.8.9__ (02/12/2020)

* better JavaScript & HTML & inline code parsing with string escapes
* fix: problem with HTML and JavaScript within block-effects
* removed `~~~` for now ...
* fix: parsing block-html und loading order of js

__0.8.8__ (26/11/2020)

* better script-tag parsing with comments and strings
* scripts can now also produce LiaScript content via the result string:

  ``` html
  <script>`LIASCRIPT:
  $$
     \sum_{i=1}^\infty\frac{1}{n^2}
          =\frac{\pi^2}{6}
  $$
  `</script>

  or:

  <script>
  send.liascript(`
    $$
      \sum_{i=1}^\infty\frac{1}{n^2}
          =\frac{\pi^2}{6}
    $$
  `)
  </script>
  ```

* code-blocks can also be marked with `~~~`
* fixes for qr-code background in dark mode and margin for figures with titles

__0.8.7__ (21/11/2020)

* new funnel diagram type for tables
* better support for lineplots and scatterplot for categories
* new link type for qr-codes: `[qr-code](url)`
* better integration of script with further configurations
* fix in script formatting

__0.8.6__ (18/11/2020)

* updated ASCII-Art, which now now supports escaping via `"`
* updates with eslint & npm update

__0.8.5__ (12/11/2020)

* hotfix: internal macro-parameters work only form @0 ot @9

__0.8.4__ (10/11/2020)

* attached scripts can now also use inputs from detached scripts
* script inputs now react to onEnter events
* fix: nameing issue in web-components
* macros can now have an infinite length of input paratmeters

__0.8.3__ (04/11/20202)

* script format locale default is defined by global language default
* fix: order of script execution corrected in textbook mode
* fix: caching bug in Katex fomulas
* added funnel diagram to table visualization
* optimitzed table diagram generation
* double-click on script now uses an overlay editor


__0.8.2__ (01/11/2020)

* little bugfixes, multiple inputs for scripts and internationlization for scripts outputs...


__0.8.1__ (27/10/2020)

* Support for subHeaders via:

  ```markdown
  subHeader
  =========

  sub-subHeader
  ------------
  ```

__0.8.0__ (26/10/2020)

* script-tags can now be used like web-components, which may return a value:

  * with reactive programming
  * with attached input elements
  * formatting is also possible with Intl

* Terminal supports the output of HTML content via
  `console.html("<img src'= ...>")`
* Terminal output gets truncated after 200 inputs and uses Html.Keyed.node
  for faster rendering


__0.7.12__ (07/10/2020)

* removed Google-Analytics
* upgrade KaTeX to 0.12.0

__0.7.11__ (06/10/2020)

* Added a Makefile for better local development.
* Use `make all KEY="your-key"` with your key for your website from
  https://responsivevoice.com
* Use `make help` to get some help 😏

__0.7.10__ (06/10/2020)

* better internal reference handling, which works now also with unicode-symbols
* stable preprocessor, which handles single `#` more securely
* multimedia captions `![alt](url "title")`, the title element can now contain
  Markdown content, which will be displayed as a caption; it works also for
  audio and video content
* fix: floating bug with tables

__0.7.9__ (29/09/2020)

* tables do not increase the size of the frame anymore
* `[preview-lia](course-url)` depicts now a preview link for the LiaScript
  course in your course. The same can be achieved with the web component
  `<preview-lia src="course-url"></preview-lia>`

  See section [Preview](#Preview) for more information.


__0.7.8__ (28/09/2020)

* updated ascii-art generation, which now supports the usage of emojies, see the
  documentation at: https://github.com/andre-dietrich/elm-svgbob

__0.7.7__ (25/09/2020)

* added laziness to Charts, Tables, and ASCII-art in order to increase speed
* npm updates
* added russian translation

__0.7.6__ (10/09/2020)

* fix: typo in css for grey design
* npm update

__0.7.5__ (10/07/2020)

* fix: jumping on animations on mobile or if content too long ...
* update ace editor to 1.4.12
* updated elm-ui to 1.0.7
* added special classes to quizzes to enable the usage of quiz-banks

__0.7.4__ (07/07/2020)

* fix: some problems with arrow navigation, added `stopPropagationOn` for
  dealing with key-press events that should not interact with the navigation
* fix: some css for cards, such as quizzes and surveys

__0.7.3__ (06/07/2020)

* Editor settings via attributes: `data-theme`, `data-marker`, `data-`...

__0.7.2__ (26/06/2020)

* fix: HTML elements with quoted strings that contain & are now accepted

__0.7.1__ (23/06/2020)

* Added string escaping with an additonal macro-notation `@'name`, which works
  also with `@'1` or `@'input` ...
* New visualization type for tables `data-type="boxplot"`
* More settings for table-diagrams, i.e. `data-title`, `data-xlabel`,
  `data-ylabel`
* fix: Macro debugging caused some errors, due to new HTML handling, this was
  fixed, but the visualization is still not as expected...

__0.7.0__ (14/06/2020)

* Tables are now smarter and can be used also in conjunction with animations
* Supported tables are now (BarChart, ScatterPlot, LineChart, HeatMap, Map,
  Sankey, Graph (directed and undirected), Parallel, Radar, and PieChart)
* Added special tags for table definitions: `data-type`, `data-src`,
  `data-transpose`, `data-show`
* JavaScript execution is now delayed until all resources are loaded
* Unified parsing of HTML attributes and comment attributes
* HTML resources are now also checked if they are relative or not
* fix: single HTML-comments can now also be detached from any Markdown body

__0.6.2__ (19/05/2020)

* Added tag `<lia-keep>`: innerHTML is parsed without checking or parsing for
  Markdown
* fix: HTML-paramters with `-` are now also allowed
* fix: better search, with titles, and search-delete button
* fix: some overflow CSS bugs for quotes and quizzes
* App starts with closed table of contents on mobile devices
* fix: navigation buttons are now all of equal size
* fix: Title tab now shows the main title of the course

__0.6.1__

* Better error handling, faulty Markdown is now parsed until the end of a
  section
* Minor optimizations to speedup JIT compilation.

__0.6.0__

* Started tagging with version numbers
* Added language support for Spanish `es` and Taiwanese(`tw`)/Chinese(`zh`)
* Refactored effects, which now also support `{{|>}}` or `{{|> Voice}}` for main
  manual text2speech output for blocks, as well as an inline notation
  `{|>}{_read me aloud_}` for inlining
* Effect-fragments can be combined with with spoken output `{{|> 1-3}}`


## Contact

Author: André Dietrich

eMail: LiaScript@web.de

Website: https://LiaScript.github.io
