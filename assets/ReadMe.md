<!--

author:   Andre Dietrich

email:    dietrich@ivs.cs.uni-magdeburg.de

version:  1.0.0

language: en_US

narator:  US English Female

-->

# Lia-Script

Lia-Script is an extended Markdown format for writing interactive online
courses. Imagine all schoolbooks, technical or scientifical literature could
become open-source projects and more interactive ... with colaborating teachers
and students ...

* easy to share adapt and translate
* no additional software required, everything is implemented in JavaScirpt/Elm
  and runs directly within the browser
* automatic convertion to epub, pdf, ...


                                     --{{1}}--
With Lia we try to implement an extended Markdown format that should enable
everyone to create, share, adapt, translate or correct and extend online courses
without the need of beeing a web-developer.

                                     --{{2}}--
Everything that is required is simple text-editor and a web-browser. Or you
start directly to create and share your course on github. The entire parsing and
transformation of Lia-Markdown to any other format is done within the browser at
client-side.

## Markdown-Syntax

This section is intended to give a brief overview on the basic Markdown
formating elements. The only difference to common Markdown at this point is,
that every course has to start with a comment, which defines authors, a language
and  a narrator voice, see https://responsivevoice.org for all supported voices.


``` XML
<!--

author:   Andre Dietrich

email:    dietrich[at]ivs.cs.uni-magdeburg.de

version:  1.0.0

language: en_US

narator:  US English Female

-->
```

                                    --{{0}}--
Click on the (ear) button at the navigation bar to switch between spoken and
plain text mode format. And please click on the at the top for navigating.

### Text-Formating

                                    --{{0}}--
