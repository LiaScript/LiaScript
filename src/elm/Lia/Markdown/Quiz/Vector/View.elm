module Lia.Markdown.Quiz.Vector.View exposing (view)

import Accessibility.Aria as A11y_Aria
import Accessibility.Role as A11y_Role
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Quiz.Update as QuizUpdate
import Lia.Markdown.Quiz.Vector.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Vector.Update as VectorUpdate
import Lia.Markdown.Update as Main


{-| Render the current Vector-Quiz options, based on its state. The content of
every option is rendered by the caller (`Lia.Markdown.View`, which recursively
renders nested `Block` content via `viewBlocks`) and passed in as `rendered`,
one `List (Html Main.Msg)` per option - exactly as with Task-list items.

Returns the attributes for the surrounding container (its role) and the
options.

-}
view : String -> Bool -> String -> Int -> Quiz body -> State -> List (List (Html Main.Msg)) -> ( List (Attribute Main.Msg), List (Html Main.Msg) )
view base open class quizId quiz state rendered =
    case ( quiz.solution, state ) of
        ( SingleChoice _, SingleChoice list ) ->
            ( [ A11y_Role.radioGroup ]
            , List.map2 (option base "lia-radio" "radio" open class quizId) list (List.indexedMap Tuple.pair rendered)
            )

        ( MultipleChoice _, MultipleChoice list ) ->
            ( [ A11y_Role.group ]
            , List.map2 (option base "lia-checkbox" "checkbox" open class quizId) list (List.indexedMap Tuple.pair rendered)
            )

        _ ->
            ( [], [] )


{-| **private:** A radio button or check box with its content `body`, only
clickable if the quiz is `open`. The body is not a `label`, since it might
contain images or scripts, which must not toggle the input, it names the input
via `aria-labelledby` instead. All inputs of a quiz share the name `base`,
thus radio buttons form a group, which can be navigated with arrow keys.
-}
option : String -> String -> String -> Bool -> String -> Int -> Bool -> ( Int, List (Html Main.Msg) ) -> Html Main.Msg
option base inputClass inputType open colorClass quizId checked ( id, body ) =
    let
        bodyID =
            base ++ "-option-" ++ String.fromInt id
    in
    Html.div [ Attr.class "lia-label lia-label--top" ]
        [ Html.input
            [ Attr.class inputClass
            , Attr.class colorClass
            , Attr.type_ inputType
            , Attr.name base
            , Attr.checked checked
            , A11y_Aria.labelledBy bodyID
            , if open then
                onClick (Main.UpdateQuiz (QuizUpdate.Vector_Update quizId (VectorUpdate.Toggle id)))

              else
                Attr.disabled True
            ]
            []
        , Html.div [ Attr.id bodyID, Attr.style "width" "100%" ] body
        ]
