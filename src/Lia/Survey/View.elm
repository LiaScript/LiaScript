module Lia.Survey.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Helper exposing (ID)
import Lia.Markdown.Inline.Types exposing (Annotation, Inline, Inlines)
import Lia.Markdown.Inline.View exposing (annotation, view_inf)
import Lia.Survey.Model exposing (..)
import Lia.Survey.Types exposing (..)
import Lia.Survey.Update exposing (Msg(..))


view : Annotation -> Survey -> Vector -> Html Msg
view attr survey model =
    Html.p (annotation "lia-card" attr) <|
        case survey of
            Text lines idx ->
                view_text (get_text_state model idx) lines idx
                    |> view_survey model idx

            Vector button questions idx ->
                vector button (VectorUpdate idx) (get_vector_state model idx)
                    |> view_vector questions
                    |> view_survey model idx

            Matrix button vars questions idx ->
                matrix button (MatrixUpdate idx) (get_matrix_state model idx) vars
                    |> view_matrix vars questions
                    |> view_survey model idx


view_survey : Vector -> ID -> (Bool -> Html Msg) -> List (Html Msg)
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
            Html.button
                [ Attr.class "lia-btn", Attr.disabled True ]
                [ Html.text "Thanks" ]
          else
            Html.button
                [ Attr.class "lia-btn", onClick <| Submit idx ]
                [ Html.text "Submit" ]
        ]


view_text : String -> Int -> ID -> Bool -> Html Msg
view_text str lines idx submitted =
    let
        attr =
            [ onInput <| TextUpdate idx
            , Attr.class "lia-input"
            , Attr.placeholder "Enter text..."
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


view_vector : List ( Var, Inlines ) -> (Bool -> ( Var, Inlines ) -> Html Msg) -> Bool -> Html Msg
view_vector questions fn submitted =
    let
        fnX =
            fn submitted
    in
    Html.div [] <| List.map fnX questions


view_matrix : List Var -> List Inlines -> (Bool -> ( Int, Inlines ) -> Html Msg) -> Bool -> Html Msg
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
        |> Html.table [ Attr.class "lia-survey-matrix" ]


mat_attr : Html.Attribute Msg
mat_attr =
    Attr.align "center"


vector : Bool -> (Var -> Msg) -> (Var -> Bool) -> Bool -> ( Var, Inlines ) -> Html Msg
vector button msg fn submitted ( var, elements ) =
    Html.p
        []
        [ input button (msg var) (fn var) submitted, inline elements ]


matrix : Bool -> (ID -> Var -> Msg) -> (ID -> Var -> Bool) -> List Var -> Bool -> ( ID, Inlines ) -> Html Msg
matrix button msg fn vars submitted ( row, elements ) =
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
                        [ input button (msgX var) (fnX var) submitted ]
                )
                vars
            )
            [ Html.td [] [ inline elements ] ]


input : Bool -> Msg -> Bool -> Bool -> Html Msg
input button msg checked submitted =
    -- FIXME: lia-label MUST be placed in here and not outside the lia-*-item
    -- !!! convert the lia-*-item span to a p element when lia-label is included here
    Html.span
        [ Attr.class <|
            if button then
                "lia-check-item"
            else
                "lia-radio-item"
        ]
        [ Html.input
            [ Attr.type_ <|
                if button then
                    "checkbox"
                else
                    "radio"
            , Attr.checked checked
            , if submitted then
                Attr.disabled True
              else
                onClick msg
            ]
            []
        , Html.span
            [ Attr.class <|
                if button then
                    "lia-check-btn"
                else
                    "lia-radio-btn"
            ]
            [ Html.text <|
                if button then
                    "check"
                else
                    ""
            ]
        ]


inline : Inlines -> Html Msg
inline elements =
    Html.span [] <| List.map view_inf elements
