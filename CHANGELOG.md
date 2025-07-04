# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.17.3] - 23/06/2025

- improve: Images in links are now not zoomable anymore
- fix: Matrix quizzes with empty single-choice rows work now as expected
- feat: add `nextcloud://` URL to translate self-hosted nextcloud links properly

## [0.17.2] - 04/06/2025

- feat: Add progress slider
- improve: voice gender detection for IOS
- improve: error messages for loading failures
- improve: loading from gitlab, codeberg, and other git services now works without a proxy
- fixes: on service workers and caching

## [0.17.1] - 19/05/2025

- fix: Support for `foreignObject` in SVG now scales correctly.
- improve: Self hosted gitlabs can now be referenced with `gitlab://` instead of `https://`. LiaScript will automatically switch to the data api, removing the need for a proxy.
- improve: Video comments with translations are now synced with the text to speech api from the browser.

## [0.17.0] - 13/05/2025

Added SVG integration of LiaScript.
LiaScript code can now be embedded into SVG via the `foreignObject` tag, which allows to combine drawings with animations and LiaScript code to make SVG more interactive.

```markdown
<svg width="400" height="250">
<!-- Circle with blue fill and black border -->
<circle cx="100" cy="100" r="80" fill="lightblue" stroke="black" stroke-width="2" />

<!-- Foreign object with LiaScript formula and animation -->
<foreignObject x="10" y="60" width="180" height="40">

           {{1}}
$$
   \sum_{i=1}^\infty\frac{1}{n^2}
      =\frac{\pi^2}{6}
$$

</foreignObject>
</svg>
```

## [0.16.15] - 08/05/2025

- feat: Add `edit` macro that allows to share a link to the course resource for editing.

  ```markdown
  <!--
  edit: true
  -->

  # Open automatically provide a link to the LiveEditor

  https://LiaScript.github.io/LiveEditor/
  ```

  ---

  ... or provide a link to a custom editor


  ```markdown
  <!--
  edit: https://github.dev/username/repo/...
  -->

  # Provide a link to a custom editor
  ```

