module Lia.Markdown.Footnote.View exposing (block, inline)

--import Html.Events exposing (onClick)
--import Lia.Markdown.Footnote.Update exposing (Msg(..))

import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Markdown.Footnote.Model exposing (..)
import Lia.Markdown.Types exposing (Markdown)


inline : String -> Html msg
inline key =
    Html.sup
        [ Attr.attribute
            "onclick"
            ("lia.app.ports.footnote.send(\"" ++ key ++ "\");")
        , Attr.style [ ( "cursor", "pointer" ) ]
        ]
        [ braces key ]


block : (Markdown -> Html msg) -> Model -> Html msg
block fn model =
    if empty model then
        Html.text ""

    else
        let
            def =
                definition fn
        in
        model
            |> toList
            |> List.map def
            |> Html.table
                [ Attr.style
                    [ --( "width", "100%" )
                      ( "padding", "-10px" )
                    , ( "border-top", "2px solid black" )
                    , ( "-ms-transform", "scale(0.8, 0.8)" )
                    , ( "-ms-transform-origin", "0 50%" )
                    , ( "-webkit-transform", "scale(0.8, 0.8)" )
                    , ( "-webkit-transform-origin-x", "0" )
                    , ( "transform", "scale(0.8, 0.8)" )
                    , ( "transform-origin", "0 50%" )
                    ]
                , Attr.align "left"
                ]


definition : (Markdown -> Html msg) -> ( String, List Markdown ) -> Html msg
definition fn ( key, val ) =
    Html.tr []
        [ Html.td
            [ Attr.attribute "valign" "top"
            , Attr.style [ ( "padding-right", "10px" ) ]
            ]
            [ Html.p [] [ braces key ] ]
        , Html.td
            [ Attr.attribute "valign" "top" ]
            (List.map fn val)
        ]


braces : String -> Html msg
braces key =
    Html.text ("[" ++ key ++ "]")
