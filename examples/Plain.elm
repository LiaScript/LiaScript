module Plain exposing (..)

import Html exposing (Html)
import Lia


main : Program Never Model Msg
main =
    Html.program
        { update = update
        , init = init
        , subscriptions = \_ -> Sub.none
        , view = view
        }



-- MODEL


type Msg
    = Child Lia.Msg


type alias Model =
    Lia.Model



-- INIT


init : ( Lia.Model, Cmd msg )
init =
    ( Lia.init_plain script, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Child liaMsg ->
            Lia.update liaMsg model



-- VIEW


view : Model -> Html Msg
view model =
    Html.map Child <| Lia.view model


script : String
script =
    """{-
Comments have to be enclosed by curly braces and can be put everywhere...
These can be used to comment single elements, lines, and multi-lines...
-}

# Main Markdown

Paragraphs are separated by newlines ...

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
