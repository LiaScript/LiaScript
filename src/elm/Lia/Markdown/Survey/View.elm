module Lia.Markdown.Survey.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Markdown.Inline.Annotation exposing (Parameters, annotation)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Survey.Model exposing (get_matrix_state, get_select_state, get_submission_state, get_text_state, get_vector_state)
import Lia.Markdown.Survey.Types exposing (Survey, Type(..), Vector)
import Lia.Markdown.Survey.Update exposing (Msg(..))
import Translations exposing (surveySubmit, surveySubmitted, surveyText)


view : Config -> Parameters -> Survey -> Vector -> Html Msg
view config attr survey model =
    Html.p (annotation "lia-quiz lia-card" attr) <|
        case survey.survey of
            Text lines ->
                view_text config (get_text_state model survey.id) lines survey.id
                    |> view_survey config model survey.id survey.javascript

            Select inlines ->
                view_select config inlines (get_select_state model survey.id) survey.id
                    |> view_survey config model survey.id survey.javascript

            Vector button questions ->
                vector config button (VectorUpdate survey.id) (get_vector_state model survey.id)
                    |> view_vector questions
                    |> view_survey config model survey.id survey.javascript

            Matrix button header vars questions ->
                matrix config button (MatrixUpdate survey.id) (get_matrix_state model survey.id) vars
                    |> view_matrix config header vars questions
                    |> view_survey config model survey.id survey.javascript


view_survey : Config -> Vector -> Int -> Maybe String -> (Bool -> Html Msg) -> List (Html Msg)
view_survey config model idx javascript fn =
    let
        submitted =
            get_submission_state model idx
    in
    [ fn submitted, submit_button config submitted idx javascript ]


submit_button : Config -> Bool -> Int -> Maybe String -> Html Msg
submit_button config submitted idx javascript =
    Html.div []
        [ if submitted then
            Html.button
                [ Attr.class "lia-btn", Attr.disabled True ]
                [ Html.text (surveySubmitted config.lang) ]

          else
            Html.button
                [ Attr.class "lia-btn", onClick <| Submit idx javascript ]
                [ Html.text (surveySubmit config.lang) ]
        ]


view_select : Config -> List Inlines -> ( Bool, Int ) -> Int -> Bool -> Html Msg
view_select config options ( open, value ) id submitted =
    Html.span
        []
        [ Html.span
            [ Attr.class "lia-dropdown"
            , if submitted then
                Attr.disabled True

              else
                onClick <| SelectChose id
            ]
            [ get_option config value options
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
            |> List.indexedMap (option config id)
            |> Html.div
                [ Attr.class "lia-dropdown-options"
                , Attr.style "max-height" <|
                    if open then
                        "2000px"

                    else
                        "0px"
                ]
        ]


option : Config -> Int -> Int -> Inlines -> Html Msg
option config id1 id2 opt =
    opt
        |> viewer config
        |> Html.div
            [ Attr.class "lia-dropdown-option"
            , SelectUpdate id1 id2
                |> onClick
            ]


get_option : Config -> Int -> List Inlines -> Html Msg
get_option config id list =
    case ( id, list ) of
        ( 0, x :: _ ) ->
            x |> viewer config |> Html.span []

        ( i, _ :: xs ) ->
            get_option config (i - 1) xs

        ( _, [] ) ->
            Html.text "choose"


view_text : Config -> String -> Int -> Int -> Bool -> Html Msg
view_text config str lines idx submitted =
    let
        attr =
            [ onInput <| TextUpdate idx
            , Attr.class "lia-textarea"
            , Attr.placeholder (surveyText config.lang)
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


view_matrix : Config -> List Inlines -> List String -> List Inlines -> (Bool -> ( Int, Inlines ) -> Html Msg) -> Bool -> Html Msg
view_matrix config header vars questions fn submitted =
    let
        th =
            header
                |> List.map (viewer config >> Html.th [ Attr.align "center" ])
                |> Html.thead []

        fnX =
            fn submitted
    in
    questions
        |> List.indexedMap Tuple.pair
        |> List.map fnX
        |> (::) th
        |> Html.table [ Attr.class "lia-survey-matrix" ]


vector : Config -> Bool -> (String -> Msg) -> (String -> Bool) -> Bool -> ( String, Inlines ) -> Html Msg
vector config button msg fn submitted ( var, elements ) =
    Html.table [ Attr.attribute "cellspacing" "8" ]
        [ Html.td [ Attr.attribute "valign" "top", Attr.class "lia-label" ]
            [ input button (msg var) (fn var) submitted ]
        , Html.td [ Attr.class "lia-label" ]
            [ inline config elements ]
        ]


matrix : Config -> Bool -> (Int -> String -> Msg) -> (Int -> String -> Bool) -> List String -> Bool -> ( Int, Inlines ) -> Html Msg
matrix config button msg fn vars submitted ( row, elements ) =
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
            [ Html.td [] [ inline config elements ] ]


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


inline : Config -> Inlines -> Html Msg
inline config elements =
    Html.span [] <| viewer config elements
