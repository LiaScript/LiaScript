<!--

author:   Andre Dietrich
email:    andre.dietrich@ovgu.de
version:  1.0.0
language: en
narrator: US English Female

comment:  This is a very simple comment.
          Multiline is also okay.

script:   https://cdn.jsdelivr.net/chartist.js/latest/chartist.min.js
          https://felixhao28.github.io/JSCPP/dist/JSCPP.es5.min.js

link: https://cdn.jsdelivr.net/chartist.js/latest/chartist.min.css

translation: Deutsch  translations/German.md
translation: Français translations/French.md
translation: Русский  translations/Russian.md


-->

# Lia-Script

                                    --{{0}}--
With Lia, we try to implement an extended Markdown format that should enable
everyone to create, share, adapt, translate or correct and extend online courses
without the need of being a web-developer.

See the online rendered version at: https://liascript.github.io/course/?https://raw.githubusercontent.com/liaScript/docs/master/README.md

                                    --{{0}}--
Click on the (ear) button at the navigation bar to switch between spoken and
plain text mode format. And use the arrows-buttons at the top for navigating.


*Lia-Script* <!-- class = "animated infinite bounce" style = "color: red;" onclick = "alert('It started with a click!');" -->
is an extended Markdown format for writing interactive online
courses. Imagine all schoolbooks, technical or scientific literature could
become open-source projects and more interactive ... with collaborating teachers
and students ...

* easy to share adapt and translate
* no additional software required, everything is implemented in JavaScirpt/Elm
  and runs directly within the browser (online)
* automatic conversion to epub, pdf, ...


                                     --{{1}}--
Everything that is required is simple text-editor and a web-browser. Or you
start directly to create and share your course on github. The entire parsing and
transformation of Lia-Markdown to any other format is done within the browser at
client-side.


## Tools

                                     --{{0}}--
