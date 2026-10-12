module Lia.Markdown.Quiz.Vector.View exposing (view)

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
view : Bool -> String -> Int -> Quiz body -> State -> List (List (Html Main.Msg)) -> ( List (Attribute Main.Msg), List (Html Main.Msg) )
view open class quizId quiz state rendered =
    case ( quiz.solution, state ) of
        ( SingleChoice _, SingleChoice list ) ->
            ( [ A11y_Role.radioGroup ]
            , List.map2 (option "lia-radio" "radio" A11y_Role.radio open class quizId) list (List.indexedMap Tuple.pair rendered)
            )

        ( MultipleChoice _, MultipleChoice list ) ->
            ( [ A11y_Role.list ]
            , List.map2 (option "lia-checkbox" "checkbox" A11y_Role.checkBox open class quizId) list (List.indexedMap Tuple.pair rendered)
            )

        _ ->
            ( [], [] )


{-| **private:** A radio button or check box with its content `body`, only
clickable if the quiz is `open`.
-}
option : String -> String -> Attribute Main.Msg -> Bool -> String -> Int -> Bool -> ( Int, List (Html Main.Msg) ) -> Html Main.Msg
option inputClass inputType role open colorClass quizId checked ( id, body ) =
    Html.label [ Attr.class "lia-label lia-label--top", A11y_Role.listItem ]
        [ Html.input
            [ Attr.class inputClass
            , Attr.class colorClass
            , Attr.type_ inputType
            , Attr.checked checked
            , role
            , if open then
                onClick (Main.UpdateQuiz (QuizUpdate.Vector_Update quizId (VectorUpdate.Toggle id)))

              else
                Attr.disabled True
            ]
            []
        , Html.div [ Attr.style "width" "100%" ] body
        ]