- feat: [Nostr](https://nostr.com) as data source is now, which means you can host course content on a decentralized storage. A Nostr-URI typically starts with `npub` or `nsec` and is followed by a base64 encoded string. The Nostr-URI can be used in the same way as a normal URL, but it will be resolved via the Nostr protocol.

  > The LiveEditor provides an export to Nostr.

- feat: Chats in classroom mode now can also execute scripts, but the user has to
  explicitly allow this.

- chors: Upgrade npm packages and trystero

  # Classroom

  This will allow to execute scripts in the classroom mode.
  ```

## [0.16.14] - 14/04/2025

- fix(Formulas): Translating the content with Google-Translate does now not affect formulas anymore.
- chors: Npm update of katex, ace, caniuse, etc
- feat: Special ignore comments added `<!---.*--->`

  Since separating HTML-comments with HTML-parameters is difficult,
  compared to only comments. This new parser introduces a comment with at
  least three dashes, which means that the content will be totally ignored.

  `<!--- Everything style="here" will be ignored --->`

  `<!-- everything style="width: 100" data-will be-kept -->`

## [0.16.12] - 04/04/2025

- fix: length calculation for ASCII-Art with complex emojis
- feat: add time settings to multimedia comments `#t=start,end`

## [0.16.11] - 06/03/2025

- feat(Formulas): Add chemistry support via https://mhchem.github.io/MathJax-mhchem/
- improve(Tooltips): Use Wikipedia to generate tooltips for links
- chore: npm update ace, caniuse, echarts, katex
- improve(Comment): Better video overlay positioning
- fix: Working on kaios again
- update: oEmbed endpoints
- translations: Add Urdu and Georgian
- improve(Index): Add popups to index cards for deleting and resetting courses
- improve(ASCII-Art): Better widechart detection
- fix: Loading courses from zip-files
- improved(a11y): Better keyboard navigation for quizzes and surveys and modals

## [0.16.10] - 04/02/2025

- fix: keyboard switched direction of left right arrow keys

## [0.16.9] - 03/02/2025

- fix: associated scripts work now for gap-text paragraphs
- chore: npm update ace, caniuse, echarts, katex
- a11y:

  - add <kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>C</kbd> for table of Contents toggle
  - add additional keyboard navigation <kbd>Shift</kbd>+<kbd>Alt</kbd>+<kbd>P|N</kbd> for previous and next slide
  - header levels defined by number of `#`
  - remove alt from logo
  - multiple aria-polite and aria-live optimizations for quizzes, tables and formulas, and the terminal output

- feat: in script for the modify parameter it is now possible true or false the modification but also to add a string that is used as a code separator to allow modifications only for a certain part

## [0.16.8] - 06/01/2025

- chore: npm update ace, katex, caniuse-lite
- localization: Updated italian translation
- fix(Link): alt unfinished quotations

  Previously not closing quotations where chomped away when a title link
  was defined:

  ```markdown
  [... "closing" ... "open](#link "title")
  ```
- improve(Links): Title with single quotes

  Now it is possible to add title within single quotes to links as well:

  ```markdown
  - [alt](ref 'title')
  - [alt](ref "title")
  ```

- feat(Table): add data-orientation setting

  using the following

  `<!-- data-orientation="vertical|horizontal" -->`

  above a table allows to change the orientation of the generated diagram...

- improve(Platform support): Courses can now also be loaded directly from the following platform, without requiring a proxy, and thus will not cause any CORS issues:

  - [GitLab](https://gitlab.com)
  - [Codeberg](https://codeberg.org)
  

## [0.16.7] - 14/11/2025

- upgrade: ASCII-Art now a bit faster
- improve(Translations): Add lang without translations

  Previously TTS could only be used if it is supported by responsive
  voice. But since LiaScript now allows to use browser supported TTS with
  locally installed languages, this check has become obsolete. TTS is now
  enabled for all comments, even for languages such as Georgian.

## [0.16.6] - 08/11/2024

- improve: LiaScript preview cards with new design
- fix: HTML parser with combined macros

## [0.16.5] - 07/11/2024

- fix: Add escape `\@` for macros, this will allow to pass escaped parameters to macros, which will not be evaluated by the parser.


## [0.16.4] - 29/10/2024

- improve(Index): The course overview now has a masonry organization of courses with different size for cards. This will allow for a better overview of the courses and a more dynamic layout.
- improve(Cards): Better Design with more options
- improve(Google-Translation): Annoying pop-ups and hover effects are now suppressed.
- Upgrade:
  
  - [x] npm Dexie 4.0.9
  - [x] elm andre-dietrich/parser-combinators
  - [x] elm f0i/statistics
  - [x] elm tesk9/accessible-html

- feat: add . to \\. escape characters

  ``` markdown
  Next to escaping ellipsis, \.\.\. this will now allow to add numbers to lists:

  * 5\.1 ....
  * 5\.2 ....
  ```

- fix(Parser): Arrows have been overwritten by typography

  Rules for typographical dashes kicked in before the arrows, which blocked
  left to right arrows to don't be detected correctly.

  `-->  ->`

## [0.16.3] - 21/10/2024

- feat(Typography): It is now possible within a LiaScript Markdown to apply the following typographical elements:

  - A sequence of dashes is now translated into:

    1. - (single dash): Hyphen or minus sign
    2. -- (double dash): En dash
    3. --- (triple dash): Em dash

  - Translate ... to unicode ellipsis

  - Language base quotes single and double are translated into their typographical counterparts, based on the language of the course. Additionally these two types have been added to the escaped elements `\"` and `\'`.

- improve(HTML-Parser): The parsing speed for HTML has been increased, due to a new abort mechanism, which will stop the parsing of a HTML end-tag has been detected. This will prevent the parser from running into an long loop.

- improve(Parser): Some minor improvements for regular expressions have been applied after benchmarking the parser.

## [0.16.2] - 04/10/2024

- feat(Zip): Courses can now be uploaded as ZIP files, which will be automatically extracted and loaded. Also courses can be hosted as Zip-files, which will be extracted on the fly.

  Additionally, a URL translation for download links for Zip-files stored on the following services is now supported:

  - [GitHub](https://github.com)
  - [OneDrive](https://onedrive.live.com)
  - [Dropbox](https://www.dropbox.com)

- feat(Table): Add `data-sortable` to tables, which can be set to `true` or `false` to enable or disable sorting for a column.
  By default every column is sortable, but this changed globally or on a per column basis. The defintion in the column header will overwrite the global setting.

  ```markdown
  <!-- data-sortable="false" -->
  | Header 1 | <!-- data-sortable="true" --> Header 2 |
  | :------- | :------------------------------------- |
  | Item 1   | Item 2                                 |
  | Item 5   | Item 6                                 |
  | Item 9   | Item 10                                |
  | Item 13  | Item 14                                |
  ```

- feat(Table): Tables of type `none` which are not displayed as an visualization have now a non sticky first column. Previously the first column was sticky, while the others could be moved.

- improve(Quiz): Quiz definitions now allow for escaped strings, such that a text-inputs

  `[[a\|b]]`

  or selections allow

  `[[\(a\) | (b) | \[c\]]]`

- feat(Formula): Pass global `.katex` CSS to webcomponent

  Somehow the global styles were not passed to the webcomponent, although
  the shadow-DOM was open. This is now done explizitly by querying all
  definitions for .katex and injecting them into the webcomponent.

## [0.16.1] - 27/09/2024

- feat: Allow to upload LiaScript courses at the Index-page directly from the device as single files or as ZIP archives
- improve: Hide skip navigation link
- improve(Macro): Escaping of `${` as `\${`

## [0.15.12] - 28/08/2024

- chore: Update npm packages
- improve(Macro): Parameter with more than 3 backticks

  The macro parameters formats had the following format

  - `single,line,parameter,with,commas`
  - ``` multiline `parameters` ```

  The 3 backticks were hard-coded, hence it was not possible to pass markdown-blocks with code-blocks. Now it is possible to define multiline parameters with more than 3 backticks, allowing for more complex parameters. Basically it works like an ordinary code-block now, which can contain other code-blocks with less backticks.

## [0.15.11] - 22/08/2024

- improve: Code-Terminal, which scrolls to the bottom on every new output
- feat: Add backslash followed by a newline in a paragraph, will result in a line-break
- fix: Single images with a block-comment were interpreted as a paragraph with a starting
  image and thus resulted in a shorted image, with half of the size

## [0.15.10] - 14/08/2024

- improve: Translations for code, now also translations for code copy-buttons
- improve: onload will block the execution of other scripts until it is finished

## [0.15.9] - 12/08/2024

- feat: Add pitch and rate settings to TTS comments.
  
  - The pitch can be set between 0 and 2, the rate between 0.1 and 5.

  - Rate is also added to video and audio comments, while keeping the pitch constant.

  - Additionally, the pitch and rate can be modified within the script for the current comment or replayed element as well

    ```markdown
    <!-- data-rate="2.0" data-pitch="1.2" -->
        --{{0}}--
    This element will be read with a higher pitch and rate.

    <!-- data-rate="1.3" -->
        --{{0}}--
    !?[video](/path/to/video.mp4)
    This video will be played with a higher rate, but the pitch will stay the same.

    <!-- data-rate="2.0" data-pitch="1.2" -->
        {{|>}}
    Also for this local playback, the custom data rate and pitch will be used to overwrite the default settings 
    ```

## [0.15.8] - 07/08/2024

- chore: Update npm packages
- improve(Classroom): connect event will also fire if connection is already established
- upgrade: oEmbed endpoints
- feat: enable styling for oEmbeds ... everything link that starts with ??
- fix: overlay video works on chrome mobile, better positioning on the right
- Add Citation.cff for simple citation of the project

## [0.15.7] - 26/07/2024

- improve(VideoComments):

  - Add accessibility features
  - Add video-comments hide to settings, which will only replay the audio
  - Improved z-index handling

## [0.15.6] - 26/07/2024

- fix: SVG emoji sizing in ASCII-art images
- feat: Add video-comments. Video snippets can be added to comments, which will be replayed if the comment is read out loud.

  ```markdown
      --{{1}}--

  !?[|>](video.mp4)
  The upper video is replayed if this comment becomes active.
  ```

## [0.15.5] - 15/07/2024

- chore(Classroom): Upgrade Trystero to 0.19
- refac(Charts): optimized eCharts loading and added `renderer` option, which can be set to `svg` or `canvas`, svg is the default
- chore(elm): Optimized with elm-review
- fix: text-book switching
- improve(TTS): only if there is a comment or an audio-file, the playbutton is enabled

## [0.15.4] - 03/07/2024

- chore: npm update katex, sass, echarts, ace-builds, caniuse-lite
- fix: z-index on copy-buttons
- fix: local script loading

## [0.15.3] - 26/06/2024

- improve Editor: Codes have now a copy button...
- reduce scrollIntoView calls for better usage in embeddings
- improve Comments: a custom audio-file can be added to a comment, which will be played
  when the comment is read out loud. Loading of audio can now also be done in editor modes ...
- fix: keyed audio tags

## [0.15.1] - 14/06/2024

- hotfix: return error message correctly in worker script.

## [0.15.0] - 14/06/2024

- feat: Add voice recordings to comments

  ```markdown
      --{{1 UK English Female}}--

  ?[|>](recording.mp3)
  If a comment starts with a audio-link or ends with one, then this file will be played
  when the comment should be read out loud. This will automatically trigger a replay.
  If the course is translated with Google, then the audio will be played in if and only if
  the languages is not the main, that was translated into. Otherwise the browser-based TTS
  will be used.
  ```

- improve(Audio): Music can now be embedded with `?[alt](url)` from

  - https://www.deezer.com
  - https://open.spotify.com
  - https://soundcloud.com/discover
  - https://music.youtube.com

- improve: Add information about the where a course is stored to the index-view.
- fix: loading Translation files by using `@translation: ...` macro.
- fix: loading JavaScript from animations step, when mode switched to Textbook

## [0.14.12] - 14/05/2024

- feat(YouTube): Embedding videos for YouTube will now always embed the no-cookie version
- fix: Add elements to allow embedding the editor again within the github.dev editor

## [0.14.11] - 15/04/2024

- feat(Script): a `<script worker="true" ...` attribute can now be attached to script, which will
  execute the script in a web-worker, if the browser supports it. This way, the main-thread
  will not be blocked by the script and the user can still interact with the course.
- fix(Settings): Translations and information are now clickable again ...
- fix(Script): Not modifiable scripts are now correctly displayed without the background.
- feat: Add LiaScript-Library support, which can now be used to show courses within different websites, similar to [docsify](https://docsify.js.org).
- fix: Gap-Text can now also be created dynamically with JavaScript.

## [0.14.10] - 04/03/2024)

- Script: Submit button waits for clicks, while button starts immediately

## [0.14.8] - 29/02/2024

- hotfix: script allow for sending "LIA: stop"

## [0.14.7] - 29/02/2024

- fix: script execution live-span
- improve: lia-charts can now evaluate code
- fix(Parser): Support for multiple hidden comments in sequence

## [0.14.6] - 25/02/2024

- hotfix: ASCII art now draws again empty circles

## [0.14.5] - 23/02/2024

- improve: ASCII-art images now with better emoji support and improved coloring and rendering
- update: oEmbed endpoints
- chore: update npm packages

## [0.14.4] - 14/01/2024

- feat: add "mailto:" and "tel:" to allowed protocols, which can be used in links.
- hotfix: for testing webrtc connections
- improve: ASCII-Art now fully supports emojis ...

## [0.14.3] - 03/01/2024

- improve: Add `data-show-partial-solution` to quizzes, which only have an effect
  on compound quizzes, such as Matrix-Quizzes and Gap-Texts, to reveal (as the
  name suggests) the partial solution of the quiz.
- improve: Gap-Texts can now also be integrated into ASCII-Art by putting them into
  quotations "
- feat: The SCORM1.2 connector now can also be used in OPAL-LMS

## [0.14.2] - 24/12/2023

- add italian translation

## [0.14.1] - 21/12/2023

- chore: update caniuse, ace and y-js
- fix: add hits to ascii-art quizzes

## [0.14.0] - 19/12/2023

- feat: New pub-sub system for classroom
- fix: DOM for SVG inputs
- hotfix: P2PT for google chrome

## [0.12.12] - 22/11/2023

- fix: horizontal | parsing (also for tables)
- fix: enable backtick-escape in macro parameters
- fix: dropping last newline in macro-block parsing

## [0.12.11] - 15/11/2023

- fix: recursive macro loading with not existing one

## [0.12.10] - 15/11/2023

- fix: Multiline-macros with starting newlines work now
- upgrade: Ace, caniuse, sass, katex, workbox, yjs, ...

## [0.12.9] - 14/11/2023

- fix: string escape in JavaScript executables
- changed icons
- improved index
- fix: onload macro precedence loading
- improve: SVG images can now be directly embedded into the Markdown
- improve: SCORM integration

## [0.12.8] - 26/09/2023

- improve: Add "skip-navigation" link to tabulator order, which will only appear
  in keyboard navigation

## [0.12.7] - 22/09/2023

- feat: Add `@style` macro, which reduces the need for adding custom styles.
  This macros will be loaded faster during the initialization phase than using
  the `@link` method. In contrast to `@link` the `@style` will only be applied
  onto the local course and will not be imported into others.

## [0.12.6] - 21/09/2023

- fix: Npm build problems
- update Easy-Speech for browser-based TTS output

## [0.12.5] - 21/09/2023

- chore: Npm update
- improve: Add WebRTC-checks for classroom connections
- update: oEmbed-list
- fix: Terminal storage for code (only last line was persistently stored)
- feat: Add P2PT to classroom connections
- improve: SCORM support
- improve: Enable Keyboard Accessibility for Ace-Editor
- fix: Last slide of course will be restored on reload

## [0.12.4] - 11/07/2023

- fix: Loading external CSS on Chrome-based browsers
- improve: `icon: url` can now set per slide
- chore: Update npm packages (remove matrix-crdt)

## [0.12.3] - 22/06/2023

- improve: @author: separated by ; will use the plural (Authors) in the general information field
- improve: Navigation through slides is now also possible with a presenter
- fix: Different handling of German and Deutsch voices, introduced by responsiveVoice
- fix: Script execution in order
- feat: Support for decoding courses from data-uris and gzipped data uris too
- feat: Loading of IPFS courses, the URL will change to a proxy if the IPFS protocol is not supported by the browser

## [0.12.2] - 24/04/2023

- fix: Unicode detection in ascii-art

## [0.12.1] - 24/04/2023

- feat: Add gap text quizzes and selections to inline-elements.
  Tables, paragraph, galleries, etc. can now be turned into a quiz..

  ```markdown
                      {{English Male |>}}

  The film that I saw [[(that)|those|these|then]] night wasn’t very good.
  It was all [[about]] a man [[who]] built a
  time machine so he [[could]] travel back in time.
  It took him ages and ages [[to]] build the machine.
  ```

- fix: Preprocessing of singleton HTML-tags does not chomp content anymore
- improve: ASCII-art can now cope with complex and compound emojis.
- fix: URL parsing will stop on \"

## [0.11.1] - 10/04/2023

- multiple CSS fixes and optimizations
- improve: docs
- chat:

  - improve: shake animation and improved accessibility
  - feat: Add gunDB persistent storage
  - fix: Jitsi-backend works again
  - improve: Error messages
  - Add SCROM 1.2 export for moodle

## [0.11.0] - 29/03/2023

- **Add chat to classroom, which parses LiaScript-Code live**
- refactor: Internal classroom data-structures
- fix: multiple tiny errors in classroom Synchronization
- ShortCut: Ctrl-Enter or Command-Enter can now be used to execute code or send a chat message
- fix: Probability distribution visualization for surveys
- update localization
- improve: Menu options get closed when they loose their focus
- feat: Add macros to formulas

  Macros to formulas can no be defined globally with the formula macro

  ```markdown
  <!--
  formula: Theta   \mathrm{\zeta}(#1)
  formula: \beta   \Theta{B}
  -->
  ```

  These macros are then passed to every formula. If formulas are defined
  with `\def` or `\gdef`, etc. within a formula, then only these macros are
  used an no external ones are passed.

  Additionally, formulas from other imports are imported and used as well.
  This way it is possible to include reusable formula collections.

## [0.10.34] - 27/03/2023

- feat: Add macros to formula

  Macros to formulas can no be defined globally with the formula macro

  ```markdown
  <!--
  formula: Theta   \mathrm{\zeta}(#1)
  formula: \beta   \Theta{B}
  -->
  ```

  These macros are then passed to every formula. If formulas are defined
  with \def or \gdef, etc. within a formula, then only these macros are
  used an no external ones are passed.

  Additionally, formulas from other imports are imported and used as well.
  This way it is possible to include reusable formula collections.

- improve: Menus get closed if they or one of their children loose their focus
- fix: classroom, single user is displayed after successful creation
- fix(CSS): too small textbook widths

## [0.10.33] - 22/03/2023

- improve: Style, textbook mode is now centered and spaced optimal
- fix: Code terminal overwriting of `console.log` outputs
- fix: Classroom merging conflicts of nested maps were fixed by using key-value-stores
- fix: Multiple paints of diagrams
- fix: Quiz `max-trials` triggered to fast

## [0.10.32] - 14/03/2023

- improve: Better an fine granular handling of synchronous data structures.
- fix: Cursor jumping in collaborative edit mode
- feat: Show moving cursors and selections within the editor of foreign users in classroom mode.
- improve: Styled terminals now have a highlighted resize-handler.
- fix: Edrys can now also be used as a backend for classrooms.

## [0.10.31] - 02/03/2023

- improve(Webcomponents): Web components to not have to be wrapped into `<lia-keep>` tags to preserve their inner structure.
  The body of a Webcomponent is not parsed by the internal LiaScript parser and directly passed to the component.
- feat(Quiz): `data-hint-button` can now also be defined to show the hint button after a certain amount of wrong trials.
- improve(SCORM-Connector):

  - Works now with the [SCORM-Cloud](https://app.cloud.scorm.com) by checking the compatibility setting:

    "Wrap SCO Window with API"

  - User settings (color, font-size, etc.) are preserved within the SCORM LMS

- feat(Settings): The global `window.LIA.settings` option can now be used to interactively change the user-settings from JavaScript.

## [0.10.30] - 21/02/2023

- add more quiz options:

  - `data-max-trials`: An integer value before the quiz is automatically solved
  - `data-solution-button`: can be used with a boolean value to hide this button entirely,
    or by adding an integer value the trial-number can be defined at which this button is show.
    "0" means it is immediately visible, "1" only after the first trial
  - `data-score`: This can be used together with the scorm export, to increase or decrease the
    score of a quiz. This value takes a float value and by default it is set to "1".

## [0.10.29] - 16/02/2023

- Internationalization: added new languages (portuguese, amharic, swahili, panjabi, hindi, japanese)
- Removed Matrix classroom due to size
- chore: added additional minification step

## [0.10.28] - 14/02/2023

- refact(Sync): Add code splitting for faster loading
- chore: Npm upgrade of ace, caniuse, sass
- chore: Add bundle analyzer for inspecting code-size

## [0.10.27] - 14/02/2023

- feat: New classroom that allows synchronizing quizzes, surveys, and editable code based on Y-js
- fix: Service worker required a reload on updates, no should be fixed
- feat: Quiz with randomize option for vector and matrix quizzes applied to shuffle rows:

  ```markdown
  <!-- data-randomize -->

  - [[X]] option 1
  - [[]] option 2
  - [[]] option 3
  ```

- feat: Clickable QR-Code at the share options displays a larger image
- fix: Buggy handling of escape sequences for backticks in macros.
- chore: Npm update echarts, ace-builds, typescript.
- lang: Add french translation and friendly error message if quiz solution was not correct yet.

## [0.10.26] - 16/01/2023

- improve: The content of web-components is not parsed anymore by the LiaScript parser, which in most
  cases will not require a `<lia-keep>` to handle the body appropriately.
- fix: The default GunDB server has been updated to a working one, since some of the servers, hosted
  on heroku, do not run anymore.
- improve: oEmbed - provider list is updated and the service discovery now checks also the resource
  website for oEmbed information.
- fix: Easy-Speech now works also on KaiOS and the LiaScript interpreter will not crash anymore on
  feature-Phones, based on text-to-speech output.
- fix: Bug on Terminal resize, which required to shrink the terminal before its height could be increased.
- improve: Loading of some JSON values and all view functions are now tail-recursive.
- fix: import of relative resources now works also on GitHub.

## [0.10.25] - 05/12/2022

- improve: nested loading of macros, scripts can now load complex script-macro combinations
- improve: font loading
- fix: loading relative sources (js, css) now as blob files

## [0.10.24] - 28/11/2022

- Upgraded oEmbed endpoints
- Updated language modes for ace-editor

## [0.10.23] - 28/11/2022

- Improve (TTS):

  - Responsive-Voice is now used as a fallback, if the browser does not have TTS support,
    otherwise the browser TTS gets preferred. The user can still change the preference.

  - It is now also allowed to define only the preferred language without being explicit about the gender.
    LiaScript will select an existing voice.

    ```markdown
          --{{1 English}}--

    The first english voice will be selected for this comment.
    ```

  - Fixes: Minor fixes in TTS translations.

- Improve Tooltips: Wikipedia like link previews do now interpret also relative urls correctly.

- Improve Code-Parser: Code-blocks can now also be added via macros to projects.

- improve HTML:

  - Add styling for `kdb` keyboard tags.
  - Add simple svg-parsing
  - Add : to allowed chars for HTML-parameters, this enables RDFa annotations

- chore: Upgrade of parcel, sass, caniuse, typescript, ace-builds, echarts

- Minor improvements and refactoring ...

## [0.10.22] - 14/10/2022

- fix: browser caching for editor
- fix: quizzes, surveys, and tasks can now be listed wit \*, \-, \+
- optimizations for table/diagram encoding
- improved navigation for empty resources (can now be used in editors and web-components)

## [0.10.21] - 09/09/2022

- fix: Corrected shortcode for Swahili
- improve: Parsing of main comment is not ignored, if it does not start on the
  first line.

## [0.10.20] - 30/08/2022

- add `window.parent.liaReady` as an alternative callback to an parent frame, which
  can be used if `onload` for an `<iframe>` fails or is not triggered

## [0.10.19] - 24/08/2022

- minor fixes in the window.LIA interface
- add blob - URLS to allowed types

## [0.10.18] - 18/07/2022

- improved Sync:

  - Supported backends for syncing courses can now also be used in systems
    that do not support it by default. All sync-systems are now supported in
    all cases, it might be simply disabled ...

    To enable, you can use the macro:

    `classroom: enable`

  - Add 'literal' "room-names"

    Currently a room-name and a course-URL are used to generate a unique ID
    for a room. However, the user has now also the possibility to define a
    room-name within " or '. In this case only the room-name is used as the
    ID.

  - fix(Styling): Sync now below the quiz/survey

## [0.10.17] - 29/06/2022

- improved charts:

  - fix: failing first load of geoJson data
  - refactor: internal charting
  - feat: Add axis-limit definitions

    ```markdown
    <!-- data-xlim="0,5" data-ylim=",20.0">
    | x | y |
    |---|---|
    | 1 | 2 |
    | 3 | 4 |
    ```

## [0.10.16] - 28/06/2022

- improved surveys:

  - fixed quantitative representation for small sets
  - add tooltips to quantitative outputs
  - relaxed rules for ids ...

    ```markdown
    Would yo please rate it?

        [(5 ⭐)] ⭐ ⭐ ⭐ ⭐ ⭐
        [(4 ⭐)] ⭐ ⭐ ⭐ ⭐
        [(3 ⭐)] ⭐ ⭐ ⭐
        [(2 ⭐)] ⭐ ⭐
        [(1 ⭐)] ⭐
    ```

## [0.10.15] - 27/06/2022

- feat: Add `font` macro to import external fonts such as egyptian hieroglyphs
  or cuneiform:

  ```markdown
  <!--
  author: ...
  link:   https://fonts.googleapis.com/css2?family=Noto+Sans+Egyptian+Hieroglyphs&display=swap
  font:   Noto Sans Egyptian Hieroglyphs, ...
  -->

  # Course

  > Some hieroglyphs: **𓈖𓆓 𓊽𓉐𓉐 𓈖𓏲𓇯𓂝𓏴𓃾 𓉐𓃾𓂝𓃻𓁶𓃾 𓌓𓁶𓌓𓆓𓂝𓃾 𓌅𓂧𓌅𓀠 𓀠𓇯𓈖**
  ```

- chore: Update parcel, ace, sass, caniuse, ...

## [0.10.14] - 18/06/2022

- fix: Preprocessing parsing with > and < in title
- chore: Update parcel, ace-editor, sass, and typescript
- improve: internationalization of embedded YouTube controls
- fix: index-view on small screens once cut off the main title
- improve: Quiz, Survey, and Task defintion, which is now closer to GitHub, spaces
  are allowed but not mandatory (`- [X]` vs. `-[X]`)
- improve: add < and > to escape characters

## [0.10.12] - 02/06/2022

- fix: Bug in heatmap-representation of tables ...

## [0.10.11] - 30/05/2022

- improve: DOM - handling

  DOM can now be set to `persistent: on` within the main-header-comment. This way
  no DOM-elements of other slides will be deleted anymore, they will only set to
  `hidden`. This way other systems, that need to manipulate the DOM, can now safely
  interact with LiaScript.

  But, when dealing with a lot of iframes, movies, simulations, etc. It is still
  wise to use the `persistent: off` mode. This way, videos and sound are closed,
  when switching the slide, otherwise they will still remain active, but hidden.

  However, by default the persistency of slides is disabled, it has to be enabled
  globally, but is can also be redefined per slide:

  ```markdown
  <!--
  persistent: on
  -->

  # Title

  ...

  ## Sub-Section

  <!--
  persistent: off
  -->

  ## Sub-Section 2

  <!--
  persistent: true
  -->

  Switching on is not required, if it is globally activated.
  ```

## [0.10.10] - 24/05/2022

- fix: ASCII-Art now works with embedded LiaScript-animations
- improve: Text-to-Speech output for translations with initial delay
- fix: some simple elements will not be translated anymore by google
- fix: Ukrainian translation shortcode
- update oEmbed services
- package updates including (ace-editor, caniuse, typescript)

## [0.10.9] - 09/05/2022

- keyed tables with improved performance for sorting large datasets (larger than 1000 samples)
- fix: table icons for sorting now also visible in scripts
- feat: HTML-comments can now also be used to hide content
- updated oEmbed and improved responsiveness of external embeds and iframes
- fix: offline content loading from indexedDB

## [0.10.8] - 10/04/2022

- improve: internal Links

  - integrated URL-percent-encoding to support for example parenthesis
  - fix: target \_blank removed for internal links

## [0.10.7] - 07/04/2022

- improve: LiaScript now runs also on Feature-Phones such as Nokia with
  [KaiOS](https://www.kaiostech.com) 2.5 ... CSS has been updated, web components,
  the editor, eCharts, and classroom functionality can be used.

## [0.10.6] - 28/03/2022

- feat: **Synchronization via [Edrys](https://github.com/edrys-org/edrys)**

  If a course is loaded from within Edrys via the module:

  https://github.com/edrys-org/module-liascript

  States will be automatically synced within a room between all members.

## [0.10.5] - 23/03/2022

- Add two helpers:

  - `LIA.focusOnMain`: Prevent LiaScript from stealing the focus, when a slide
    gets loaded.
  - `LIA.scrollUpOnMain`: Prevent scrolling to top when a slide is loaded.

## [0.10.4] - 23/03/2022

- undo: Update of npm packages, which caused build problems in css

## [0.10.3] - 23/03/2022

- chore: Update npm packages
- fix: Modal images work in editor again

## [0.10.2] - 08/03/2022

- improve: Survey with automated quantity or category detection
- improve: TTS now adds lang ("en") to text output. This is especially useful
  when other services than responsiveVoice are used.
- fix: Google-translate and others use `https://` instead of `//` only.
- Add icon resources

## [0.10.1] - 25/02/2022

- Build optimizations
- improve: Security by allowing only LiaScript to access indexedDB
- feat: Add functions `LIA.gotoNext` and `LIA.gotoPrevious` for improving
  navigation with external libraries
- improve: Unordered list now match the GitHub flavoured style

## [0.10.0] - 17/02/2022

- Add Classroom functionality within the share section, currently supported are

  - [BeakerBrowser](https://beakerbrowser.com)
  - [PubNub](https://www.pubnub.com)
  - [GunDB](https://gun.eco)

  This will at the moment synchronize quizzes and survey, and provide an overview
  on the results/inputs to all connected users. All data is only stored/synchronized
  between the users not at the backend. And when a user leaves the room, her or she
  takes the data with them, which will result in an update overview.

- Complete rebuild of the internal messaging pipeline to a service architecture.
- Better API, all functionality is now accessible from within a global `window.LIA`
  object.
- A set of new macros, which can be used to disable setting components:

  - `@classroom: disable`
  - `@sharing: false`
  - `@translateWithGoogle: off`

  You can use words like `false`, `disabled`, `0`, `OFF` ... LiaScript will recognize
  them as negative. All other words like `wouldLoveToSeeThisFeature` are treated
  as positive. **But better stick with `false/true`, `on/of`, `disable/enable`**

- Improved CSS for printing. This allows to generate beautiful content of a slide,
  with preserved links, if media or iframes are added.

## [0.9.51] - 26/01/2022

- improve: Tooltip positioning

## [0.9.50] - 25/01/2022

- fix: Tooltip

  - tabbing on touch devices works by long press
  - tooltips is deactivated on small screens
  - improved performance on parsing & links are preserved and clickable too

## [0.9.49] - 24/01/2022

- feature: Add tooltips to links, which work by hovering or by putting the
  focus onto a link. This feature has to be activated within the settings,
  since it creates additional http traffic. Currently supported types of
  links:

  - Links to LiaScript courses, which have to contain the URL of the
    Markdown file
  - Links to services that support oEmbend
  - Other sites with meta information as OpenGraph, TwitterCards, otherwise
    the first image, header, and paragraphs are grabbed to create the tooltip

## [0.9.47] - 14/01/2022

- improve: Video resources via Multimedia links

  - Add support for the TU Bergakademie Freiberg video platform

    https://video.tu-freiberg.de

    Links like for YouTube can simply be copied into the URL part of a link and
    it will be automatically inserted as an responsive video:

    `!?[video](https://video.tu-freiberg.de/video/Zahlensysteme/e54f8df0ac5d94701b277f9bc63863f6)`

  - fix: Videos on subsequent sites with an equal structure have not been
    updated properly

## [0.9.46] - 09/01/2022

- improve: Repository information

  - only visible for resources from GitHub, GitLab, DropBox
  - additional `@repository: url` macro-def, which overwrites the definitions
    from above and is also visible for exports

## [0.9.45] - 06/01/2022

- improve(Links): Links to external sites do now contain a `target="_blank"` by
  default. Thus, clicks open a new tab instead of destroying the current state
  of the window.

## [0.9.44] - 06/01/2022

- fix(patches): `make all` now runs all patches including the virtual-dom patch
- improve: ResponsiveVoice information is only visible if and only if text to
  speech is activated and used
- improve: A repository link is added to the information section, which points
  to the github, gitlab, or dropbox-repository. Others are about to come...

## [0.9.43] - 14/12/2021

- improve: Reference macros can now also have an optional title field, which
  will be ignored during the injection. However, this might be useful for
  adding information about the content of the data:

  ```markdown
  @[Macro.Name](URL 'some more information')
  ```

## [0.9.42] - 12/12/2021

- fix: Indentation for bigger macro-blocks are now injected appropriately

## [0.9.41] - 07/12/2021

- use elm-optimize-level-2 for compilation
- fix: google voice translations
- update via npm
- improved icon support
- reference macro
- updated oEmbed endpoints

## [0.9.40] - 21/10/2021

- improved quiz:

  - accessibility with block-question
  - quizzes can have starting dashes
  - fixes for generic quizzes

## [0.9.39] - 04/10/2021

- improve: Attached scripts are now executed only if a change was triggered by the
  user and their default value gets loaded. The default or initial state for quizzes
  and surveys is undefined, for tasks it is defined by the initial state.
- improve: Add `send.clear` command to scripts

## [0.9.37] - 01/10/2021

- hotfix: modal script-editor now prohibits translations

## [0.9.36] - 01/10/2021

- Attached scripts can now also publish their results
- Updated korean translations
- Export to (nearly) full Json, which can be used later as the basis to translate
  documents into other formats

## [0.9.35] - 26/09/2021

- chore: Npm update
- fix: footnote

  - CSS table and background color
  - styling of multimedia in modal
  - inline footnote now with Markdown parser

## [0.9.34] - 23/09/2021

- improve: footnote styling
- inline & block-playback are now also translatable via tts

## [0.9.33] - 15/09/2021

- fix: CSS styling for Katex-formulas and displayMode
- Internal message-routing uses a fixed datatype (`Return`) for all modules

## [0.9.32] - 06/09/2021

- Improved accessibility for quizzes
- Custom styling enabled for comments
- Improved relative link handling
- Updated translations
- fix: Minor CSS bugs and relative links in `href="#..."`

## [0.9.31] - 30/08/2021

- Improved internationalization and CSS bug-fixes
- Script-tags can now also be evaluated with internal macro support
- Add share-button to main settings, which will only appear on devices which support
  `navigation.share`

## [0.9.30] - 27/08/2021

- Add korean translation `language: ko`
- Updated build to newer parcel.rc

## [0.9.29] - 24/08/2021

- fix: Terminal-output now with whitespace pre behavior

## [0.9.28] - 23/08/2021

- feat: Resizable terminal windows
- fix(CORS): Changed CORS-proxy to allorigins.win

## [0.9.27] - 17/08/2021

- Sidebar in Slide-mode can now used to navigate through all effects
- Home-view has also a settings menu and cards are now presented according to the
  common style
- Improved TTS for translations
- Minor bug-fixes

## [0.9.24] - 30/07/2021

- Add arabic translation: `language: ar`
- Improved inline parsing speed.
- Add support for sharing courses on other protocols than `http://` and
  `https://`.

  - [`hyper:// & dat://`](https://en.wikipedia.org/wiki/Dat_%28software%29)

    This allows to use the
    [Beaker](https://en.wikipedia.org/wiki/Beaker_%28eb_browser%29) browser
    for creating, sharing, and editing courses directly within the browser,
    _no further upload required!_

  - [`ipfs:// & ipns://`](https://en.wikipedia.org/wiki/InterPlanetary_File_System)

    Since the newest version of the [Brave](https://brave.com) browser also has
    support for the "InterPlanetary File-System".

    [Blog-Post](https://brave.com/brave-integrates-ipfs)

  - How is this achieved?

    Actually by applying a patch to the original elm-url module, which can be
    found here:

    https://github.com/andre-dietrich/elm-patch

- Minor fixes in pre-processing, spelling , styling, and removed
  line-highlighting for not interactive code-blocks

- Additional headers are allowed, if they are within lists or block-quotes,
  etc.:

  ```markdown
  # Outer Header

  > ## Inner Header
  >
  > which will not lead to a separate slide.
  ```

## [0.9.23] - 12/07/2021

- Updated code-snippet language support
  (see [code-list](https://github.com/LiaScript/docs/blob/master/Code.md))
- Optimized loading time with lighthouse
- fix: icons in nested lists (3rd level)
- fix: silent hidden TTS
- refactor typescript

## [0.9.21] - 22/06/2021

- optimized loading of oEmbed content, which deals with some CORS issues and adds
  thumbnails to galleries
- fix: `-- citation` in editor mode
- minor CSS optimizations

## [0.9.19] - 09/06/2021

- some optimizations with the help of elm-review
- fix: CSS width in gallery views

## [0.9.18] - 28/05/2021

- feature: audio elements are now also usable within a gallery
- improve: background color added to gallery-cards
- fix: Video now visible in modal again

## [0.9.17] - 26/05/2021

- feature: Oembed support via the extended link notation `??[alt](url "maybe title")`,
  additionally these embeds can be used in galleries as well.
- fix(ASCII-art): wrong concatenation of multi verbatim elements in single-line

## [0.9.16] - 17/05/2021

- hotfix: Google finds always ways to trick me, this time it was with
  translating of long paragraphs, which worked sometimes. Now sentences
  are presented single paragraphs, this seems to do the trick...

## [0.9.15] - 17/05/2021

- improved TTS output:

  - Google-translate can now also deal with long paragraphs.
  - better translation & delay (500ms) to support translated courses

## [0.9.14] - 08/05/2021

- adds no translation indicators to verbatim elements
- npm update

## [0.9.12] - 04/05/2021

- hotfix: add back deleted main icon

## [0.9.11] - 04/05/2021

- fix: falsy overwritten evaluation code-snippets
- style(Cite): changed default font-style to normal
- add missing icons to tables & improved parsing
- improve ASCII-Art:

  - better support of inline Code
  - enabled caseInsensitive detection of `AsCIi` or `Art`
  - additional header text can now be used to define figcaption

## [0.9.10] - 27/04/2021

- all images can now be increased and zoomed, if their actual size is less than
  their native size
- updated KaTex, echarts, workbox, typescript, ...
- improve fig-caption
- small CSS fixes with starting images in paragraphs

## [0.9.9] - 26/04/2021

- add `console.stream` to handle stream events from remote services correctly
- fix: minor CSS bugs in tables

## [0.9.8] - 23/04/2021

- user friendly error messages, with the possibility to return to the index page.
- new macro `@persistent: false`, which allows to mark a course, `true` is default
  and means it, should be stored, `false` is used to prohibit the storage within
  IndexedDB, or another connector
- minor CSS bugfixes

## [0.9.7] - 21/04/2021

- new feature, click on an image to see it as modal and scaled ...
- removes bug with parsing quotation marks
- improved modals & fixed inline script-code editing

## [0.9.6] - 20/04/2021

- adds font-spacing
- lazy loading for images, videos, and iframes
- better parsing of weird list and quotation structures
- many little bugfixes

## [0.9.5] - 13/04/2021

- revert double single quotations for titles (caused bugs)
- add error output to surveys and quizzes
- fix: **Wired constructions of nested lists and quotes generate semantically correct HTML**
- minor fixes in CSS for selection surveys and open modals stop keyboard navigation

## [0.9.4] - 12/04/2021

- audio elements `?[audio](http...mp3)` can no be part of a gallery too
- title in references now can be placed in single and double quotation marks
- adds citation which is indicated by starting a paragraph with `--`
- minor CSS fixes

## [0.9.3] - 08/04/2021

- fix: Loading older version of courses
- fix: Changed icons `+` & `-` in codes, to be equal to the LiaScript syntax
- fix: Styling for share-buttons
- fix: Intl formatting for different languages
- fix: Styling search in dark-mode
- fix: Background colors for script-tags
- improve(Code): Terminal accessibility

## [0.9.0] - 05/04/2021

- Total redesign of UI/UX
- Adds support for Tasks

  ```markdown
  - [x] some task solved
  - [ ] some task unsolved ...
  ```

- Support for galleries as collections of images and videos:

  ```markdown
  ![some image](url1) ![some image](url2)
  !?[some video](url3)
  ![some image](url4)
  !?[some video](url5)
  ```

- Images and videos are now scaled automatically to fit the best size
- Moved from JavaScript to Typescript
- Optimized internal message-handling
- Scripts can now also create Quizzes, Code, Surveys, etc.
  (scripts cannot create scripts)
- Updated debug-information
- Updated to eCharts 5
- ASCII-art blocks now have a verbatim environment, that is surrounded by either
  single or double quotation marks:

  `````markdown
  ````ascii
  +------------------------------------+
  |"$$                                "|   Single
  |"   \sum_{i=1}^\infty\frac{1}{n^2} "|   quote
  |"        =\frac{\pi^2}{6}          "|   verbatim
  |"$$                                "|   block
  +------------------------------------+
                   |
                   V
  +------------------------------------+
  |""```js                           ""|   Double quote
  |""let str = "Hello World!         ""|   verbatim block
  |""alert(str)                      ""|   -
  |""```                             ""|   can contain
  |""<script>@input</script>         ""|   single quotes
  +------------------------------------+
  ````
  `````

## [0.8.12] - 08/12/2020

- better handling of incorrect and incomplete HTML-comments
- inline code does now preserve whitespaces
- table-cells can now also be styled with a starting HTML comment

## [0.8.11] - 05/12/2020

- parsing everything can be difficult, fixed issues with + and - that resulted
  from the last list updates.
- footnotes are clickable again and with multiline support

## [0.8.10] - 04/12/2020

- fixed issues with ordered and unordered lists, as well as quotes...

## [0.8.9] - 02/12/2020

- better JavaScript & HTML & inline code parsing with string escapes
- fix: problem with HTML and JavaScript within block-effects
- removed `~~~` for now ...
- fix: parsing block-html und loading order of js

## [0.8.8] - 26/11/2020

- better script-tag parsing with comments and strings
- scripts can now also produce LiaScript content via the result string:

  ```html
  <script>
    ;`LIASCRIPT:
  $$
     \sum_{i=1}^\infty\frac{1}{n^2}
          =\frac{\pi^2}{6}
  $$
  `
  </script>

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

- code-blocks can also be marked with `~~~`
- fixes for qr-code background in dark mode and margin for figures with titles

## [0.8.7] - 21/11/2020

- new funnel diagram type for tables
- better support for line-plots and scatter-plot for categories
- new link type for qr-codes: `[qr-code](url)`
- better integration of script with further configurations
- fix in script formatting

## [0.8.6] - 18/11/2020

- updated ASCII-Art, which now now supports escaping via `"`
- updates with eslint & npm update

## [0.8.5] - 12/11/2020

- hotfix: internal macro-parameters work only form @0 ot @9

## [0.8.4] - 10/11/2020

- attached scripts can now also use inputs from detached scripts
- script inputs now react to onEnter events
- fix: naming issue in web-components
- macros can now have an infinite length of input parameters

## [0.8.3] - 04/11/20202

- script format locale default is defined by global language default
- fix: order of script execution corrected in textbook mode
- fix: caching bug in Katex formulas
- added funnel diagram to table visualization
- optimized table diagram generation
- double-click on script now uses an overlay editor

## [0.8.2] - 01/11/2020

- little bugfixes, multiple inputs for scripts and internationalization for scripts outputs...

## [0.8.1] - 27/10/2020

- Support for subHeaders via:

  ```markdown
  # subHeader

  ## sub-subHeader
  ```

## [0.8.0] - 26/10/2020

- script-tags can now be used like web-components, which may return a value:

  - with reactive programming
  - with attached input elements
  - formatting is also possible with Intl

- Terminal supports the output of HTML content via
  `console.html("<img src'= ...>")`
- Terminal output gets truncated after 200 inputs and uses Html.Keyed.node
  for faster rendering

## [0.7.12] - 07/10/2020

- removed Google-Analytics
- upgrade KaTeX to 0.12.0

## [0.7.11] - 06/10/2020

- Added a Makefile for better local development.
- Use `make all KEY="your-key"` with your key for your website from
  https://responsivevoice.com
- Use `make help` to get some help 😏

## [0.7.10] - 06/10/2020

- better internal reference handling, which works now also with unicode-symbols
- stable preprocessor, which handles single `#` more securely
- multimedia captions `![alt](url "title")`, the title element can now contain
  Markdown content, which will be displayed as a caption; it works also for
  audio and video content
- fix: floating bug with tables

## [0.7.9] - 29/09/2020

- tables do not increase the size of the frame anymore
- `[preview-lia](course-url)` depicts now a preview link for the LiaScript
  course in your course. The same can be achieved with the web component
  `<preview-lia src="course-url"></preview-lia>`

  See section [Preview](#Preview) for more information.

## [0.7.8] - 28/09/2020

- updated ascii-art generation, which now supports the usage of emojis, see the
  documentation at: https://github.com/andre-dietrich/elm-svgbob

## [0.7.7] - 25/09/2020

- added laziness to Charts, Tables, and ASCII-art in order to increase speed
- npm updates
- added russian translation

## [0.7.6] - 10/09/2020

- fix: typo in css for grey design
- npm update

## [0.7.5] - 10/07/2020

- fix: jumping on animations on mobile or if content too long ...
- update ace editor to 1.4.12
- updated elm-ui to 1.0.7
- added special classes to quizzes to enable the usage of quiz-banks

## [0.7.4] - 07/07/2020

- fix: some problems with arrow navigation, added `stopPropagationOn` for
  dealing with key-press events that should not interact with the navigation
- fix: some css for cards, such as quizzes and surveys

## [0.7.3] - 06/07/2020

- Editor settings via attributes: `data-theme`, `data-marker`, `data-`...

## [0.7.2] - 26/06/2020

- fix: HTML elements with quoted strings that contain & are now accepted

## [0.7.1] - 23/06/2020

- Added string escaping with an additional macro-notation `@'name`, which works
  also with `@'1` or `@'input` ...
- New visualization type for tables `data-type="boxplot"`
- More settings for table-diagrams, i.e. `data-title`, `data-xlabel`,
  `data-ylabel`
- fix: Macro debugging caused some errors, due to new HTML handling, this was
  fixed, but the visualization is still not as expected...

## [0.7.0] - 14/06/2020

- Tables are now smarter and can be used also in conjunction with animations
- Supported tables are now (BarChart, ScatterPlot, LineChart, HeatMap, Map,
  Sankey, Graph (directed and undirected), Parallel, Radar, and PieChart)
- Added special tags for table definitions: `data-type`, `data-src`,
  `data-transpose`, `data-show`
- JavaScript execution is now delayed until all resources are loaded
- Unified parsing of HTML attributes and comment attributes
- HTML resources are now also checked if they are relative or not
- fix: single HTML-comments can now also be detached from any Markdown body

## [0.6.2] - 19/05/2020

- Added tag `<lia-keep>`: innerHTML is parsed without checking or parsing for
  Markdown
- fix: HTML-parameters with `-` are now also allowed
- fix: better search, with titles, and search-delete button
- fix: some overflow CSS bugs for quotes and quizzes
- App starts with closed table of contents on mobile devices
- fix: navigation buttons are now all of equal size
- fix: Title tab now shows the main title of the course

## [0.6.1]

- Better error handling, faulty Markdown is now parsed until the end of a
  section
- Minor optimizations to speedup JIT compilation.

## [0.6.0]

- Started tagging with version numbers
- Added language support for Spanish `es` and Taiwanese(`tw`)/Chinese(`zh`)
- Refactored effects, which now also support `{{|>}}` or `{{|> Voice}}` for main
  manual text2speech output for blocks, as well as an inline notation
  `{|>}{_read me aloud_}` for inlining
- Effect-fragments can be combined with with spoken output `{{|> 1-3}}`
