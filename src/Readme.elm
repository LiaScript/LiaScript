module Readme exposing (..)


text : String
text =
    """# Lia

A Markdown format for writing interactive online courses.


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

\\*italic\\* -> *italic*

\\*\\*bold\\*\\* -> **bold**

\\*\\*\\*bold and italic \\*\\*\\* -> ***bold and italic ***

\\_also italic\\_ -> _also italic_

\\_\\_also bold\\_\\_ -> __also bold__

\\_\\_\\_also bold and italic\\_\\_\\_ -> ___also bold and italic___

\\~strike\\~ -> ~strike~

                                       {{1}}
{{

\\~\\~underline\\~\\~ -> ~~underline~~

\\~\\~\\~underline\\~\\~\\~ -> ~~~strike and underline~~~

\\^superscript\\^ -> ^superscript^ ^^superscript^^ ^^^superscript^^^

}}

                                     --{{1}}--
These exceptions are for example underline and its combination with strike
throug or the application of superscript. If you superscript superscript you
can get even smaller.

### Combinations

                                     --{{0}}--
As you can see from the examples you can combine all elements freely.


\\*\\*bold \\_bold italic\\_\\*\\* -> **bold _italic_**

\\*\\*\\~bold strike\\~ \\~\\~bold underline\\~\\~\\*\\* -> **~bold strike~ ~~bold underline~~**

\\*\\~italic strike\\~ \\~\\~italic underline\\~\\~\\* -> *~italic strike~ ~~italic underline~~*

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


## Math-Mode

sss

## Syntax Highlighting

lll

## Quizes

## Effects



"""
