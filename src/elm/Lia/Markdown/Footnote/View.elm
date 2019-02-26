module Lia.Markdown.Footnote.View exposing (block, inline)

import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Markdown.Footnote.Model exposing (Model, empty, toList)
import Lia.Markdown.Types exposing (Markdown)


inline : String -> List (Html.Attribute msg) -> Html msg
inline key attr =
    Html.sup
        (attr
            |> (::) (Attr.style "cursor" "pointer")
            |> (::) (Attr.attribute "onclick" ("showFootnote(\"" ++ key ++ "\");"))
        )
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
                [ Attr.style "padding" "-10px"
                , Attr.style "border-top" "2px solid black"
                , Attr.style "-ms-transform" "scale(0.8, 0.8)"
                , Attr.style "-ms-transform-origin" "0 50%"
                , Attr.style "-webkit-transform" "scale(0.8, 0.8)"
                , Attr.style "-webkit-transform-origin-x" "0"
                , Attr.style "transform" "scale(0.8, 0.8)"
                , Attr.style "transform-origin" "0 50%"
                , Attr.align "left"
                ]


definition : (Markdown -> Html msg) -> ( String, List Markdown ) -> Html msg
definition fn ( key, val ) =
    Html.tr []
        [ Html.td
            [ Attr.attribute "valign" "top"
            , Attr.style "padding-right" "10px"
            ]
            [ Html.p [] [ braces key ] ]
        , Html.td
            [ Attr.attribute "valign" "top" ]
            (List.map fn val)
        ]


braces : String -> Html msg
braces key =
    Html.text ("[" ++ key ++ "]")
