module Editor exposing (..)

import Bound exposing (createBound)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia
import LiaHtml exposing (book, plain)
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
    | Child LiaHtml.Msg


type alias Model =
    { outer : SplitPane.State
    , inner : SplitPane.State
    , script : String
    , debug : String
    , error : String
    , lia : List Lia.Slide
    , slide : Int
    , mode : Mode
    }


type Mode
    = Slides
    | Book



-- INIT


init : ( Model, Cmd a )
init =
    update (Update script)
        { outer =
            SplitPane.init Horizontal
                |> withResizeLimits (createBound (percentage 0.2) (percentage 0.8))
        , inner =
            SplitPane.init Vertical
                |> withSplitterAt (percentage 0.75)
        , script = ""
        , debug = ""
        , error = ""
        , lia = []
        , slide = 0
        , mode = Slides
        }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd a )
update msg model =
    case msg of
        Update script ->
            let
                m =
                    { model | script = script, error = "" }
            in
            case Lia.parse script of
                Ok lia ->
                    ( { m | lia = lia, debug = toString lia }, Cmd.none )

                Err msg ->
                    ( { m | error = msg }, Cmd.none )

        Render mode ->
            ( { model | mode = mode }, Cmd.none )

        Child liaMsg ->
            ( { model | slide = LiaHtml.activated liaMsg }, Cmd.none )

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
            [ ( "width", "100vw" )
            , ( "height", "100vh" )
            ]
        ]
        [ SplitPane.view outerViewConfig (leftView model model.inner) (rightView model) model.outer ]


rightView : Model -> Html Msg
rightView model =
    Html.div
        [ Attr.style
            [ ( "margin", "10px" )
            , ( "overflow-y", "auto" )
            , ( "height", "calc(100% - 24px)" )
            , ( "width", "calc(100% - 24px)" )
            ]
        ]
        [ case model.mode of
            Book ->
                Html.map Child <| plain model.lia

            Slides ->
                Html.map Child <| book model.lia model.slide
        ]


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
                        , Attr.checked (model.mode == Slides)
                        ]
                        []
                    , Html.text "Slides"
                    , Html.input
                        [ Attr.type_ "radio"
                        , onClick (Render Book)
                        , Attr.checked (model.mode == Book)
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
                , Attr.value model.script
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
            [ Html.text (model.error ++ "\n" ++ model.debug) ]
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


## Tables

| h1   | h2   | h3   |
|:-----|-----:|------|
| a    |    b |  c   |
| aa   |   bb |  cc  |
| aaa  |  bbb | ccc  |
| aaaa | bbbb | cccc |



"""
