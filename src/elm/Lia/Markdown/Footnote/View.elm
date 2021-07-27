module Lia.Markdown.Footnote.View exposing
    ( block
    , byKey
    , inline
    )

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Html exposing (Html)
import Html.Attributes as Attr
import Lia.Markdown.Footnote.Model exposing (Model, empty, toList)
import Lia.Markdown.Types exposing (Markdown)


inline : String -> List (Html.Attribute msg) -> Html msg
inline key attr =
    Html.sup []
        [ Html.button
            ([ Attr.style "padding" "2px"
             , Attr.class "lia-btn lia-btn--transparent text-highlight"
             , Attr.attribute "onclick" ("showFootnote(\"" ++ key ++ "\");")
             , key
                |> byKey
                |> Attr.id
             , A11y_Aria.describedBy [ by key ]
             , A11y_Key.tabbable True
             ]
                |> List.append attr
            )
            [ braces key ]
        ]


block : (Markdown -> Html msg) -> Model -> Html msg
block fn model =
    if empty model then
        Html.text ""

    else
        let
            def =
                definition fn
        in
        [ model
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
        ]
            |> Html.footer []


definition : (Markdown -> Html msg) -> ( String, List Markdown ) -> Html msg
definition fn ( key, val ) =
    Html.tr []
        [ Html.td
            [ Attr.attribute "valign" "top"
            , Attr.style "padding-right" "10px"
            ]
            [ Html.p [ Attr.id <| by key ] [ braces key ] ]
        , Html.td
            [ Attr.attribute "valign" "top" ]
            (List.map fn val)
        ]


braces : String -> Html msg
braces key =
    Html.text ("[" ++ key ++ "]")


by : String -> String
by =
    (++) "footnote-"


byKey : String -> String
byKey =
    (++) "key-" >> by
