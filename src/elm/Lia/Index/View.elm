module Lia.Index.View exposing
    ( bottom
    , content
    , search
    )

import Accessibility.Key as A11y_Key
import Accessibility.Live as A11y_Live
import Accessibility.Widget as A11y_Widget
import Array exposing (Array)
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


search : Lang -> Bool -> Array { x | visible : Bool } -> Model -> List (Html Msg)
search lang active results model =
    [ Html.input
        [ Attr.type_ "search"
        , Attr.value model
        , Attr.class "lia-input"
        , Attr.placeholder (baseSearch lang)
        , onInput ScanIndex
        , blockKeydown (ScanIndex model)
        , Attr.id "lia-input-search"
        , A11y_Key.tabbable active
        , A11y_Key.onKeyDown [ A11y_Key.enter (ScanIndex "") ]
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
            , onClick DeleteSearch
            , A11y_Key.tabbable active
            , lang
                |> Translations.baseDelete
                |> Attr.title
            ]
            [ Html.i
                [ Attr.class "icon icon-close" ]
                []
            ]
    , if String.isEmpty model then
        Html.text ""

      else
        let
            counts =
                Array.foldl
                    (\s c ->
                        if s.visible then
                            c + 1

                        else
                            c
                    )
                    0
                    results
        in
        Html.span [ A11y_Live.liveAssertive, Attr.class "hidden-visually" ]
            [ Html.text <|
                case counts of
                    0 ->
                        Translations.baseNoResult lang

                    1 ->
                        Translations.baseOneResult lang

                    _ ->
                        String.fromInt counts ++ " " ++ Translations.baseResults lang
            ]
    ]


content : Lang -> Bool -> Int -> (( Int, Script.Msg sub ) -> msg) -> Sections -> List (Html msg)
content lang active sectionId msg =
    Array.toList
        >> List.map (item lang active sectionId msg)


bottom : Bool -> msg -> Html msg
bottom active msg =
    Html.button
        [ onClick msg
        , Attr.title "home"
        , Attr.class "lia-btn lia-btn--transparent"
        , Attr.id "lia-btn-home"
        , A11y_Key.tabbable active
        ]
        [ Html.i [ Attr.class "lia-btn__icon icon icon-grid" ] []
        , Html.span [ Attr.class "lia-btn__text" ] [ Html.text "home" ]
        ]


item : Lang -> Bool -> Int -> (( Int, Script.Msg sub ) -> msg) -> Section -> Html msg
item lang active sectionId msg section =
    section.title
        |> List.map (view_inf Array.empty lang)
        |> itemLink active sectionId section
        |> Html.map (Tuple.pair section.id >> msg)


itemLink : Bool -> Int -> Section -> List (Html msg) -> Html msg
itemLink active sectionId section =
    [ A11y_Key.tabbable active
    , section.indentation
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
