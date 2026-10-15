module Lia.Markdown.Task.View exposing (view)

import Accessibility.Aria as A11y_Aria
import Accessibility.Role as A11y_Role
import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)
import Lia.Markdown.Task.Types exposing (Task, Vector)
import Lia.Markdown.Task.Update exposing (Msg(..))
import Lia.Markdown.Update as Markdown


{-| Render the current Task list, based on its states with the `Vector`. The
content of every item is rendered by the caller (`Lia.Markdown.View`, which
recursively renders nested `Block` content via `viewBlocks`) and passed in as
`rendered`, one `List (Html Markdown.Msg)` per item.
-}
view : String -> Maybe String -> Vector -> Parameters -> Task body -> List (List (Html Markdown.Msg)) -> ( Maybe Int, Html Markdown.Msg )
view base labeledBy vector attr task rendered =
    case Array.get task.id vector of
        Just element ->
            ( element.scriptID
            , Html.div
                (annotation "lia-quiz lia-quiz-multiple-choice open" attr)
                [ Html.div
                    [ Attr.class "lia-quiz__answers"
                    , A11y_Role.group
                    , labeledBy
                        |> Maybe.map A11y_Aria.labelledBy
                        |> Maybe.withDefault (Attr.class "")
                    ]
                    (element.state
                        |> Array.toList
                        |> List.indexedMap Tuple.pair
                        |> List.map2 (row base task.id) rendered
                    )
                ]
            )

        Nothing ->
            ( Nothing, Html.text "" )


{-| The item body is not a `label`, since it might contain images or scripts,
which must not toggle the checkbox, it names the checkbox via `aria-labelledby`.
-}
row : String -> Int -> List (Html Markdown.Msg) -> ( Int, Bool ) -> Html Markdown.Msg
row base x body ( y, checked ) =
    let
        bodyID =
            base ++ "-item-" ++ String.fromInt y
    in
    [ Html.input
        [ Attr.type_ "checkbox"
        , Attr.checked checked
        , Attr.class "lia-checkbox"
        , A11y_Aria.labelledBy bodyID
        , Markdown.UpdateTask (Toggle x y)
            |> onClick
        ]
        []
    , Html.div [ Attr.id bodyID, Attr.style "width" "100%" ] body
    ]
        |> Html.div [ Attr.class "lia-label lia-label--top" ]
