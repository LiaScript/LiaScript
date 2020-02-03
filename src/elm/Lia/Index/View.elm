module Lia.Index.View exposing (view, view_search)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onInput)
import Lia.Index.Model exposing (Model)
import Lia.Index.Update exposing (Msg(..))
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Section exposing (Section, Sections)
import Lia.Settings.Model exposing (Mode(..))
import Translations exposing (Lang, baseSearch)


view_search : Lang -> Model -> Html Msg
view_search lang model =
    Html.span [ Attr.class "lia-toolbar" ]
        -- [ Html.span [ Attr.class "lia-icon", Attr.style [ ( "float", "left" ), ( "font-size", "16px" ) ] ] [ Html.text "search" ]
        --, Html.span [ Attr.style [ ( "float", "right" ), ( "max-width", "100px" ), ( "position", "relative" ) ] ]
        [ Html.input
            [ Attr.type_ "input"
            , Attr.value model
            , Attr.class "lia-input"
            , Attr.placeholder (baseSearch lang)
            , Attr.style "max-width" "100%"
            , onInput ScanIndex
            ]
            []

        --  ]
        ]


view : Int -> Sections -> Html msg
view active sections =
    let
        toc_ =
            toc active
    in
    sections
        |> Array.toList
        |> List.map toc_
        |> Html.div [ Attr.class "lia-content" ]


toc : Int -> Section -> Html msg
toc active section =
    if section.visible then
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
            (viewer Presentation 9999 section.title)

    else
        Html.text ""
