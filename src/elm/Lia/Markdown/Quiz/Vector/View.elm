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
-}
view : Bool -> String -> Int -> Quiz body -> State -> List (List (Html Main.Msg)) -> ( List (Attribute Main.Msg), List (Html Main.Msg) )
view open class quizId quiz state rendered =
    case ( quiz.solution, state ) of
        ( SingleChoice _, SingleChoice list ) ->
            ( [ A11y_Role.radioGroup ], table (radio open class quizId) rendered list )

        ( MultipleChoice _, MultipleChoice list ) ->
            ( [ A11y_Role.list ], table (check open class quizId) rendered list )

        _ ->
            ( [], [] )


table : (Bool -> ( Int, List (Html Main.Msg) ) -> Html Main.Msg) -> List (List (Html Main.Msg)) -> List Bool -> List (Html Main.Msg)
table fn contents bool =
    contents
        |> List.indexedMap Tuple.pair
        |> List.map2 fn bool


check : Bool -> String -> Int -> Bool -> ( Int, List (Html Main.Msg) ) -> Html Main.Msg
check open colorClass quizId checked ( id, body ) =
    Html.label [ Attr.class "lia-label lia-label--top", A11y_Role.listItem ]
        [ Html.input
            [ Attr.class "lia-checkbox"
            , Attr.class colorClass
            , Attr.type_ "checkbox"
            , Attr.checked checked
            , A11y_Role.checkBox
            , if open then
                onClick (Main.UpdateQuiz (QuizUpdate.Vector_Update quizId (VectorUpdate.Toggle id)))

              else
                Attr.disabled True
            ]
            []
        , Html.div [ Attr.style "width" "100%" ] body
        ]


radio : Bool -> String -> Int -> Bool -> ( Int, List (Html Main.Msg) ) -> Html Main.Msg
radio open colorClass quizId checked ( id, body ) =
    Html.label [ Attr.class "lia-label lia-label--top", A11y_Role.listItem ]
        [ Html.input
            [ Attr.class "lia-radio"
            , Attr.class colorClass
            , Attr.type_ "radio"
            , Attr.checked checked
            , A11y_Role.radio
            , if open then
                onClick (Main.UpdateQuiz (QuizUpdate.Vector_Update quizId (VectorUpdate.Toggle id)))

              else
                Attr.disabled True
            ]
            []
        , Html.div [ Attr.style "width" "100%" ] body
        ]
