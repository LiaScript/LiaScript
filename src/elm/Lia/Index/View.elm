module Lia.Index.View exposing (view, view_search)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Index.Model exposing (Model)
import Lia.Index.Update exposing (Msg(..))
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Section exposing (Section, Sections)
import Lia.Settings.Model exposing (Mode(..))
import Lia.Utils exposing (blockKeydown)
import Translations exposing (Lang, baseSearch)


view_search : Lang -> Model -> Html Msg
view_search lang model =
    Html.div [ Attr.class "lia-toolbar", Attr.id "lia-toolbar-index" ]
        -- [ Html.span [ Attr.class "lia-icon", Attr.style [ ( "float", "left" ), ( "font-size", "16px" ) ] ] [ Html.text "search" ]
        --, Html.span [ Attr.style [ ( "float", "right" ), ( "max-width", "100px" ), ( "position", "relative" ) ] ]
        [ Html.span [ Attr.style "width" "100%", Attr.style "height" "100%" ]
            [ Html.span
                [ Attr.style "height" "100%"
                ]
                [ Html.input
                    [ Attr.type_ "search"
                    , Attr.value model
                    , Attr.class "lia-input lia-left"
                    , Attr.placeholder (baseSearch lang)
                    , Attr.style "width" "calc(100% - 35px)"

                    --, Attr.style "height" "40%"
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

        --  ]
        ]


view : Lang -> Int -> Sections -> Html ( Int, Script.Msg sub )
view lang active sections =
    let
        toc_ =
            toc lang active
    in
    sections
        |> Array.toList
        |> List.map toc_
        |> Html.div [ Attr.class "lia-content" ]


toc : Lang -> Int -> Section -> Html ( Int, Script.Msg sub )
toc lang active section =
    if section.visible then
        Html.map (Tuple.pair section.idx) <|
            Html.a
                [ Attr.class
                    ("lia-toc-l"
                        ++ String.fromInt section.indentation
                        ++ (if section.error /= Nothing then
                                " lia-error"

                            else if active == section.idx then
                                " lia-active"

                            else if section.visited then
                                ""

                            else
                                " lia-not-visited"
                           )
                    )
                , Attr.href ("#" ++ String.fromInt (section.idx + 1))
                , Attr.id <|
                    if active == section.idx then
                        "focusedToc"

                    else
                        ""
                ]
                (List.map (view_inf Array.empty lang) section.title)

    else
        Html.text ""
