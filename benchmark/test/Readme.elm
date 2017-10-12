module Readme exposing (text)


text : String
text =
    """<!--

author:   Andre Dietrich

email:    dietrich@ivs.cs.uni-magdeburg.de

version:  1.0.0

language: en_US

narrator: US English Female


script:   https://cdn.jsdelivr.net/chartist.js/latest/chartist.min.js

script:   https://cdn.rawgit.com/davidedc/Algebrite/master/dist/algebrite.bundle-for-browser.js

script:   https://felixhao28.github.io/JSCPP/dist/JSCPP.es5.min.js


script:   https://interactivepython.org/runestone/static/thinkcspy/_static/skulpt.min.js

script:   https://interactivepython.org/runestone/static/thinkcspy/_static/skulpt-stdlib.js

-->

# Lia-Script

See the online rendered version at: https://liascript.github.io

Lia-Script is an extended Markdown format for writing interactive online
courses. Imagine all schoolbooks, technical or scientific literature could
become open-source projects and more interactive ... with collaborating teachers
and students ...

* easy to share adapt and translate
* no additional software required, everything is implemented in JavaScirpt/Elm
  and runs directly within the browser
* automatic conversion to epub, pdf, ...


                                     --{{1}}--
With Lia, we try to implement an extended Markdown format that should enable
everyone to create, share, adapt, translate or correct and extend online courses
without the need of being a web-developer.

                                     --{{2}}--
Everything that is required is simple text-editor and a web-browser. Or you
start directly to create and share your course on github. The entire parsing and
transformation of Lia-Markdown to any other format is done within the browser at
client-side.

## Markdown-Syntax

This section is intended to give a brief overview on the basic Markdown
formatting elements. The only difference to common Markdown at this point is,
that every course has to start with a comment, which defines authors, a language
and  a narrator voice, see https://responsivevoice.org for all supported voices.


``` XML
<!--

author:   Andre Dietrich

email:    dietrich[at]ivs.cs.uni-magdeburg.de

version:  1.0.0

language: en_US

narrator: US English Female

script:   javascript resourse url

script:   another javascript resourse url

-->
```

                                    --{{0}}--
Click on the (ear) button at the navigation bar to switch between spoken and
plain text mode format. And please click on the at the top for navigating.

### Structuring

                                    --{{0}}--
A course is structured as any other Markdown document with starting hash-tags,
whereby the number of hash-tags is used to define the hierarchy.

```markdown
# Main Title

 ...

## Section Title 1

 ...

### Subsection Title

 ...
## Section Title 2
```

### Text-Formatting

asdf
"""
