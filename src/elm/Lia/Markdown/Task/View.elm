module Lia.Markdown.Task.View exposing (view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Task.Types exposing (Task, Vector)
import Lia.Markdown.Task.Update exposing (Msg(..))


{-| Render the current Task list, based on its states with the `Vector`.
-}
view : Config sub -> Vector -> Parameters -> Task -> Html (Msg sub)
view config vector attr task =
    case Array.get task.id vector of
        Just states ->
            Html.div (annotation "lia-quiz lia-quiz-multiple-choice open" attr)
                [ Html.div [ Attr.class "lia-quiz__answers" ]
                    (states
                        |> Array.toList
                        |> List.indexedMap Tuple.pair
                        |> List.map2 (row config task.id task.javascript) task.task
                    )
                ]

        Nothing ->
            Html.text ""


row : Config sub -> Int -> Maybe String -> Inlines -> ( Int, Bool ) -> Html (Msg sub)
row config x code inlines ( y, checked ) =
    [ Html.input
        [ Attr.type_ "checkbox"
        , Attr.checked checked
        , Attr.class "lia-checkbox"
        , onClick (Toggle x y code)
        ]
        []
    , viewer config inlines
        |> Html.span []
        |> Html.map Script
    ]
        |> Html.label [ Attr.class "lia-label" ]