We tried to use the github flavored Markdown style for simple formating with
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
throug or the application of superscript. If you, for example, superscript
superscript you can get even smaller.

                                       {{1}}
{{

\~\~underline\~\~ -> ~~underline~~

\~\~\~strike and underline\~\~\~ -> ~~~strike and underline~~~

\^superscript\^ -> ^superscript^ ^^superscript^^ ^^^superscript^^^

}}


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
`:-/` :-/, `:-P` :-P, `:-*` :-*, `:')` :'), `:'(` :'(

### References

The next section shows how external resources can be integrated.

#### Simple Links

                                     --{{0}}--
There are two ways of adding links to a Markdown document, either by inlining
the url directly or you can name it, as shown in listing 2, by applying the
typical brackets and parenthesis notation.

1. example of an url-link -> http://www.google.de

   textformating can be applied also (`*** http://www.google.de ***`) ->
   *** http://www.google.de ***

2. naming the link (`[title](www.google.de)`) -> [title](www.google.de)

#### Images and Movies

                                    --{{0}}--
Images are marked with a starting exclamation mark before the link, movies are
defined by two exclamation marks.

* Image-notation: `![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)`

  ![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)

* Movie-notation: `!![movie](https://www.youtube.com/embed/XsNk5aOpqUc?&autoplay=1)`

  !![movie](https://www.youtube.com/embed/XsNk5aOpqUc?&autoplay=1)

  See alse http://www.google.com/support/youtube/bin/answer.py?hl=en&answer=56107
  to get an overview on how a YouTube link has to be formated to add a starting
  and/or end point, autoplay, subtitles, and other options.

##### Styling

                                    --{{0}}--
Adding CSS elements to images is implemented via a trailing comment-tag,
everything within this comment is treated as a style attribute, so that it can
also used to apply graphical filters of for positioning.


`![image](...Creative-Tail-Animal-lion.svg)<!-- width: 100px; border: 10px solid; filter: grayscale(100%); -->`


![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)<!--
  width: 100px;
  border: 10px solid;
-->
![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)<!--
  width: 120px;
  border: 10px solid;
-->
![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)<!--
  width: 140px;
  border: 10px solid;
-->
![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)<!--
  width: 120px;
  border: 10px solid;
  -webkit-filter: grayscale(100%); /* Safari 6.0 - 9.0 */
  filter: grayscale(100%);
-->
![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)<!--
  width: 100px;
  border: 10px solid;
  -webkit-filter: blur(5px); /* Safari 6.0 - 9.0 */
  filter: blur(5px);
-->

                                     --{{1}}--
The same technique can also be applied to style and format movies...

{{1}}
{{

!![movie](https://www.youtube.com/embed/XsNk5aOpqUc)<!--
  width: 100px;
  height: 60px;
-->
!![movie](https://www.youtube.com/embed/XsNk5aOpqUc)<!--
  width: 120px;
  height: 70px;
-->
!![movie](https://www.youtube.com/embed/XsNk5aOpqUc)<!--
  width: 140px;
  height: 80px;
-->
!![movie](https://www.youtube.com/embed/XsNk5aOpqUc)<!--
  width: 120px;
  height: 70px;
  -webkit-filter: grayscale(100%); /* Safari 6.0 - 9.0 */
  filter: grayscale(100%);
-->
!![movie](https://www.youtube.com/embed/XsNk5aOpqUc)<!--
  width: 100px;
  height: 60px;
  -webkit-filter: blur(5px); /* Safari 6.0 - 9.0 */
  filter: blur(5px);
-->

}}

### Lists & Tables

Within the following part enumerations, itemizations and tables are presented,
actually with no difference to basic Markdown, so you can skip this section,
if you are already familiar with it.

#### Unordered Lists

                                 --{{1}}--
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

                                 --{{1}}--
Ordered list start with a number and a dot. As you can cee from the example, the
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
3. propably zeta
```

Result:

0. alpha
2. **beta**
1. * gamma
   * delta
   * and epsilon
3. propably zeta

#### Tables

                                   --{{0}}--
Tables, we hope, are self-explanatory. The second line is used to define a table
header as well as the alignement of the column, which is indicated by the colon.
The default is left alignement.

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
> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.

Quote break.

> This is a very long line that will still be quoted properly when it wraps...
```

Result:

> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.

Quote break.

> This is a very long line that will still be quoted properly when it wraps. Oh boy let's keep writing to make sure this is long enough to actually wrap for everyone. Oh, you can *put* **Markdown** into a blockquote.

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


## Math-Mode

{{0}}{{ via KaTex http://katex.org }}

{{1}}{{ Inline math-mode `$ \frac{a}{\sum{b+i}} $` -> $ \frac{a}{\sum{b+i}} $ }}

                                        {{2}}
Multi-line math-mode can be applied by double dollars `$$ formula $$`
$$
  \frac{a}{\sum{b+i}}
$$

                                    --{{0}}--
We apply KaTeX for math-formating, see the documentation at www.katex.org.

                                    --{{1}}--
A formula can be either inline with single dollars.

                                    --{{2}}--
Or multiline by using the double dollar notation.

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
JavaScript? A language definition with a trailing X indicates that this code can
be executed, click on the run button to execute this example.

Double-click on the code to switch to edit mode:

``` javascript X
var string = "liaScript rocks";
alert(string);

// result of this script is:
string + "!!!";
```

                                    --{{1}}--
At the moment, executing code is only possible for JavaScript, we gone extend
this in the future with backend-support for other languages. Double click on the
code to edit it and to change the output ...

## Quizes

Quizes are an essential element of every online course for students to reflect
and test their knowledge. Lia currently supports tree different types of quizes
which can be tweaked, if required.

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
quizes, their can be multiple selected choices or no one, which is also allowed.

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
To any type of quiz you can add as much hints as you want, which are revealed in
order by clicking onto the questionmark.

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
And finaly, some quizes might require some more explanations, if they are solved
or not. That is why, with additionall three oppening and three closing brackets
you mark the begining and the end of your solution, which can contain multiple
paragraphs, formulas, program code, videos, etc as well as effects (see therefor
the next section).

Markdown-format:

``` markdown
    [[super]]
    [[?]] hint 1
    [[?]] hint 2
    [[[

                                {{1}}
You are right, super was the correct answer again

* {{2}}{{super}} as an effect
* $\sum x + 3$
* terra

![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)

]]]
```

A quiz with hints and a revealed result.

    [[super]]
    [[?]] hint 1
    [[?]] hint 2
    [[[

                                    {{1}}
You are right, super was the correct answer again

* {{2}}{{super}} as an effect
* $\sum x + 3$
* terra

![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)

]]]

## Effects

There are currently three types of effects, that are supported by liaScript:

1. Inline effects
2. Block effects
3. and a narrator

Every effect is defined by two braces around a number `{{1}}`, which marks the
order of their appearance.

### Inline Effects

                                   --{{0}}--
Inline effects can be used in nearly all liaScript elements, as already
mentioned, the first number within curly braces defines the number of appearance
while the second part defines those Markdown elements that should be revealed
stepwise. If you use 0, than the effect will be revealed imediately.

Use this to highlight important facts and to structure your slides (multiple
effects can be combined, due to the usage of equal numbers):

``` markdown
* no effect here
* but in this line {{1}}{{show *** first ***}}
* as well as this one {{1}}{{show *** first ***}}, which contains two effects
  {{2}}{{![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)}}
```

* no effect here
* but in this line {{1}}{{show *** first ***}}
* as well as this one {{1}}{{show *** first ***}}, which contains two effects
  {{2}}{{![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)}}


### Animations

                                   --{{0}}--
To define animations and transitions, you can use the animate.css notation,
simply place an animation definition after the effect number, as it is done
within the examples.


See https://daneden.github.io/animate.css for more animation effects.

``` markdown
* {{0 infinite bounce}}{{ *bounce* }}
* {{1 zoomIn}}{{zoomIn}}
* {{2 zoomIn}}{{zoomOut}}
* {{3 rubberBand}}{{![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)}}
```

* {{0 infinite bounce}}{{ *bounce* }}
* {{1 zoomIn}}{{zoomIn}}
* {{2 zoomOut}}{{zoomOut}}
* {{3 rubberBand}}{{![image](https://upload.wikimedia.org/wikipedia/commons/d/d0/Creative-Tail-Animal-lion.svg)}}


### Block Effects

                                   --{{0}}--
Block effects an animations are defined similarly to inline effects, just with
one additional newline after the effect definition. The following Markdown block
is then entirely associated with this effect.

                                   --{{1}}--
You can put many blocks into double curly braces to enclose multiple Markdown
blocks and as you can see from the examples below, an effect can also contain
further effects.


``` markdown
                      {{1}}
This is an example for a *single* block effect.

                   {{2 zoomIn}}
{{

This is an example for a ... wait a second {{3 rubberBand}}{{**multi**}} ...
block effect.

* alpha
* beta
* gamma

}}
```

                                  {{1}}
This is an example for a *single* block effect.

                               {{2 zoomIn}}
{{

This is an example for a ... wait a second {{3 rubberBand}}{{**multi**}} ...
block effect.

* alpha
* beta
* gamma

}}

                                --{{4}}--
You can put spaces before the definition of a block effect, to prevent github
and others from adding the definition to a Markdown paragraph, and thus, to
render the script properly.

### Narator

1. we are using the text-to-speech engine of https://responsivevoice.org
2. the narator voice must be defined within the inital comment of a script
3. use `--{{id}}--` to indicate what is spoken and when

``` markdown
                                --{{1}}--
The entire ***Markdown*** paragraph right below the effect definition in double
minus notation is send to responsivevoice to speak the text out loud. If you
click on the ear button at the navigation panel, then this paragraph gets
rendered at the place where it is defined.
```

                                --{{1}}--
The entire ***Markdown*** paragraph right below the effect definition in double
minus notation is send to responsivevoice to speak the text out loud. If you
click on the ear button at the navigation panel, then this paragraph gets
rendered at the place where it is defined.

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

Similar to text-quizes, use the following syntax to define a text-survey, where
the number of underlines defines the presented line numbers:

   `[[___ ___ ___ ___]]`

What is your oppinion on ... :

    [[___ ___ ___ ___]]

### Single Choice Vector

                              --{{0}}--
And also this kind of survey is similar to a single choice quiz, but in this
case numbers within parentesis are used to define some kind of variable
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
Similar to multi-choice quizes, you can define multi-choice survey vectors with
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
    [(:totaly)(:agree)(:unsure)(:maybe not)(:disagree)]
    [                                                 ] liaScript is great?
    [                                                 ] I would use it to make online **courses**?
    [                                                 ] I would use it for online **surveys**?
```

    [(:totaly)(:agree)(:unsure)(:maybe not)(:disagree)]
    [                                                 ] liaScript is great?
    [                                                 ] I would use it to make online **courses**?
    [                                                 ] I would use it for online **surveys**?

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


## Future Work

* Better integration with github/gitlab and the versioning of courses
* Free Integration of JavaScript and Elm resources
* Automagically analysed surveys
* Integration of WebGl and a 3D navigation
* Inline function-plotter

## Contributors and Credit

{{1 fadeInUpBig}}{{<h1> André Dietrich  </h1>}}

--{{1}}--
Programming paradigm experimenter and creator of liaScript and SelectScript...



{{2 fadeInUpBig}}{{<h1> Sebastian Zug   </h1>}}

--{{2}}--
The mind in the dark and the man behind the eLab-project ...



{{3 fadeInUpBig}}{{<h1> Fin Christensen </h1>}}

--{{3}}--
CSS and Web development enthusiast, outstanding git user ...



{{4 fadeInUpBig}}{{<h1> Martin Koppehel </h1>}}

--{{4}}--
Hardware-architect and fully Fullstack developer ...



{{5 fadeInUpBig}}{{<h1> Leon Wehmeier   </h1>}}

--{{5}}--
Coordinator and embedded development guru ...


{{6 fadeInUpBig}}{{<h1> Karl Fessel     </h1>}}

--{{6}}--
Embedded systems developer, creator or arduinoview, and Markdown evangelist ...
