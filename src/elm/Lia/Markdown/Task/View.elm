module Lia.Markdown.Task.View exposing (view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Task.Types exposing (Task, Vector)
import Lia.Markdown.Task.Update exposing (Msg(..))


view : Config sub -> Vector -> Parameters -> Task -> Html (Msg sub)
view config vector _ task =
    case Array.get task.id vector of
        Just states ->
            states
                |> Array.toList
                |> List.indexedMap Tuple.pair
                |> List.map2 (row config task.id task.javascript) task.task
                |> Html.table [ Attr.attribute "cellspacing" "8" ]

        Nothing ->
            Html.text ""


row : Config sub -> Int -> Maybe String -> Inlines -> ( Int, Bool ) -> Html (Msg sub)
row config id1 code inlines ( id2, checked ) =
    [ Html.td [ Attr.attribute "valign" "top", Attr.class "lia-label" ]
        [ Html.input
            [ Attr.type_ "checkbox"
            , Attr.checked checked
            , onClick (Toggle id1 id2 code)
            ]
            []
        , Html.span
            [ Attr.class "lia-check-btn" ]
            [ Html.text "check" ]
        ]
    , viewer config inlines
        |> Html.td []
        |> Html.map Script
    ]
        |> Html.tr []
