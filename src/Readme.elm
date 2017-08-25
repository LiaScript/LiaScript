module Readme exposing (..)


text : String
text =
    """<!--
Comments have to be enclosed by curly braces and can be put everywhere...
These can be used to comment single elements, lines, and multi-lines...
-->

# Main Markdown

Paragraphs are separated by newlines ...

* XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
  XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
  XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX

* XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
  XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
  XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX

* XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
  XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
  XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX

--{{1}}--
This is some kind of first explanation text ...

                         --{{2}}--

The second one comes afterwards.

XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX

XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX


## Basic Inlines

\\*bold\\* -> *bold*

\\~italic\\~ -> ~italic~

\\^superscript\\^ -> ^superscript^

\\_underline\\_ -> _underline_


Combinations are allowed:

\\~\\*bold italic\\*\\~ -> ~*bold italic*~

\\_\\*bold underline\\*\\_ -> _*bold underline*_

\\_\\~italic underline\\~\\_ -> _~italic underline~_

\\_\\~\\*bold italic underline\\*\\~\\_ -> _~*bold italic underline*~_

## Code

Code can be either `inline` or explicit:

``` c
#include <stdio.h>

void main(int) {
    println("%d\\n", 1234);
}
```

``` python
import math

def sqrt(val):
    return math.sqrt(val)
```

## Quize

### Single-Choice

Die zwei ist die einzig richtige Antwort

[( )] 1
[(X)] 2
[( )] Oder 3
[[?]] Es gibt nur eine möglichkeit
[[?]] Nummer 2 ist es
[[?]] Alles aufgebraucht

### Multiple-Choice

Zwei von Vier?

[[ ]] nein
[[X]] Ja
[[X]] auch Ja
[[ ]] auf keinen Fall
[[?]] Es gibt nur eine möglichkeit
[[?]] Nummer 2 ist es
[[?]] Alles aufgebraucht

### Texteingaben

Wie sieht Pi aus, bis auf 5 Stellen nach dem Komma?

[[3.14159]]

## effects

                                  {{1}}
AAA AAA AAA AAA {{3}}{{*test*}} AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA
AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA
AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA AAA

{{2}}
{{

![Image](http://package.elm-lang.org/assets/favicon.ico)

[[ ]] nein
[[X]] Ja
[[X]] auch Ja
[[ ]] auf keinen Fall

}}
                                  {{1}}
BBB BBB BBB BBB BBB BBB BBB {{3}}{{*test*}} {{3}}{{*test*}} BBB BBB BBB BBB BBB BBB BBB

## References

Links: [Google](http://www.google.de)

Images:

![Image](http://package.elm-lang.org/assets/favicon.ico)

Movies:

!![Movie](https://www.youtube.com/embed/EDp6UmaA9CM)

## Quotes

> This is a quote ...
>
> xxx xxx xxx xxx xxx xxx xxx xxx xxx
> xxx xxx xxx xxx xxx xxx xxx xxx xxx

## Formulas

simple inline formulas $ \\frac{a+b}{\\sum x} * \\int x $
or larger multiline formulas

$$
\\frac{a+b}{\\sum x}
      * \\int x
$$


## Symboles

### Arrows

->, ->>, >->, <-, <-<, <<-, <->, =>, <=, <=>

-->, <--, <-->, ==>, <==, <==>

~>, <~

### Smileys

:-), ;-), :-D, :-O, :-(, :-|, :-/, :-P, :-*, :'), :'(

### Escape Chars

\\*, \\~, \\_, \\#

## Tables

| h1   | h2   | h3   |
|:-----|-----:|------|
| a    |    b |  c   |
| aa   |   bb |  cc  |
| aaa  |  bbb | ccc  |
| aaaa | bbbb | cccc |

## Enumeration

* bullets
* xxx
  xxx

## Html

This is normal Markdown ...
<b id="test" style="background-color:blue;color:red">
This is a bold and colored html...
</b> that can be used inline or <br> <br> everywhere

<img src="http://package.elm-lang.org/assets/favicon.ico">

s


## Misc

horizontal line

---

xxx


"""
