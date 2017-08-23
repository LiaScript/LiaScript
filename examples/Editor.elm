module Editor exposing (..)

import Bound exposing (createBound)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia
import Lia.Types exposing (Mode(..))
import SplitPane exposing (Orientation(..), ViewConfig, createViewConfig, percentage, withResizeLimits, withSplitterAt)


main : Program Never Model Msg
main =
    Html.program
        { update = update
        , init = init
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Msg
    = Outer SplitPane.Msg
    | Inner SplitPane.Msg
    | Update String
    | Render Mode
    | Child Lia.Msg


type alias Model =
    { outer : SplitPane.State
    , inner : SplitPane.State
    , lia : Lia.Model
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    update (Update script)
        { outer =
            SplitPane.init Horizontal
                |> withResizeLimits (createBound (percentage 0.2) (percentage 0.8))
        , inner =
            SplitPane.init Vertical
                |> withSplitterAt (percentage 0.75)
        , lia = Lia.init_slides script
        }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update script ->
            ( { model | lia = Lia.parse <| Lia.set_script model.lia script }, Cmd.none )

        Render mode ->
            ( { model | lia = Lia.switch_mode mode model.lia }, Cmd.none )

        Child liaMsg ->
            let
                ( lia, cmd ) =
                    Lia.update liaMsg model.lia
            in
            ( { model | lia = lia }, Cmd.none )

        Outer m ->
            { model
                | outer = SplitPane.update m model.outer
            }
                ! []

        Inner m ->
            { model
                | inner = SplitPane.update m model.inner
            }
                ! []



-- VIEW


view : Model -> Html Msg
view model =
    Html.div
        [ Attr.style
            [ ( "width", "99vw" )
            , ( "height", "97vh" )
            ]
        ]
        [ SplitPane.view outerViewConfig (leftView model model.inner) (rightView model) model.outer ]


rightView : Model -> Html Msg
rightView model =
    Html.div
        [ Attr.style
            [ ( "margin", "10px" )

            --, ( "overflow-y", "auto" )
            , ( "height", "calc(100% - 24px)" )
            , ( "width", "calc(100% - 12px)" )
            ]
        ]
        [ Html.map Child <| Lia.view model.lia ]


leftView : Model -> SplitPane.State -> Html Msg
leftView model =
    SplitPane.view innerViewConfig
        (Html.div
            [ Attr.style
                [ ( "resize", "horizontal" )
                , ( "overflow", "auto" )
                , ( "width", "100%" )
                , ( "height", "100%" )
                , ( "resize", "none" )
                ]
            ]
            [ Html.div
                [ Attr.style
                    [ ( "margin", "10px" )
                    ]
                ]
                [ Html.button [] [ Html.text "Load File" ]
                , Html.fieldset
                    [ Attr.style
                        [ ( "float", "right" ) ]
                    ]
                    [ Html.input
                        [ Attr.type_ "radio"
                        , onClick (Render Slides)
                        , Attr.checked (model.lia.mode == Lia.Types.Slides)
                        ]
                        []
                    , Html.text "Slides"
                    , Html.input
                        [ Attr.type_ "radio"
                        , onClick (Render Plain)
                        , Attr.checked (model.lia.mode == Plain)
                        ]
                        []
                    , Html.text "Book"
                    ]
                ]
            , Html.textarea
                [ Attr.style
                    [ ( "height", "calc(100% - 78px)" )
                    , ( "width", "calc(100% - 24px)" )
                    , ( "margin", "10px" )
                    , ( "resize", "none" )
                    ]
                , Attr.value model.lia.script
                , onInput Update
                ]
                []
            ]
        )
        (Html.textarea
            [ Attr.style
                [ ( "height", "calc(100% - 24px)" )
                , ( "width", "calc(100% - 24px)" )
                , ( "margin", "10px" )
                , ( "resize", "none" )
                ]
            ]
            [ Html.text (model.lia.error ++ "\n" ++ toString model.lia.slides) ]
        )


outerViewConfig : ViewConfig Msg
outerViewConfig =
    createViewConfig
        { toMsg = Outer
        , customSplitter = Nothing
        }


innerViewConfig : ViewConfig Msg
innerViewConfig =
    createViewConfig
        { toMsg = Inner
        , customSplitter = Nothing
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map Outer <| SplitPane.subscriptions model.outer
        , Sub.map Inner <| SplitPane.subscriptions model.inner
        ]


script : String
script =
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
XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX
XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX

                         --{{2}}--

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
