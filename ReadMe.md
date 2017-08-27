<!--
Comments have to be placed in Htlml comment tags and can be put everywhere...

.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789
-->


# Lia

A Markdown format for writing interactive online courses.


                                     --{{1}}--
With Lia we try to implement an extended Markdown format that should enable
everyone to create, share, adapt, translate or correct and extend online courses
without the need of beeing a web-developer.

                                     --{{2}}--
Everything that is required is simple text-editor and a web-browser. Or you
start directly to create and share your course on github.


## Basic Inlines

\*bold\* -> *bold*

\~italic\~ -> ~italic~

\^superscript\^ -> ^superscript^

\_underline\_ -> _underline_

--{{0}}--
U can use some simple kind of basic Markdown style.

{{1}}
{{

Combinations are allowed:

\~\*bold italic\*\~ -> ~*bold italic*~

\_\*bold underline\*\_ -> _*bold underline*_

\_\~italic underline\~\_ -> _~italic underline~_

\_\~\*bold italic underline\*\~\_ -> _~*bold italic underline*~_

}}

--{{1}}--
But of course also combine them freely.

## Code

Code can be either `inline` or explicit:

``` c
#include <stdio.h>

void main(int) {
    println("%d\n", 1234);
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
[[?]] Es gibt nur eine mÃ¶glichkeit
[[?]] Nummer 2 ist es
[[?]] Alles aufgebraucht

### Multiple-Choice

Zwei von Vier?

[[ ]] nein
[[X]] Ja
[[X]] auch Ja
[[ ]] auf keinen Fall
[[?]] Es gibt nur eine mÃ¶glichkeit
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

simple inline formulas $ \frac{a+b}{\sum x} * \int x $
or larger multiline formulas

$$
\frac{a+b}{\sum x}
      * \int x
$$


## Symboles

### Arrows

->, ->>, >->, <-, <-<, <<-, <->, =>, <=, <=>

-->, <--, <-->, ==>, <==, <==>

~>, <~

### Smileys

:-), ;-), :-D, :-O, :-(, :-|, :-/, :-P, :-*, :'), :'(

### Escape Chars

\*, \~, \_, \#

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
