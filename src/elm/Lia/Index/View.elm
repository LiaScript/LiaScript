module Lia.Index.View exposing
    ( bottom
    , content
    , search
    )

import Array
import Conditional.List as CList
import Conditional.String as CString
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
    [ Html.input
        [ Attr.type_ "search"
        , Attr.value model
        , Attr.class "lia-input"
        , Attr.placeholder (baseSearch lang)
        , onInput ScanIndex
        , blockKeydown (ScanIndex model)
        , Attr.id "lia-input-search"
        ]
        []
    , Html.span
        [ Attr.class "icon icon-search"
        ]
        []
    , if String.isEmpty model then
        Html.text ""

      else
        Html.button
            [ Attr.class "lia-toc__clear-index"
            , onClick <| ScanIndex ""
            ]
            [ Html.i
                [ Attr.class "icon icon-close" ]
                []
            ]
    ]


content : Lang -> Int -> (( Int, Script.Msg sub ) -> msg) -> Sections -> List (Html msg)
content lang sectionId msg =
    Array.toList
        >> List.map (item lang sectionId msg)


bottom : msg -> Html msg
bottom msg =
    Html.button
        [ onClick msg
        , Attr.title "home"
        , Attr.class "lia-btn lia-btn--transparent"
        , Attr.id "lia-btn-home"
        ]
        [ Html.i [ Attr.class "lia-btn__icon icon icon-grid" ]
            []
        , Html.span [ Attr.class "lia-btn__text" ] [ Html.text "home" ]
        ]


item : Lang -> Int -> (( Int, Script.Msg sub ) -> msg) -> Section -> Html msg
item lang sectionId msg section =
    section.title
        |> List.map (view_inf Array.empty lang)
        |> itemLink sectionId section
        |> Html.map (Tuple.pair section.id >> msg)


itemLink : Int -> Section -> List (Html msg) -> Html msg
itemLink sectionId section =
    [ section.indentation
        |> String.fromInt
        |> (++) "lia-toc__link lia-toc__link--is-lvl-"
        |> CString.attachIf (not section.visible) " hide"
        |> Attr.class
    , section.id
        + 1
        |> String.fromInt
        |> (++) "#"
        |> Attr.href
    ]
        |> CList.appendIf (sectionId == section.id) [ Attr.id "focusedToc", Attr.class "lia-active" ]
        |> Html.a
