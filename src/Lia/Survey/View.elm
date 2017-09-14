module Lia.Survey.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Inline.Types exposing (ID, Inline, Line)
import Lia.Inline.View exposing (view_inf)
import Lia.Survey.Model exposing (..)
import Lia.Survey.Types exposing (..)
import Lia.Survey.Update exposing (Msg(..))


view : Model -> Survey -> Html Msg
view model survey =
    let
        vec type_ msg fn questions =
            vector type_ msg fn |> view_vector questions

        mat type_ msg fn vars questions =
            matrix type_ msg fn vars |> view_matrix vars questions
    in
    Html.p [] <|
        case survey of
            Text lines idx ->
                view_text (get_text_state model idx) lines idx
                    |> view_survey model idx

            SingleChoice questions idx ->
                vec "radio" (Vector idx) (get_vector_state model idx) questions
                    |> view_survey model idx

            MultiChoice questions idx ->
                vec "checkbox" (Vector idx) (get_vector_state model idx) questions
                    |> view_survey model idx

            SingleChoiceBlock vars questions idx ->
                mat "radio" (Matrix idx) (get_matrix_state model idx) vars questions
                    |> view_survey model idx

            MultiChoiceBlock vars questions idx ->
                mat "checkbox" (Matrix idx) (get_matrix_state model idx) vars questions
                    |> view_survey model idx


view_survey : Model -> Int -> (Bool -> Html Msg) -> List (Html Msg)
view_survey model idx fn =
    let
        submitted =
            get_submission_state model idx
    in
    [ fn submitted, submit_button submitted idx ]


submit_button : Bool -> ID -> Html Msg
submit_button submitted idx =
    Html.div []
        [ if submitted then
            Html.button [ Attr.disabled True ] [ Html.text "Thanks" ]
          else
            Html.button [ onClick <| Submit idx ] [ Html.text "Submit" ]
        ]


view_text : String -> Int -> ID -> Bool -> Html Msg
view_text str lines idx submitted =
    let
        attr =
            [ onInput <| TextInput idx
            , Attr.value str
            , Attr.disabled submitted
            ]
    in
    Html.div []
        [ case lines of
            1 ->
                Html.input attr []

            _ ->
                Html.textarea (Attr.rows lines :: attr) []
        ]


view_vector : List ( Var, Line ) -> (Bool -> ( Var, Line ) -> Html Msg) -> Bool -> Html Msg
view_vector questions fn submitted =
    let
        fnX =
            fn submitted
    in
    Html.div [] <| List.map fnX questions


view_matrix : List Var -> List Line -> (Bool -> ( Int, Line ) -> Html Msg) -> Bool -> Html Msg
view_matrix vars questions fn submitted =
    let
        th =
            (vars ++ [ "" ])
                |> List.map (\v -> Html.td [ mat_attr ] [ Html.text v ])
                |> Html.thead []

        fnX =
            fn submitted
    in
    questions
        |> List.indexedMap (,)
        |> List.map fnX
        |> List.append [ th ]
        |> Html.table []


mat_attr : Html.Attribute Msg
mat_attr =
    Attr.align "center"


vector : String -> (Var -> Msg) -> (Var -> Bool) -> Bool -> ( Var, Line ) -> Html Msg
vector type_ msg fn submitted ( var, elements ) =
    Html.p [] [ input type_ (msg var) (fn var) submitted, inline elements ]


matrix : String -> (ID -> Var -> Msg) -> (ID -> Var -> Bool) -> List Var -> Bool -> ( ID, Line ) -> Html Msg
matrix type_ msg fn vars submitted ( row, elements ) =
    let
        msgX =
            msg row

        fnX =
            fn row
    in
    Html.tr [] <|
        List.append
            (List.map
                (\var ->
                    Html.td [ mat_attr ]
                        [ input type_ (msgX var) (fnX var) submitted ]
                )
                vars
            )
            [ Html.td [] [ inline elements ] ]


input : String -> Msg -> Bool -> Bool -> Html Msg
input type_ msg checked submitted =
    Html.input
        [ Attr.type_ type_
        , Attr.checked checked
        , if submitted then
            Attr.disabled True
          else
            onClick msg
        ]
        []


inline : Line -> Html Msg
inline elements =
    Html.span [] <| List.map view_inf elements