There are currently 2 Plugins for the [Atom Editor](https://atom.io/) available,
which are intended to ease and simplify the development of online course with
LiaScript.

[liascript-preview](https://atom.io/packages/liascript-preview): Is a tiny
previewer that, if it was toggled, updates the view on your course each time you
save your document.

[liascript-snippets](https://atom.io/packages/liascript-snippets): If you start
typing "lia" in your document you switch on a fuzzy search, that contains a lot
of LiaScript help, examples, and snippets.

## *Markdown*-Syntax


                                     --{{0}}--
This section is intended to give a brief overview on the basic Markdown
formatting elements. The only difference to common Markdown at this point is,
that every course has to start with a comment, which defines authors, a language
and  a narrator voice, see https://responsivevoice.org for all supported voices.

Initial LIA-comment-tag for basic definitions:

``` XML
<!--

author:   Andre Dietrich

email:    dietrich[at]ivs.cs.uni-magdeburg.de

version:  1.0.0

language: en

narrator: US English Female

script:   javascript resourse url

script:   another javascript resourse url

link:     some css stuff
          and some more css

-->
```

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

                                    --{{0}}--
We tried to use the github flavored Markdown style for simple formatting with
some additional elements.

\*italic\* -> *italic*

\*\*bold\*\* -> **bold**

\*\*\*bold and italic \*\*\* -> ***bold and italic ***

\_also italic\_ -> _also italic_

\_\_also bold\_\_ -> __also bold__

\_\_\_also bold and italic\_\_\_ -> ___also bold and italic___

\~strike\~ -> ~strike~

                                     --{{1}}--
These exceptions are for example underline and its combination with strike
through or the application of superscript. If you, for example, superscript
superscript you can get even smaller.

                                       {{1}}
********************************************************************************

\~\~underline\~\~ -> ~~underline~~

\~\~\~strike and underline\~\~\~ -> ~~~strike and underline~~~

\^superscript\^ -> ^superscript^ ^^superscript^^ ^^^superscript^^^

********************************************************************************


#### Combinations

                                     --{{0}}--
As you can see from the examples, you can combine all elements freely.


\*\*bold \_bold italic\_\*\* -> **bold _italic_**

\*\*\~bold strike\~ \~\~bold underline\~\~\*\* -> **~bold strike~ ~~bold underline~~**

\*\~italic strike\~ \~\~italic underline\~\~\* -> *~italic strike~ ~~italic underline~~*

#### Escape Characters

\*, \~, \_, \#, \{, \}, \[, \], \|, \`, \$

                                     --{{0}}--
If you want to use multiple stars, hash-tags, or other syntax elements within
your script without applying their functionality, then you can escape them with
a starting backslash.

### Symbols

                                     --{{0}}--
One thing that we missed in standard Markdown, was an implementation for arrows.
The parenthesis shows, how arrows are defined in our Markdown implementation with
their result on the right (these symbols are generated automatically for you).

(`->`) ->, (`->>`) ->>, (`>->`) >->, (`<-`) <-, (`<-<`) <-<,
(`<<-`) <<-, (`<->`) <->, (`=>`) =>, (`<=`) <=, (`<=>`) <=>

(`-->`) -->, (`<--`) <--, (`<-->`) <-->, (`==>`) ==>, (`<==`) <==, (`<==>`) <==>

(`~>`) ~>, (`<~`) <~

                                     --{{1}}--
But you can also use some basic smileys. We will try to extend this partial
support in the future.

                                       {{1}}
`:-)` :-), `;-)` ;-), `:-D` :-D, `:-O` :-O, `:-(` :-(, `:-|` :-|,
`:-/` :-/, `:-P` :-P, `:-*` :-, `:')` :'), `:'(` :'(

### References

The next section shows how external resources can be integrated.

#### Simple Links

                                     --{{0}}--
There are two ways of adding links to a Markdown document, either by inlining
the url directly or you can name it, as shown in listing 2, by applying the
typical brackets and parenthesis notation, the optional info is put in double
quotes at the end of the url.


1. example of an url-link -> http://goo.gl/fGXNvu

   text-formatting can be applied also (`*** http://goo.gl/fGXNvu ***`) ->
   *** http://goo.gl/fGXNvu ***

2. naming the link (`[title](http://goo.gl/fGXNvu "optional info")`) -> [title](http://goo.gl/fGXNvu "click Me")

#### Images and Movies

                                    --{{0}}--
Images are marked with a starting exclamation mark before the link, audio by a
starting question mark and movies are made of images and sound, that is why you
combine both marks `!?`. Defining ressources this way shows at least the links
correctly in other Markdown parsers or on github.


**Image-notation: `![alt-text](image-url "some info")`**

- url: `![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg "a picture of a lion")`
- ![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg "a picture of a lion")
- relative path: `![image](img/lenna.jpg)`
- ![image](img/lenna.jpg "beautiful Lenna")

---

**Audio-notation: `?[alt-text](audio-url "some info")`**

- `?[a horse](https://www.w3schools.com/html/horse.mp3 "hear a horse")``
- ?[a horse](https://www.w3schools.com/html/horse.mp3 "hear a horse")

---

**Movie-notation: `!?[alt-text](movie-url)`**

- YouTube: `!?[movie](https://www.youtube.com/embed/XsNk5aOpqUc?&autoplay=1)`
- !?[movie](https://www.youtube.com/embed/XsNk5aOpqUc?&autoplay=1)
- See also http://www.google.com/support/youtube/bin/answer.py?hl=en&answer=56107
    to get an overview on how a YouTube link has to be formatted to add a starting
    and/or end point, autoplay, subtitles, and other options.
- relative path: `!?[movie](vid/math.mp4)`
- !?[movie](vid/math.mp4) <!-- width="60%" -->

### Styling

                                    --{{0}}--
Adding CSS elements or classes or any other HTML setting to an image or to any
other Markdown element is implemented via a trailing comment-tag, everything
within this comment is treated as a HTML attribute, so that it can
also be used to apply graphical filters of for positioning.


``` markdown
![image](...Creative-Tail-Animal-lion.svg)<!--
style = "width: 100px;
         border: 10px solid;
         filter: grayscale(100%);"

class = "animated infinite bounce"
-->
```


![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)<!--
style = "width: 100px;
         border: 10px solid;
         filter: grayscale(100%);"

class = "animated infinite bounce"
-->
![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)<!--
style="
  width: 120px;
  border: 10px solid;"
-->
![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)<!--
  style="width: 140px;
  border: 10px solid;"
-->
![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)<!--
  style="width: 120px;
  border: 10px solid;
  -webkit-filter: grayscale(100%); /* Safari 6.0 - 9.0 */
  filter: grayscale(100%);"
-->
![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)<!--
  style="width: 100px;
  border: 10px solid;
  -webkit-filter: blur(5px); /* Safari 6.0 - 9.0 */
  filter: blur(5px);"
-->

                                     --{{1}}--
The same technique can also be applied to style and format movies and other inline
elements, such as links, words, symbols, or code...

                                       {{1}}
********************************************************************************

!?[movie](https://www.youtube.com/embed/XsNk5aOpqUc)<!--
style = "width: 100px; height: 60px;"
-->
!?[movie](https://www.youtube.com/embed/XsNk5aOpqUc)<!--
style = "width: 120px; height: 70px;"
-->
!?[movie](https://www.youtube.com/embed/XsNk5aOpqUc)<!--
style = "width: 140px; height: 80px;"
-->
!?[movie](https://www.youtube.com/embed/XsNk5aOpqUc)<!--
style = "width: 120px;
         height: 70px;
         -webkit-filter: grayscale(100%); /* Safari 6.0 - 9.0 */
         filter: grayscale(100%);"
-->
!?[movie](https://www.youtube.com/embed/XsNk5aOpqUc)<!--
style = "width: 100px;
         height: 60px;
         -webkit-filter: blur(5px); /* Safari 6.0 - 9.0 */
         filter: blur(5px);"
-->

`:-) <!-- class = "animated infinite bounce" -->` ==> :-) <!-- class = "animated infinite bounce" -->

`[google](www.google.de) <!-- style = "color: red;" -->` ==> [google](www.google.de) <!-- style = "color: red;" -->

********************************************************************************


#### Block-Styling

                                  --{{0}}--
Settings for entire blocks can be set with a **starting** comment that includes
all required HTML-attributes and can even contain animation settings. These can
be used to highlight specific elements of your slides.


``` markdown
<!-- class = "animated rollIn" style = "animation-delay: 3s; color: purple" -->
The whole text-block should appear in purple color and with a wobbling effect.
Which is a **bad** example, please use it with causion ...
~~ ;-) ~~ <!-- class = "animated infinite bounce" style = "color: red;" -->
```

<!-- class = "animated rollIn" style = "animation-delay: 3s; color: purple" -->
The whole text-block should appear in purple color and with a wobbling effect.
Which is a **bad** example, please use it with causion ...
~~ ;-) ~~ <!-- class = "animated infinite bounce" style = "color: red;" -->

### Lists & Tables

Within the following part enumerations, itemizations and tables are presented,
actually with no difference to basic Markdown, so you can skip this section,
if you are already familiar with it.

#### Unordered Lists

                                 --{{0}}--
To define unordered list, starting stars, pluses, and minuses can be used and
mixed. If one point has more than one line, you can also use newlines, but with
spaces at the beginning. Paragraphs can be included in the same way, by using
two newlines.

Markdown-format:

``` markdown
* alpha
+ *beta*
- gamma
  and delta

  new Paragraph
```

Result:

* alpha
+ *beta*
- gamma
  and delta

  new Paragraph


#### Ordered Lists

                                 --{{0}}--
Ordered list start with a number and a dot. As you can see from the example, the
number does not count at the moment, the generated list will always count by the
order of appearance. And it is also possible to mix lists with other lists and
elements freely.

Markdown-format:

``` markdown
0. alpha
2. **beta**
1. * gamma
   * delta
   * and epsilon
3. probably zeta
```

Result:

0. alpha
2. **beta**
1. * gamma
   * delta
   * and epsilon
3. probably zeta

#### Tables

                                   --{{0}}--
Tables, we hope, are self-explanatory. The second line is used to define a table
header as well as the alignment of the column, which is indicated by the colon.
The default is left alignment.

Markdown-format:

``` markdown
| Tables            | Are           | Cool  |
| ----------------- |:-------------:| -----:|
| *** col 3 is ***  | right-aligned | $1600 |
| ** col 2 is **    | centered      |   $12 |
| * zebra stripes * | are neat      |    $1 |
```

Result:

| Tables            | Are           | Cool  |
| ----------------- |:-------------:| -----:|
| *** col 3 is ***  | right-aligned | $1600 |
| ** col 2 is **    | centered      |   $12 |
| * zebra stripes * | are neat      |    $1 |



### Blockquotes

Markdown-format:

``` markdown
<!--
style="font-size: 18px; font-style: italic; width: 500px; margin: 0.25em 0;"
-->
> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.

Quote break.

> This is a very long line that will still be quoted properly when it wraps...
```

Result:

<!--
style="font-size: 18px; font-style: italic; width: 500px; margin: 0.25em 0;"
-->
> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.

Quote break.

> This is a very long line that will still be quoted properly when it wraps. Oh boy let's keep writing to make sure this is long enough to actually wrap for everyone. Oh, you can *put* **Markdown** into a blockquote.


                                   --{{1}}--
Next to simple paragraphs also any other block element can be included ...


                                     {{1}}
********************************************************************************

``` markdown
> <!-- style="font-size: 18px; font-style: italic; width: 500px; margin: 5.25em 0;" -->
> | Tables            | Are           | Cool  |
> | ----------------- |:-------------:| -----:|
> | *** col 3 is ***  | right-aligned | $1600 |
> | ** col 2 is **    | centered      |   $12 |
> | * zebra stripes * | are neat      |    $1 |
```

Result:

> <!-- style="font-size: 18px; font-style: italic; width: 500px; margin: 5.25em 0;" -->
> | Tables            | Are           | Cool  |
> | ----------------- |:-------------:| -----:|
> | *** col 3 is ***  | right-aligned | $1600 |
> | ** col 2 is **    | centered      |   $12 |
> | * zebra stripes * | are neat      |    $1 |

********************************************************************************

### HTML

You can also use raw HTML in your Markdown, and it'll mostly work pretty well.

```HTML
Test **bold** and <b> HTML bold</b> works also inline

<dl>
  <dt style="color: red">Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt><b>Markdown in HTML</b></dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>
```

Test **bold** and <b> HTML bold</b> works also inline

<dl>
  <dt style="color: red">Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt><b>Markdown in HTML</b></dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>

#### HTML & JavaScirpt

                                 --{{0}}--
In contrast to common Markdown-Parsers it is also possible to include and
execute javascript code. If you combine it with your HTML elements, you are free
to integrate whatever you want.

``` html
<div class="ct-chart ct-golden-section" id="chart"></div>
<script>
    // Initialize a Line chart in the container with the ID chart
    new Chartist.Line('#chart', {
        labels: [1, 2, 3, 4],
        series: [[100, 120, 180, 200]]
    });
</script>
```


                                   {{0-1}}
<div class="ct-chart ct-golden-section" id="chart1"></div>
<script>
// Initialize a Line chart in the container with the ID chart1
new Chartist.Line('#chart1', {
  labels: [1, 2, 3, 4],
  series: [[100, 120, 180, 200]]
});
</script>


                                     {{1}}
<div class="ct-chart ct-golden-section" id="chart2"></div>
<script>
// Initialize a Line chart in the container with the ID chart2
new Chartist.Line('#chart2', {
  labels: [1, 2, 3, 4],
  series: [[-100, 120, 180, 20]]
});
</script>

                                --{{2}}--
Note, you have to include all required JavaScirpt-resourses in the initial
comment after the script definition. And by combining this feature with
LiaScript effects, you can build even more sophisticated courses.

## Footnotes

    --{{0}}--
There are two types of footnotes, either inline or divided ones (into two
parts). The the footnotbody is only showed in textbook mode, or if you click
on the marker.

1. Inline Footnote[^1](explanation in one line) => `[^1](explanation in one line)`
2. Divided into a marker[^2] => `[^2]`, that can appeare every where and an
   explanation at the bottom of a section.

   ```md
   [^2]: This is an explanation, than
         can consist of multiple blocks.
   ```

[^2]: This is an explanation, than
      can consist of multiple blocks.

## Math-Mode

{{0}} via KaTex http://katex.org

{{1}} Inline math-mode `$ \frac{a}{\sum{b+i}} $` -> $ \frac{a}{\sum{b+i}} $

                                        {{2}}
Multi-line math-mode can be applied by double dollars `$$ formula $$`
$$
  \frac{a}{\sum{b+i}}
$$

                                    --{{0}}--
We apply KaTeX for math-formatting, see the documentation at www.katex.org.

                                    --{{1}}--
A formula can be either inline with single dollars.

                                    --{{2}}--
Or multi-line by using the double dollar notation.

## Syntax Highlighting

The following section shows a three types of code blocks, simple inline and
block-code as well as interactive block-code, as an extension to common
Markdown.

### Inline-Code

Inline code via \` enter some code in here 1\#\#\#\$& \` -> ` enter some code in here 1###$& `

### Block-Code

                                --{{0}}--
Syntax highlighting is enabled with highlight.js. Blocks of code are either by
lines with three back-ticks \`\`\` and an identifier for the language. See a
complete list of examples and how to write language names at the
[highlight.js demo page](http://softwaremaniacs.org/media/soft/highlight/test.html).

\`\`\` `language (python, c, javascript, ...)`

code ...

\`\`\`

C example:

``` c
#include "test.h"

int main () {
    printf("this is an example\n");
    return 0;
}
```

Python example:

``` python
import math

def lia_sqrt(val):
    return math.sqrt(val) + 22
```

### Interactive Code

                                    --{{0}}--

Why should code examples not be interactive and editable, especially if it is
JavaScript or any other language that has been ported to it? Simply add the
required resources to the initial comment with keyword `script`.

1. Add resource to main-comment: `script: url.js`

2. Add a trailing script-tag to your code: `<script>@input</script>`

3. A project with multiple files can be realized with `@input(0)`, `@input(1)`, ...,`@input(n)`.


                                     --{{1}}--
And add an additional script tag to the end of your language definition with an
`@input` macro. This element is afterwards substituted with your code and
executed. We provide some basic examples within the following section.

                                    --{{2}}--
Use the `@input` macro as a parameterized function in projects. The number
defines the the file, starting from 0.



#### JavaScript
<!--
@eval
<script>@input</script>
@end
-->

                                    --{{0}}--
Click on the run-button to execute the script or double-click on the code to
edit it and to change the output ...

Double-click on the code to switch to edit mode and double-click to get out:

``` javascript
var i=0;
var j=0;
var result = 0;

for(i = 0; i<1000; i++) {
    for(j = 0; j<i; j++) {
        result += j;
    }
}
// the last statement defines the return statement
result;
```
@eval

#### Projects

                --{{0}}--
Mutliple different code snippets can be combined to form a larger project. It
requires to wo write them in a row. You can give them names, if you add a second
parameter after the highlighting definition. Add a `+` or `-` to the front of
your filename, in order to indicate, if it should be visible by default or not.

``` js     -EvalScript.js
let who = data.first_name + " " + data.last_name;

if(data.online) {
  who + " is online"; }
else {
  who + " is NOT online"; }
```
``` json    +Data.json
{
  "first_name" :  "Sammy",
  "last_name"  :  "Shark",
  "online"     :  true
}
```
<script>
  // insert the JSON dataset into the local variable data
  let data = @input(1);

  // eval the script that uses this dataset
  eval(`@input(0)`);
</script>



#### JavaScript Chartist

A drawing example, for demonstrating that any javascript library can be used,
also for drawing.

<link rel="stylesheet" href="//cdn.jsdelivr.net/chartist.js/latest/chartist.min.css">

``` javascript
// Initialize a Line chart in the container with the ID chart1
new Chartist.Line('#chart1', {
  labels: [1, 2, 3, 4],
  series: [[100, 120, 180, 200]]
});

// Initialize a Line chart in the container with the ID chart2
new Chartist.Bar('#chart2', {
  labels: [1, 2, 3, 4],
  series: [[5, 2, 8, 3]]
});
```
<script>@input</script>

<div class="ct-chart ct-golden-section" id="chart1"></div>
<div class="ct-chart ct-golden-section" id="chart2"></div>


#### Computer-Algebra
<!--
script:   https://cdn.rawgit.com/davidedc/Algebrite/master/dist/algebrite.bundle-for-browser.js
-->


An example of a Computer-Algebra-System (Algebrit), see http://algebrite.org for more examples:

``` javascript
x + x
```
<script> Algebrite.run(`@input`) </script>



```javascript
f=sin(t)^4-2*cos(t/2)^3*sin(t)

f=circexp(f)

defint(f,t,0,2*pi)
```
<script> Algebrite.run(`@input`) </script>



#### Elm

```elm
-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/user_input/buttons.html

import Html exposing (beginnerProgram, div, button, text)
import Html.Events exposing (onClick)


main =
  beginnerProgram { model = 0, view = view, update = update }


view model =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text (toString model) ]
    , button [ onClick Increment ] [ text "+" ]
    ]


type Msg = Increment | Decrement


update msg model =
  case msg of
    Increment ->
      model + 1

    Decrement ->
      model - 1
```


#### C++

Teaching other language-basics is also possible, for this example we applied [JSCPP](https://github.com/felixhao28/JSCPP)
to run simple C++ programs:

```cpp
#include <iostream>
using namespace std;

int main() {
    int a = 120;
    int rslt = 0;
    for(int i=1; i<a; ++i) {
        rslt += i;
        cout << "rslt: " << rslt << endl;
    }
    cout << "final result = " << rslt << endl;
    return 0;
}
```
<script>
  var output = "";
  JSCPP.run(`@input`, "", {stdio: {write: s => { output += s }}});
  output;
</script>

#### Prolog
<!--
script:   https://curiosity-driven.github.io/prolog-interpreter/parser.js
          https://curiosity-driven.github.io/prolog-interpreter/interpreter.js
-->


See the implementation details at: https://curiosity-driven.org/prolog-interpreter


** Load Database and Rules: **

```prolog
exists(A, list(A, _, _, _, _)).
exists(A, list(_, A, _, _, _)).
exists(A, list(_, _, A, _, _)).
exists(A, list(_, _, _, A, _)).
exists(A, list(_, _, _, _, A)).

rightOf(R, L, list(L, R, _, _, _)).
rightOf(R, L, list(_, L, R, _, _)).
rightOf(R, L, list(_, _, L, R, _)).
rightOf(R, L, list(_, _, _, L, R)).

middle(A, list(_, _, A, _, _)).

first(A, list(A, _, _, _, _)).

nextTo(A, B, list(B, A, _, _, _)).
nextTo(A, B, list(_, B, A, _, _)).
nextTo(A, B, list(_, _, B, A, _)).
nextTo(A, B, list(_, _, _, B, A)).
nextTo(A, B, list(A, B, _, _, _)).
nextTo(A, B, list(_, A, B, _, _)).
nextTo(A, B, list(_, _, A, B, _)).
nextTo(A, B, list(_, _, _, A, B)).

puzzle(Houses) :-
    exists(house(red, english, _, _, _), Houses),
    exists(house(_, spaniard, _, _, dog), Houses),
    exists(house(green, _, coffee, _, _), Houses),
    exists(house(_, ukrainian, tea, _, _), Houses),
    rightOf(house(green, _, _, _, _), house(ivory, _, _, _, _), Houses),
    exists(house(_, _, _, oldgold, snails), Houses),
    exists(house(yellow, _, _, kools, _), Houses),
    middle(house(_, _, milk, _, _), Houses),
    first(house(_, norwegian, _, _, _), Houses),
    nextTo(house(_, _, _, chesterfield, _), house(_, _, _, _, fox), Houses),
    nextTo(house(_, _, _, kools, _),house(_, _, _, _, horse), Houses),
    exists(house(_, _, orangejuice, luckystike, _), Houses),
    exists(house(_, japanese, _, parliament, _), Houses),
    nextTo(house(_, norwegian, _, _, _), house(blue, _, _, _, _), Houses),
    exists(house(_, _, water, _, _), Houses),
    exists(house(_, _, _, _, zebra), Houses).

solution(WaterDrinker, ZebraOwner) :-
    puzzle(Houses),
    exists(house(_, WaterDrinker, water, _, _), Houses),
    exists(house(_, ZebraOwner, _, _, zebra), Houses).
```
<script>
var rules = parser(lexer(`@input`)).parseRules();
window['prolog_db'] = new Database(rules);

"database loaded";
</script>

** Query: ( it may take some time ;-) ) **

```prolog
solution(WaterDrinker, ZebraOwner)
```
<script>
var rslt = "";

var goal = parser(lexer(`@input`)).parseTerm();

for (var item of window.prolog_db.query(goal)) {
    rslt += "Yes: " + item + "\n";
}

if (rslt === "") {
   'No';
} else {
   rslt;
}
</script>

### More Examples

We provide a list of templates with more examples that can be used to start developing your own courses. See:

https://liascript.github.io/course/?https://raw.githubusercontent.com/liaScript/templates/master/README.md

## Quizzes

Quizzes are an essential element of every online course for students to reflect
and test their knowledge. Lia currently supports three different types of
quizzes which can be tweaked, if required.

### Text Inputs

                                  --{{0}}--
A text input field is defined simply by a newline and two brackets around the
solution word, value or sentence. In the depicted example, the word solution is
the solution. If you enter something else, the check will fail.

Markdown-format: `[[solution]]`

Please enter the word * "solution" * into the text-field!

    [[solution]]

### Single-Choice

                                  --{{0}}--
A single choice quiz can be defined with parenthesis within brackets and an X,
which marks the only correct answer option. The additional text is Lia-Markdown
again.

Markdown-format:

``` markdown
    [( )] Wrong
    [(X)] This is the **correct** answer
    [( )] This is ~~wrong~~ too!
```

Only one element can be selected!

    [( )] Wrong
    [(X)] This is the **correct** answer
    [( )] This is ~~wrong~~ too!


### Multiple-Choice

                                  --{{0}}--
A multiple choice quiz can be defined with brackets within brackets and an X,
which are used to mark the correct answer option. In contrast to single choice
quizzes, there can be multiple selected choices or no one, which is also allowed.

``` markdown
    [[ ]] Do not touch!
    [[X]] Select this one ...
    [[X]] ... and this one too!
    [[ ]] also not correct ...
```

Multiple of them can be selected, or all, or none of them ...

    [[ ]] Do not touch!
    [[X]] Select this one ...
    [[X]] ... and this one too!
    [[ ]] also not correct ...

### Hints

                                  --{{0}}--
To any type of quiz you can add as many hints as you want, which are revealed in
order by clicking onto the question mark.

Markdown-format:

``` markdown
    [[super]]
    [[?]] another word for awesome
    [[?]] not great or mega
    [[?]] hopefully not that bad
    [[?]] there are no hints left
```

A text input with additional hints:

    [[super]]
    [[?]] another word for awesome
    [[?]] not great or mega
    [[?]] hopefully not that bad
    [[?]] there are no hints left


### Solution

                                   --{{0}}--
And finally, some quizzes might require some more explanations, if they are
solved or not. That is why, with additional three opening and three closing
brackets you mark the beginning and the end of your solution, which can contain
multiple paragraphs, formulas, program code, videos, etc as well as effects (see
therefor the next section).

Markdown-format:

``` markdown
    [[super]]
    [[?]] hint 1
    [[?]] hint 2
    ***********************************************************************

                                {{1}}
You are right, super was the correct answer again

* {2}{super} as an effect
* $\sum x + 3$
* terra

![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)

    ***********************************************************************
```

A quiz with hints and a revealed result.

    [[super]]
    [[?]] hint 1
    [[?]] hint 2
    ***********************************************************************

                                    {{1}}
You are right, super was the correct answer again

* {2}{super} as an effect
* $\sum x + 3$
* terra

![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)

    ***********************************************************************

## Effects

There are currently three types of effects, that are supported by liaScript:

1. Inline effects
2. Block effects
3. and a narrator

Every effect is defined by two braces around one or two numbers `{{1-2}}`, which
marks the order of their appearance. The second and optional number defines, at
which step the element becomes invisible again.

### Inline Effects

                                   --{{0}}--
Inline effects can be used in nearly all liaScript elements, as already
mentioned, the first number within curly braces defines the number of appearance
while the second part defines those Markdown elements that should be revealed
step wise. If you use 0, then the effect will be revealed immediately.

Use this to highlight important facts and to structure your slides (multiple
effects can be combined, due to the usage of equal numbers):

``` markdown
* no effect here
* but in this line {1}{show *** first ***}
* as well as this one {1-2}{show *** first ***}, which contains two effects
  {2}{![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)}
```

* no effect here
* but in this line {1}{show *** first ***}
* as well as this one {1-2}{show *** first ***}, which contains two effects
  {2}{![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)}


### Animations

                                   --{{0}}--
To define animations and transitions, you can use the animate.css notation,
simply place an animation definition within the comment tag after the effects,
as it is done within the examples.


See https://daneden.github.io/animate.css for more animation effects.

``` markdown
* {0}{ *bounce* } <!-- class = "animated infinite bounce" style = "animation-delay: 5s;" -->
* {1-2}{zoomIn} <!-- class = "animated zoomIn" -->
* {2-3}{zoomOut} <!-- class = "animated zoomOut" -->
* {3}{![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)} <!-- class = "animated rubberBand" -->
```

* {0}{ *bounce* } <!-- class = "animated infinite bounce" style = "animation-delay: 5s;" -->
* {1-2}{zoomIn} <!-- class = "animated zoomIn" -->
* {2-3}{zoomOut} <!-- class = "animated zoomOut" -->
* {3}{![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)} <!-- class = "animated rubberBand" -->

### Block Effects

                                   --{{0}}--
Block effects as animations are defined similarly to inline effects, just with
one additional newline after the effect definition. The following Markdown block
is then entirely associated with this effect.

                                   --{{1}}--
You can combine blocks by enclosing them into two lines of equality signs, as
you can see from the examples below, an effect can also contain further effects.


``` markdown
                               {{1-3}}
This is an example for a *single* block effect.

                               {{2-4}}
********************************************************************************

This is an example for a ... wait a second {3 rubberBand}{**multi**} ...
block effect.

* alpha
* beta
* gamma

********************************************************************************
```

                                  {{1-3}}
This is an example for a *single* block effect.

                                  {{2-4}}
********************************************************************************

This is an example for a ... wait a second {3}{**multi**} ...
block effect.

* alpha
* beta
* gamma

********************************************************************************

                                --{{4}}--
You can put spaces before the definition of a block effect, to prevent github
and others from adding the definition to a Markdown paragraph, and thus, to
render the script properly.

### Narrator
<!--
language: en_UK

narrator: UK English Male

@Tom
UK English Male
@end

@Tanja
Russian Female
@end
-->


1. we are using the text-to-speech engine of https://responsivevoice.org
2. the narrator voice must be defined within the initial comment of a script
3. use `--{{id}}--` to indicate what is spoken and when

``` markdown
                                --{{1}}--
The entire ***Markdown*** paragraph right below the effect definition in double
minus notation is sent to responsivevoice to speak the text out loud. If you
click on the ear button at the navigation panel, then this paragraph gets
rendered at the place where it is defined.

                               --{{3 Deutsch Female}}--
Markdown ist eine vereinfachte Auszeichnungssprache, die von John Gruber und
Aaron Swartz entworfen und im Dezember 2004 mit Version 1.0.1 spezifiziert ...

                               --{{4 @Tanja}}--
Первоначально создан в 2004 году Джоном Грубером (англ. John Gruber) и Аароном
Шварцем. Многие идеи языка были позаимствованы из существующих соглашений ...
```

                                --{{1}}--
The entire ***Markdown*** paragraph right below the effect definition in double
minus notation is sent to responsivevoice to speak the text out loud. If you
click on the ear button at the navigation panel, then this paragraph gets
rendered at the place where it is defined.

                                --{{2}}--
The narrator voice is defined within the initial comment, but you can reset this
for the entire section, by adding such a definition directly after the title
tag, or you can add a voice directly after the comment number to let your script
talk in different languages. Proceed and listen ;-)

                                --{{3 Deutsch Female}}--
Markdown ist eine vereinfachte Auszeichnungssprache, die von John Gruber und
Aaron Swartz entworfen und im Dezember 2004 mit Version 1.0.1 spezifiziert
wurde. Ein Ziel von Markdown ist, dass schon die Ausgangsform ohne weitere
Konvertierung leicht lesbar ist.

                               --{{4 @Tanja}}--
Первоначально создан в 2004 году Джоном Грубером (англ. John Gruber) и Аароном
Шварцем. Многие идеи языка были позаимствованы из существующих соглашений по
разметке текста в электронных письмах. Реализации языка Markdown преобразуют
текст в формате Markdown в валидный, правильно построенный XHTML и заменяют
 левые угловые скобки («<») и амперсанды («&») на соответствующие коды сущностей.


## Charts

In many cases, a diagram is only used to present some kind of signal paths,
some primitive functions, some clusters or point clouds.

You can still generate images, but why not applying some basic kind of ASCII-art
to solve the most common tasks.

### Line-Plots 1

Markdown-format:

```markdown
                                      diagram titel
    1.5 |           *
        |
      y |        *      *
      - |      *          *
      a |     *             *       *
      x |    *                 *
      i |   *
      s |  *
        | *                              *        *
      0 +------------------------------------------
         2.0              x-axis                100
```

Result:

                            diagram titel
    1.5 |           *
        |
      y |        *      *
      - |      *          *
      a |     *             *       *
      x |    *                 *
      i |   *
      s |  *
        | *                              *        *
      0 +------------------------------------------
         2.0              x-axis                100


### Line-Plots 2

                                --{{0}}--
All diagram titles, labels, limits are optional, and if you do not define
limits, then the min max values 0 and 1 are used by default.

Markdown-format:

```markdown
         1 |                   *                       *
           |               *       *               *       *
           |*             *         *             *         *
    y-axis | *           *           *           *           *
           |  *         *             *         *             *
           |   *       *               *       *               *
           |       *                       *                      *
        -1 +--------------------------------------------------------
```

         1 |                   *                       *
           |               *       *               *       *
           |*             *         *             *         *
    y-axis | *           *           *           *           *
           |  *         *             *         *             *
           |   *       *               *       *               *
           |       *                       *                      *
        -1 +--------------------------------------------------------


### Multi-Line-Plots

                             --{{0}}--
Next to stars, you can also use any kind of character to define another line,
where the character defines the color. For example an r marks the color red and
a b the color blue.

Markdown-format:

```markdown
    | r          *
    |    r
    |       r *      *
    |        * r       *
    |       *      r      *       *
    |      *            r    *
    |     *                 r
    |   *                          r
    | *                              *    r    *
    +-------------------------------------------
```

    | r          *
    |    r
    |       r *      *
    |        * r       *
    |       *      r      *       *
    |      *            r    *
    |     *                 r
    |   *                          r
    | *                              *    r    *
    +-------------------------------------------



### Dot-Plots

                                 --{{0}}--
If the there are more point with the same character for one x-value, then only
dots are plotted. And by using upper and lower case characters you can also
define the size of the dots.

Markdown-format:

```markdown
    10 |        rrrrrrrrrrrr    x
       |    rrrrrrrrrrrrrrrr
       |  rrrrrrrrrrrrrrrrr  BBBBB
       | rrrrrrrrrrrrrrrr  BBBBBBBB
       |rrrrrrrrrrrrrrr  BBBBBBBBBBB
       |rrrrrrrrrrrrr  BBBBBBBBBBBBB
       |rrrrrrrrrrr  BBBBBBBBBBBBBBB
       | rrrrrrrr  BBBBBBBBBBBBBBBB
       |  rrrrr  BBBBBBBBBBBBBBBBB
       |        BBBBBBBBBBBBBBBB
       |   x    BBBBBBBBBBBBB
       +-----------------------------
         0                           2
```


    10 |        rrrrrrrrrrrr    x
       |    rrrrrrrrrrrrrrrr
       |  rrrrrrrrrrrrrrrrr  BBBBB
       | rrrrrrrrrrrrrrrr  BBBBBBBB
       |rrrrrrrrrrrrrrr  BBBBBBBBBBB
       |rrrrrrrrrrrrr  BBBBBBBBBBBBB
       |rrrrrrrrrrr  BBBBBBBBBBBBBBB
       | rrrrrrrr  BBBBBBBBBBBBBBBB
       |  rrrrr  BBBBBBBBBBBBBBBBB
       |        BBBBBBBBBBBBBBBB
       |   x    BBBBBBBBBBBBB
       +-----------------------------
         0                           2

## Surveys

                             --{{0}}--
A script should not define a one-way road to the student! So surveys are
required.

### Text-Inputs

Similar to text-quizzes, use the following syntax to define a text-survey, where
the number of underlines defines the presented line numbers:

   `[[___ ___ ___ ___]]`

What is your opinion on ... :

    [[____ ____ ____ ____]]

### Single Choice Vector

                              --{{0}}--
And also this kind of survey is similar to a single choice quiz, but in this
case numbers within parenthesis are used to define some kind of variable
identifier. That is why they do not have to be in order.

```markdown
    [(1)] option 1
    [(2)] option 2
    [(3)] option 3
    [(0)] option 0
```

You can only select one option:

    [(1)] option 1
    [(2)] option 2
    [(3)] option 3
    [(0)] option 0


### Multi Choice Vector

                               --{{0}}--
Similar to multi-choice quizzes, you can define multi-choice survey vectors with
a number in double square brackets. But, and this is also possible for all other
kinds of surveys you can define some kind of variable name with a starting colon.

```markdown
    [[:red]]         is it red
    [[:green]]       green
    [[:blue]]        or blue
    [[:dark purple]] no one likes purple ( last chance ;-) )
```

Select some of your favored colors!

    [[:red]]         is it red
    [[:green]]       green
    [[:blue]]        or blue
    [[:dark purple]] no one likes purple ( last chance ;-) )

### Single Choice Matrix

                              --{{0}}--
For defining survey blocks you only have to a header row, whose definition is
also used by the trailing rows.

Markdown-format:

```markdown
    [(:totally)(:agree)(:unsure)(:maybe not)(:disagree)]
    [                                                  ] liaScript is great?
    [                                                  ] I would use it to make online **courses**?
    [                                                  ] I would use it for online **surveys**?
```

    [(:totally)(:agree)(:unsure)(:maybe not)(:disagree)]
    [                                                  ] liaScript is great?
    [                                                  ] I would use it to make online **courses**?
    [                                                  ] I would use it for online **surveys**?

### Multi Choice Matrix

                               --{{0}}--
I guess, multi-choice blocks are self-explanatory...

Markdown-format:

```markdown
    [[1][2][3][4][5][6][7]]
    [                     ] question 1 ?
    [                     ] question 2 ?
    [                     ] question 3 ?
```

Result:

    [[1][2][3][4][5][6][7]]
    [                     ] question 1 ?
    [                     ] question 2 ?
    [                     ] question 3 ?



## ASCII-Art #2

Well, thanks to the great project [SvgBob](https://github.com/ivanceras/svgbob)
the newest version of LiaScript also has support for some basic ASCII art
drawings (not everything is supported yet). Simply use 4 or more backtics to
enclose your artwork and draw whatever you want. And as with any other element,
you can add some styling within HTML comments at the head of this element.

The following examples are taken from the examples on the SvgBob project site.


If you want to use a drawing tool for this, visit the online editor at:

https://ivanceras.github.io/svgbob-editor/

### Graphs

<!-- style="display: block; margin-left: auto; margin-right: auto; max-width: 315px;" -->
```````````````````````````````````````````````````````````````````````
                           .--->  F
  A       B     C   D     /
  *-------*-----*---*----*----->  E
           \            ^ \
            v          /   '--->  G
             B --> C -'
```````````````````````````````````````````````````````````````````````

<!-- style="display: block; margin-left: auto; margin-right: auto; max-width: 315px;" -->
``````````````````````````````````````````````````````````````````````
  +------+   +-----+   +-----+   +-----+
  |      |   |     |   |     |   |     |
  | Foo  +-->| Bar +---+ Baz |<--+ Moo |
  |      |   |     |   |     |   |     |
  +------+   +-----+   +--+--+   +-----+
                ^         |
                |         V
  .-------------+-----------------------.
  | Hello here and there and everywhere |
  '-------------------------------------'
```````````````````````````````````````````````````````````````````````

### Diagrams


```````````````````````````````````````````````````````````````````````
  E +-------------------------*--+     E |                         o
  D |-------------------*--*--|--*     D |                   o  o  |  o
  C |-------------*--*  |  |  |  |     C |             o  o  |  |  |  |
  B |-------*--*  |  |  |  |  |  |     B |       o  o  |  |  |  |  |  |
  A +-*--*--+--+--+--+--+--+--+--+     A +-o--o--|--|--|--|--|--|--|--|
      5 10 15 20 25 30 35 40 45 50         5 10 15 20 25 30 35 40 45 50


  85.67 ┤                                       ╭╮
  78.20 ┤                                       ││                  ╭╮
  70.73 ┤                                       ││  ╭╮ ╭╮ ╭╮   ╭╮  ╭╯╰─╮
  63.27 ┤                        ╭╮         ╭─╮ ││ ╭╯╰╮│╰─╯╰╮╭╮│╰──╯   │╭
  55.80 ┤   ╭╮                 ╭╮││╭╮ ╭╮╭╮  │ ╰─╯╰─╯  ││    ││││       ╰╯
  48.33 ┤   │╰╮      ╭──╮      │││││╰╮│╰╯│  │         ╰╯    ╰╯╰╯
  40.87 ┤╭╮ │ ╰╮╭╮  ╭╯  ╰─╮╭╮╭─╯╰╯╰╯ ╰╯  ╰──╯
  33.40 ┤││ │  ╰╯╰╮╭╯     ││╰╯
  25.93 ┤││╭╯     ╰╯      ╰╯
  18.47 ┼╯││
  11.00 ┤ ╰╯
        └───────────┴───────────┴───────────┴───────────┴───────────┴────
      2011        2012        2013        2014        2015        2016
```````````````````````````````````````````````````````````````````````

### UML


``````````````````````````````
   ____[]
  | ___ |
  ||   ||  device
  ||___||  loads
  | ooo |----------------------------------------------------------.
  | ooo |    |                          |                          |
  | ooo |    |                          |                          |
  '_____'    |                          |                          |
             |                          |                          |
             v                          v                          v
   .-------------------.  .---------------------------.  .-------------------.
   | Loadable module C |  |     Loadable module A     |  | Loadable module B |
   '-------------------'  |---------------------------|  |   (instrumented)  |
             |            |         .-----.           |  '-------------------'
             '------------+-------->| A.o |           |             |
                 calls    |         '-----'           |             |
                          |    .------------------.   |             |
                          |   / A.instrumented.o /<---+-------------'
                          |  '------------------'     |    calls
                          '---------------------------'
``````````````````````````````

`````````````````````````````
                                          .--> Base::Class::Derived_A
                                         /
                                        .----> Base::Class::Derived_B
        Something -------.             /         \\
                         \\           /           \\---> Base::Class::Derived
       Something::else    \\         /             \\
            \\             \\       /               '--> Base::Class::Derived
             \\             \\     /
              \\             \\   .-----------> Base::Class::Derived_C
               \\             \\ /
                '------ Base::Class
                        /  \\ \\ \\
                       '    \\ \\ \\
                       |     \\ \\ \\
                       .      \\ \\ '--- The::Latest
                      /|       \\ \\      \\
  With::Some::fantasy  '        \\ \\      '---- The::Latest::Greatest
                      /|         \\ \\
          More::Stuff  '          \\ '- I::Am::Running::Out::Of::Ideas
                      /|           \\
          More::Stuff  '            \\
                      /              '--- Last::One
          More::Stuff
`````````````````````````````


### Chemical Structures

``````````````````````````````
   ----- O
          \
           \________
           /        \
          /        \ \
         /            \____________ N
         \            /
          \        / /
           \________/
``````````````````````````````

``````````````````````````````
       HO
        \       
         \      
          \____________
          /------------ O     
         /
   _____/        
 H2N
``````````````````````````````


### Geometrical Shapes


````````````````````````````
  +------+.      +------+       +------+       +------+      .+------+
  |`.    | `.    |\     |\      |      |      /|     /|    .' |    .'|
  |  `+--+---+   | +----+-+     +------+     +-+----+ |   +---+--+'  |
  |   |  |   |   | |    | |     |      |     | |    | |   |   |  |   |
  +---+--+.  |   +-+----+ |     +------+     | +----+-+   |  .+--+---+
   `. |    `.|    \|     \|     |      |     |/     |/    |.'    | .'
     `+------+     +------+     +------+     +------+     +------+'
````````````````````````````


``````````````
  ____  ____  ____  ____                      ______________________
 /\   \/\   \/\   \/\   \                    /\                     \
/  \___\ \___\ \___\ \___\                  /  \    _________________\
\  / __/_/   / /   / /   /                  \   \   \                /
 \/_/\   \__/\/___/\/___/                    \   \   \__________    /
   /  \___\    /  \___\                       \   \   \    /   /   /
   \  / __/_  _\  /   /                        \   \   \  /   /   /
    \/_/\   \/\ \/___/                          \   \   \/   /   /
      /  \__/  \___\                             \   \  /   /   /
      \  / _\  /   /                              \   \/   /   /
       \/_/\ \/___/                                \      /   /
         /  \___\                                   \    /   /
         \  /   /                                    \  /   /
          \/___/                                      \/___/
``````````````````


````````````````````````````
                   _______
                  / _____ \
            _____/ /     \ \_____
           / _____/  311  \_____ \
     _____/ /     \       /     \ \_____
    / _____/  221  \_____/  412  \_____ \
   / /     \       /     \       /     \ \
  / /  131  \_____/  322  \_____/  513  \ \
  \ \       /     \       /     \       / /
   \ \_____/  232  \_____/  423  \_____/ /
   / /     \       /     \       /     \ \
  / /  142  \_____/  333  \_____/  524  \ \
  \ \       /     \       /     \       / /
   \ \_____/  243  \_____/  434  \_____/ /
   / /     \       /     \       /     \ \
  / /  153  \_____/  344  \_____/  535  \ \
  \ \       /     \       /     \       / /
   \ \_____/  254  \_____/  445  \_____/ /
    \_____ \       /     \       / _____/
          \ \_____/  355  \_____/ /
           \_____ \       / _____/
                 \ \_____/ /
                  \_______/
````````````````````````````


````````````````````````````
  .----------------------------------------------------------------------.
  |_.-._.-._.-._.-._.-._.-.    _.-._.-._.-.    _.-._.-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._. .::db .-._.-._. .::db .-._.-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._ .::d88b -._.-._ .::d88b -._.-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-. .::d8888b       .::d8888b ._.-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.- .::d88!::::::::::::d888888b _.-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.- \  Y88\_________\  Y888888P _.-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-. \  Y8888P ._.-. \  Y8888P ._.-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._ /dbY88Pdb _.-._ /dbY88Pdb _.-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-. /d8P_YP Y8b .-. /d8P_YP Y8b .-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-     /d8P .-.\ Y8b   /d8P .- \ Y8b -._.-._.-._.-._.-._.|
  |_.-._.-._.-._ .::db/d8P _.-. \.::db/d8P _.-. \ Y8b ._.-._.-._.-._.-._.|
  |_.-._.-._.-. .::d88bYP ._.-. .::d88LSP ._.-._ \ Y8b    ._.-._.-._.-._.|
  |_.-._.-._.- .::d8888b       .::d8888b`b _.-._. \ Y8b:db _.-._.-._.-._.|
  |_.-._.-._. .::d88!::::::::::::d888888b`b .-._.- \ YPd88b .-._.-._.-._.|
  |_.-._.-._. \  Y88\_________\  Y888888Pd8b       .::d8888b -._.-._.-._.|
  |_.-._.-._.- \  Y8888P -._.- \  Y8888P!::::::::::::d888888b ._.-._.-._.|
  |_.-._.-._.-. \  Y88Pdb ._.-. \  Y88Pdb_________\  Y888888P ._.-._.-._.|
  |_.-._.-._.-._ \__YP Y8b _.-._ \__YP Y8b`P -._.- \  Y8888P -._.-._.-._.|
  |_.-._.-._.-._.-._. \ Y8b .-._.-. /d\ Y8b .-._.-. /dbY88P .-._.-._.-._.|
  |_.-._.-._.-._.-._.- \ Y8b -._.- /d8P\ Y8b -._.- /d8P_YP _.-._.-._.-._.|
  |_.-._.-._.-._.-._.-. \ Y8b     /d8P _\ Y8b     /d8P _.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._ \ Y8b:db/d8P ._ \ Y8b:db/d8P ._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._. \ YPd88bYP -._. \ YPd88bYP -._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._. .::d8888b       .::d8888b .-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._ .::d88!::::::::::::d888888b -._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._ \  Y88\_________\  Y888888P -._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._. \  Y8888P .-._. \  Y8888P .-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._.- \  Y88P _.-._.- \  Y88P _.-._.-._.-._.-._.-._.|
  |_.-._.-._.-._.-._.-._.-. \__YP ._.-._.-. \__YP ._.-._.-._.-._.-._.-._.|
  `----------------------------------------------------------------------'
````````````````````````````



### Fun

````````````````````````````
                      |
  ____________    __ -+-  ____________
  \_____     /   /_ \ |   \     _____/
   \_____    \____/  \____/    _____/
    \_____                    _____/
       \___________  ___________/
                 /____\

        .---.        .-----------
       /     \  __  /    ------
      / /     \(  )/    -----
     //////   ' \/ `   ---
    //// / // :    : ---
   // /   /  /`    '--
  //          //..\\
         ====UU====UU====
             '//||\\`
               ''``
          Daron Brewood
````````````````````````````

### Unicode

And of course, if your ASCII table does not give you enough pleasure, you can
also use any kind of Unicode symbol (also within the text).

````````````````````````````````
  ┌─┬┐  ╔═╦╗  ╓─╥╖  ╒═╤╕
  │ ││  ║ ║║  ║ ║║  │ ││
  ├─┼┤  ╠═╬╣  ╟─╫╢  ╞═╪╡
  └─┴┘  ╚═╩╝  ╙─╨╜  ╘═╧╛
  ┌───────────────────┐
  │  ╔═══╗ Some Text  │▒
  │  ╚═╦═╝ in the box │▒
  ╞═╤══╩══╤═══════════╡▒
  │ ├──┬──┤           │▒
  │ └──┴──┘           │▒
  └───────────────────┘▒
   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
````````````````````````````````

### Unicode Art

````````````````````````````
  4 ◇ Sep @tw1tt3rart
 ▀▄─▀▄─▀▄─▀▄─▀▄─▀▄─▀▄─▀
 ▄▀─▄▀─▄▀─▄▀─▄▀─▄▀─▄▀─▄
 ▀─▄▀─▄▀─▄▀─▄▀─▄▀─▄▀─▄▀
 ▄─▀▄─▀▄─▀▄─▀▄─▀▄─▀▄─▀▄
 ▀▄─▀▄─▀▄─▀▄─▀▄─▀▄─▀▄─▀
 ▄▀─▄▀─▄▀─▄▀─▄▀

 23 ◇ Apr @tw1tt3rart
 ║█║█║║█║█║█║║█║█║║█║█║█
 ║█║█║║█║█║█║║█║█║║█║█║█
 ║║║║║║║║║║║║║║║║║║║║║║║
 ╚╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩╩

 19 ◇ Jan @tw1tt3rart
 ─────█─▄▀█──█▀▄─█─────
 ────▐▌──────────▐▌────
 ────█▌▀▄──▄▄──▄▀▐█────
 ───▐██──▀▀──▀▀──██▌───
 ──▄████▄──▐▌──▄████▄──
 RT
 @140artist
````````````````````````````

### Unicode Converter

Image generated with:


http://www.underware.nl/fonts/zeitung_mono/features/ASCII+/#feature_info


`````````
........................................................................................................................
........................................................................................................................
........................................................................................................................
........................................................................................................................
........................................................................................................................
.........................................................=...=..........................................................
......................................................=.====.===.=.=....................................................
....................................................========.==========.................................................
...............................................===========I================.............................................
.........................................=...=========I===II=III=III=I======............................................
.........................................=.========I==III=II=III=II==I======............................................
.......................................=.=========III=IIIIII=I=IIII=I=====I=.===........................................
.....................................=..========I==IIIIIIIII=IIIIII=I=I==II======.==....................................
.....................................==========I=I=II=IIIIIIIAIIIAI=I====II========.==..................................
....................................=====I=I===I=.=III=IIIIAAIIIIAI=I==IIII============.................................
.....................................=====II==III==IIAIIIIIAII=AIAIIIIIIII===II=======..................................
...................................==.======II=III==IAIIIIIAII=AAIII=II==I===II=I=====.==.=.............................
....................................========IIIIIII=IIAIIIAAIIIAAIII==I==I==IIIII==I=======.............................
.............................=....=========IIIIIIIIIIIAIIAAAIIIIAIII=IAIII=IIIIIIII=========..==........................
.............................====.======I===IIAAAIIIIAAAIAAAAIAIAIIIIIAIIIAIIAAI======.=======.==.......................
............................===I===========IIIIAAAIIIIAAAAAAAIAIAIAI=IIIIAAIII=I=I==============........................
..............................==II=====III==IIIIIIAAI=AAIAAXAAAAIAAIIAAIAAIIIIII=I===IIII======....=....................
............................=..=IAI===IIIIIIIIIIIAAAAAIAIXIXAAXAIAXAAIIAAAIIAII=IIIIIII========.====....................
...........................====..IAII=IIIII=IIIIAIAIAAAAAXAXAAXAIAAAIAAAAIIIAIIIIIIIIII=====.=.===......................
..................=.......========IIIIIIIIIAIIIIIIIAAXAAAXAAXXXAIXAIAXIAAAIAIIA==I=II=====I=====........................
..................==......=========IIAIIIAIIIIAAAIIIAAAAAXAXXXXAAXAAAAAAAIAIIIII=III=======.=========...................
...................=I==..=====I======IIIIIAAIAIIIAAAAAXXAXXXXAXAAXAXXIAAIAIIIIIIAII==.==IIII==IIII==....................
....................=II===II===IIIIIIIAAAAIAAAAAIIIAXXXXXXXXXXXAAAAAAAXAAAAAAAAAIIIAAAAAIIIIII====......................
....................==IIIIIIIIIIIIAAAAAAXAAAAIIIAIIIAXXXMXXXMXAAXXIAXXAXAAAAIII=IIII======IIII=I=====...................
................==..====IIIAAAAIIIIAIAAAAAXAAXAIIIAAAIXAAMXMMMXXAAXXXXXXAAIIIIIAIIIIIIIIIIIIIII========.................
...............=====II===IIAAAAAIII=====IIAXXAXXAAIAAAAXIAMMMMXAAAXMMXAIIAAAI=====IAIIIIIAII========....................
...................=====IIIIIIAAAAAAAIIIIIIAAAIAAXMMXXXXXXMMMMMXXMMXAIAAAAAIII====IIAAAAIIII=======........=............
...................========IIIIIAXXAAAAIAIIIIIAAAIAXAAAXXXXMMMXXMMMAAAAAAAAAIAIIIIAAAIAIII===========.=====.............
................=======II=========IAXAAXXXXAAAAAXXAAXAAIMMMMMXXMMMAIAAAAIAAXXAAAAAAI==II=========..=======..............
..........========.======IIIIIIIIIIIAAAXXXXXXXXAAXXXMXXXAMMMMMMMXXAAAXAAAAAXAAAAAIIIIIIIIIIIIIIIIIII===.................
............===IIIAIIIIIIIIAAAAAAXXXXXXXXXXXXXAXXAXAXXMXXMMMMMMXMXXXXAAAAAAAIIAIIAAAAAAAAAAIIIIII=====..................
................======IIIIIIIIAAAAAAAAAXAXAAAAXMMMXXAAMXIAMMMMMMMXMXXXXXXXXXXXAAAIIIIIIIIIIAIAII========................
.................====II==I=IIIAIIIIAIAAXAAAAXXXXXXXMXXXMMAMMMMXIAMXAXXXXXXXXXXXAAAAAAAAAIAAIIIIII=I===..................
...............====================IIAAAAXXXXXXXAXXMMMMMXMMWWMMMXXXXXAAAAAAAAAXXXAAAAAII=================...............
....................===...======IIIAAAXXXXAAAXAXIAAIAXMMAAMWWMXAXXAXXXAXAAXXAXAXXXAIIIIIII====I==I====.=................
..................=====IIIIIIAAAAAAAAAAAI=IAIAAA=IIAXXAXMXMWMMIAAAAXXXXXAXAIAAAXAAAAAAAAIIIIII==========................
.................=====IIIIIIAAAIIIII=IIIIIIAXAAIAAAAXXXAIMMMMXIAIXAXXXAAXXXXXAIIIAAAIAAIAIIIII====II====................
.................=======III=I======IIIIIIIAXAAAAIIAAIIIAAAMMMAAAAAIIIAXXXMXXXXAIII==IIIII==IIIII========................
................=================II==IIIAAAAAAAIIAI===IIIMMMMXAIIAIIIIIAAXXXXXXXAAII==IIII========.====.................
.................=====..=============IIAAAAAIIIIIII===IIIXMMMAIIAIIAIII=IAAAAAXXAAAIAII==============...................
........................============IAAAIAAI===I======I==AMMMAIII=IAI====IIIAAAAAAAAIIIIIII===========..................
=....................=======..=====IIII===II============IIMMMIIIIIII=====I===IAAAAAAAI=I=========.......................
====================...====...==============I=============MMMI=================IIAAIIIIIIII========.....................
===========================....===========================MMMI===================IIIIII====I==.==.......................
===============================================..=========MMMI==.=....=================I===I====........................
==========================================================MMMA=============......===..===.===.==........................
==========================================================MMMA===========================..=====...===========.=........
==========================================================MMMX==========================================================
=========================================================IMMMX==========================================================
========II==IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIAAAIIAIIXMMMMAIIIIAAAIIIIIIIIIIIIIII=IIIII=IIIIIIIIIIII================
XXXXXXXXXXXXXXXXXXXXXXXXXXMXXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXXXXMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMWMMMMMMMWMWWWWMMWMMWWWWMMWWWWWWWWWWWWMWWWMMWMWWMMMMWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
`````````

## Macros

Todo, description of the currently applied macro-syntax.

## Future Work

* Better integration with github/gitlab and the versioning of courses
* Automagically analyzed surveys
* Integration of WebGl and a 3D navigation
* Better Inline function-plotter

## Contributors and Credit


{1}{<h1> André Dietrich </h1>} <!-- class = "animated fadeInUpBig" -->

--{{1}}--
Programming paradigm experimenter and creator of liaScript and SelectScript...



{2}{<h1> Sebastian Zug  </h1>} <!-- class = "animated fadeInUpBig" -->

--{{2}}--
The mind in the dark and the man behind the eLab-project ...


{3}{<h1> Karl Fessel    </h1>} <!-- class = "animated fadeInUpBig" -->

--{{3}}--
Embedded systems developer, creator or arduinoview, and Markdown evangelist ...
