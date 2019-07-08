module Lia.Markdown.Survey.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines)
import Lia.Markdown.Inline.View exposing (annotation, view_inf)
import Lia.Markdown.Survey.Model exposing (get_matrix_state, get_select_state, get_submission_state, get_text_state, get_vector_state)
import Lia.Markdown.Survey.Types exposing (Survey, Type(..), Vector)
import Lia.Markdown.Survey.Update exposing (Msg(..))
import Translations exposing (Lang, surveySubmit, surveySubmitted, surveyText)


view : Lang -> Annotation -> Survey -> Vector -> Html Msg
view lang attr survey model =
    Html.p (annotation "lia-quiz lia-card" attr) <|
        case survey.survey of
            Text lines ->
                view_text lang (get_text_state model survey.id) lines survey.id
                    |> view_survey lang model survey.id survey.javascript

            Select inlines ->
                view_select lang inlines (get_select_state model survey.id) survey.id
                    |> view_survey lang model survey.id survey.javascript

            Vector button questions ->
                vector button (VectorUpdate survey.id) (get_vector_state model survey.id)
                    |> view_vector questions
                    |> view_survey lang model survey.id survey.javascript

            Matrix button header vars questions ->
                matrix button (MatrixUpdate survey.id) (get_matrix_state model survey.id) vars
                    |> view_matrix header vars questions
                    |> view_survey lang model survey.id survey.javascript


view_survey : Lang -> Vector -> Int -> Maybe String -> (Bool -> Html Msg) -> List (Html Msg)
view_survey lang model idx javascript fn =
    let
        submitted =
            get_submission_state model idx
    in
    [ fn submitted, submit_button lang submitted idx javascript ]


submit_button : Lang -> Bool -> Int -> Maybe String -> Html Msg
submit_button lang submitted idx javascript =
    Html.div []
        [ if submitted then
            Html.button
                [ Attr.class "lia-btn", Attr.disabled True ]
                [ Html.text (surveySubmitted lang) ]

          else
            Html.button
                [ Attr.class "lia-btn", onClick <| Submit idx javascript ]
                [ Html.text (surveySubmit lang) ]
        ]


view_select : Lang -> List Inlines -> ( Bool, Int ) -> Int -> Bool -> Html Msg
view_select lang options ( open, value ) id submitted =
    Html.span
        []
        [ Html.span
            [ Attr.class "lia-dropdown"
            , if submitted then
                Attr.disabled True

              else
                onClick <| SelectChose id
            ]
            [ get_option value options
            , Html.span
                [ Attr.class "lia-icon"
                , Attr.style "float" "right"
                ]
                [ if open then
                    Html.text "arrow_drop_down"

                  else
                    Html.text "arrow_drop_up"
                ]
            ]
        , options
            |> List.indexedMap (option id)
            |> Html.div
                [ Attr.class "lia-dropdown-options"
                , Attr.style "max-height" <|
                    if open then
                        "2000px"

                    else
                        "0px"
                ]
        ]


option : Int -> Int -> Inlines -> Html Msg
option id1 id2 opt =
    opt
        |> List.map view_inf
        |> Html.div
            [ Attr.class "lia-dropdown-option"
            , SelectUpdate id1 id2
                |> onClick
            ]


get_option : Int -> List Inlines -> Html Msg
get_option id list =
    case ( id, list ) of
        ( 0, x :: _ ) ->
            x |> List.map view_inf |> Html.span []

        ( i, _ :: xs ) ->
            get_option (i - 1) xs

        ( _, [] ) ->
            Html.text "choose"


view_text : Lang -> String -> Int -> Int -> Bool -> Html Msg
view_text lang str lines idx submitted =
    let
        attr =
            [ onInput <| TextUpdate idx
            , Attr.class "lia-textarea"
            , Attr.placeholder (surveyText lang)
            , Attr.value str
            , Attr.disabled submitted
            ]
    in
    case lines of
        1 ->
            Html.input attr []

        _ ->
            Html.textarea (Attr.rows lines :: attr) []


view_vector : List ( String, Inlines ) -> (Bool -> ( String, Inlines ) -> Html Msg) -> Bool -> Html Msg
view_vector questions fn submitted =
    let
        fnX =
            fn submitted
    in
    Html.div [] <| List.map fnX questions


view_matrix : List Inlines -> List String -> List Inlines -> (Bool -> ( Int, Inlines ) -> Html Msg) -> Bool -> Html Msg
view_matrix header vars questions fn submitted =
    let
        th =
            header
                |> List.map (List.map view_inf >> Html.th [ Attr.align "center" ])
                |> Html.thead []

        fnX =
            fn submitted
    in
    questions
        |> List.indexedMap Tuple.pair
        |> List.map fnX
        |> (::) th
        |> Html.table [ Attr.class "lia-survey-matrix" ]


vector : Bool -> (String -> Msg) -> (String -> Bool) -> Bool -> ( String, Inlines ) -> Html Msg
vector button msg fn submitted ( var, elements ) =
    Html.table [ Attr.attribute "cellspacing" "8" ]
        [ Html.td [ Attr.attribute "valign" "top", Attr.class "lia-label" ]
            [ input button (msg var) (fn var) submitted ]
        , Html.td [ Attr.class "lia-label" ]
            [ inline elements ]
        ]


matrix : Bool -> (Int -> String -> Msg) -> (Int -> String -> Bool) -> List String -> Bool -> ( Int, Inlines ) -> Html Msg
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
                    Html.td [ Attr.align "center" ]
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
