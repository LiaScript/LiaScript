<!--

author:   Andre Dietrich

email:    dietrich@ivs.cs.uni-magdeburg.de

version:  1.0.0

language: en_US

narator:  US English Female

-->

# Lia

An extended Markdown format for writing interactive online courses.


                                     --{{1}}--
With Lia we try to implement an extended Markdown format that should enable
everyone to create, share, adapt, translate or correct and extend online courses
without the need of beeing a web-developer.

                                    --{{2}}--
Everything that is required is simple text-editor and a web-browser. Or you
start directly to create and share your course on github.


## Basic Text-Formating

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

                                       {{1}}
{{

\~\~underline\~\~ -> ~~underline~~

\~\~\~strike and underline\~\~\~ -> ~~~strike and underline~~~

\^superscript\^ -> ^superscript^ ^^superscript^^ ^^^superscript^^^

}}

                                     --{{1}}--
These exceptions are for example underline and its combination with strike
throug or the application of superscript. If you superscript superscript you
can get even smaller.

### Combinations

                                     --{{0}}--
As you can see from the examples you can combine all elements freely.


\*\*bold \_bold italic\_\*\* -> **bold _italic_**

\*\*\~bold strike\~ \~\~bold underline\~\~\*\* -> **~bold strike~ ~~bold underline~~**

\*\~italic strike\~ \~\~italic underline\~\~\* -> *~italic strike~ ~~italic underline~~*

### Escape Chars

\*, \~, \_, \#, \{, \}, \[, \], \|, \`, \$

                                     --{{0}}--
If you want to use multiple stars, hash-tags, or other syntax elements within
your script without applying their functionality, then you can escape them with
a starting backslash.

### Symbols

                                     --{{0}}--
If you want to, then you can use any kind of arrows, these symbols are generated
automatically for you ...

->, ->>, >->, <-, <-<, <<-, <->, =>, <=, <=>

-->, <--, <-->, ==>, <==, <==>

~>, <~

                                     --{{1}}--
But you can also use some basic smileys. We will try to extend this partial
support in the future.

                                       {{1}}
:-), ;-), :-D, :-O, :-(, :-|, :-/, :-P, :-*, :'), :'(

## References

### Simple Links

[link](www.google.de)

### Images and Movies

## Lists

### Unordered Lists

* alpha
+ *beta*
- gamma
  and delta

### Ordered Lists

0. alpha
2. **beta**
1. gamma

   *and delta*

   ** and something else **

### Mixed Lists

1. alpha
2. **beta**
   * one
   * two
   * three
3. gamma

   *and delta*

   ** and something else **



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

### Inline-Code

Inline code via \` enter some code in here 1\#\#\#\$& \` -> ` enter some code in here 1###$& `

### Block-Code


``` c
#include "test.h"

int main () {
    printf("this is an example\n");
    return 0;
}
```

``` python
import math

def lia_sqrt(val):
    return math.sqrt(val) + 22
```

``` javascript X

alert("test XXXX");
```

                                    --{{0}}--
Syntax highlighting is enabled with highlight.js.

## Quizes

### Single-Choice

Only one element can be selected!

    [( )] Wrong
    [(X)] This is the **correct** answer
    [( )] This is ~~wrong~~ too!

### Multiple-Choice

Multiple of them can be selected, or all, or none of them ...

    [[ ]] Do not touch!
    [[X]] Select this one ...
    [[X]] ... and this one too!
    [[ ]] also not correct..


### Text Inputs

Please enter the word "solution" into the text-field!

    [[solution]]

### Hints

    [[super]]
    [[?]] another word for awesome
    [[?]] not as great as mega or terra
    [[?]] hopefully not that bad
    [[?]] there are no hints left


## Effects

### Inline Effects

### Block Effects

{{1 infinite zoomIn}}
![ape](https://www.allmystery.de/static/upics/942586_handy.jpg)<!--
    position: absolute;
    left: 0%;
    top: 0%;
    margin: 100 0 0 0;
    border:
    10px solid;
    width: 98%
-->

{{2 infinite bounce}}
![ape](https://www.allmystery.de/static/upics/942586_handy.jpg)<!--
    position: absolute;
    left: 10%;
    top: 10%;
    margin: 100 0 0 0;
    border: 10px solid;
    width: 78%
-->

{{3 infinite bounce}}
![ape](https://www.allmystery.de/static/upics/942586_handy.jpg)<!--
    position: absolute;
    left: 20%;
    top: 20%;
    margin: 100 0 0 0;
    border: 10px solid;
    width: 58%
-->

{{4 infinite bounce}}
![ape](https://www.allmystery.de/static/upics/942586_handy.jpg)<!--
    position: absolute;
    left: 30%;
    top: 30%;
    margin: 100 0 0 0;
    border: 10px solid;
    width: 38%
-->

{{5 infinite bounce}}
![ape](https://www.allmystery.de/static/upics/942586_handy.jpg)<!--
    position: absolute;
    left: 40%;
    top: 40%;
    margin: 100 0 0 0;
    border: 10px solid;
    width: 18%
-->


--{{1}}--

I like to see apes doing human stuff ...

--{{2}}--

But I do not like it the oposite way.

### Comment Effects
