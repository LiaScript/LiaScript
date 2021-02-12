module Lia.Index.View exposing
    ( bottom
    , content
    , search
    )

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Index.Model exposing (Model)
import Lia.Index.Update exposing (Msg(..))
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Section exposing (Section, Sections)
import Lia.Settings.Types exposing (Mode(..))
import Lia.Utils exposing (blockKeydown)
import Translations exposing (Lang, baseSearch)


search : Lang -> Model -> List (Html Msg)
search lang model =
    [ Html.span
        [ Attr.style "height" "100%"
        ]
        [ Html.input
            [ Attr.type_ "search"
            , Attr.value model
            , Attr.class "lia-input lia-left"
            , Attr.placeholder (baseSearch lang)
            , Attr.style "width" "calc(100% - 35px)"
            , onInput ScanIndex
            , blockKeydown (ScanIndex model)
            , Attr.id "lia-input-search"
            ]
            []
        ]
    , Html.span
        [ Attr.style "height" "100%"
        ]
        [ if String.isEmpty model then
            Html.span
                [ Attr.class "lia-icon lia-right"
                , Attr.style "padding" "16px 0px"
                ]
                [ Html.text "" ]

          else
            Html.span
                [ Attr.class "lia-icon lia-right"
                , onClick <| ScanIndex ""
                , Attr.style "padding" "16px 0px"
                , Attr.style "cursor" "pointer"
                , Attr.style "width" "5%"
                ]
                [ Html.text "close" ]
        ]
    ]


content : Lang -> Int -> (( Int, Script.Msg sub ) -> msg) -> Sections -> List (Html msg)
content lang active msg =
    let
        toc_ =
            toc lang active msg
    in
    Array.toList
        >> List.map toc_


bottom : msg -> Html msg
bottom msg =
    Html.div []
        [ Html.button
            [ onClick msg
            , Attr.title "home"
            , Attr.class "lia-btn lia-control lia-slide-control lia-left"
            , Attr.id "lia-btn-home"
            ]
            [ Html.text "home" ]
        ]


toc : Lang -> Int -> (( Int, Script.Msg sub ) -> msg) -> Section -> Html msg
toc lang active msg section =
    if section.visible then
        Html.map msg <|
            Html.map (Tuple.pair section.id) <|
                Html.a
                    [ Attr.class
                        ("lia-toc-l"
                            ++ String.fromInt section.indentation
                            ++ (if section.error /= Nothing then
                                    " lia-error"

                                else if active == section.id then
                                    " lia-active"

                                else
                                    " lia-visited"
                               )
                        )
                    , Attr.href ("#" ++ String.fromInt (section.id + 1))
                    , Attr.id <|
                        if active == section.id then
                            "focusedToc"

                        else
                            ""
                    ]
                    (List.map (view_inf Array.empty lang) section.title)

    else
        Html.text ""
