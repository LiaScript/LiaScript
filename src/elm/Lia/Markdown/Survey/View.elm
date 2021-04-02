module Lia.Markdown.Survey.View exposing (view)

import Html exposing (Html, button)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Survey.Model exposing (get_matrix_state, get_select_state, get_submission_state, get_text_state, get_vector_state)
import Lia.Markdown.Survey.Types exposing (Survey, Type(..), Vector)
import Lia.Markdown.Survey.Update exposing (Msg(..))
import Lia.Utils exposing (blockKeydown, btn)
import Translations exposing (surveySubmit, surveySubmitted, surveyText)


view : Config sub -> Parameters -> Survey -> Vector -> Html (Msg sub)
view config attr survey model =
    case survey.survey of
        Text lines ->
            view_text config (get_text_state model survey.id) lines survey.id
                |> view_survey config attr "text" model survey.id survey.javascript

        Select inlines ->
            view_select config inlines (get_select_state model survey.id) survey.id
                |> view_survey config attr "select" model survey.id survey.javascript

        Vector button questions ->
            vector config button (VectorUpdate survey.id) (get_vector_state model survey.id)
                |> view_vector questions
                |> view_survey config
                    attr
                    (if button then
                        "single-choice"

                     else
                        "multiple-choice"
                    )
                    model
                    survey.id
                    survey.javascript

        --|> Html.p (annotation "lia-quiz" attr)
        Matrix button header vars questions ->
            matrix config button (MatrixUpdate survey.id) (get_matrix_state model survey.id) vars
                |> view_matrix config header questions
                |> view_survey config attr "matrix" model survey.id survey.javascript



--|> Html.p (annotation "lia-quiz" attr)


view_survey : Config sub -> Parameters -> String -> Vector -> Int -> Maybe String -> (Bool -> Html (Msg sub)) -> Html (Msg sub)
view_survey config attr class model idx javascript fn =
    let
        submitted =
            get_submission_state model idx
    in
    Html.div
        (annotation
            ("lia-quiz lia-quiz-"
                ++ class
                ++ (if submitted then
                        ""

                    else
                        " open"
                   )
            )
            attr
        )
        [ fn submitted
        , submit_button config submitted idx javascript
        ]


submit_button : Config sub -> Bool -> Int -> Maybe String -> Html (Msg sub)
submit_button config submitted idx javascript =
    Html.div [ Attr.class "lia-quiz__control" ]
        [ if submitted then
            btn
                { msg = Nothing
                , tabbable = False
                , title = surveySubmitted config.lang
                }
                [ Attr.class "lia-btn--outline lia-quiz__check" ]
                [ Html.text (surveySubmitted config.lang) ]

          else
            btn
                { msg = Just <| Submit idx javascript
                , tabbable = False
                , title = surveySubmit config.lang
                }
                [ Attr.class "lia-btn--outline lia-quiz__check" ]
                [ Html.text (surveySubmit config.lang) ]
        ]


view_select : Config sub -> List Inlines -> ( Bool, Int ) -> Int -> Bool -> Html (Msg sub)
view_select config options ( open, value ) id submitted =
    Html.div
        [ Attr.class "lia-dropdown" ]
        [ Html.span
            [ Attr.class "lia-dropdown__selected"
            , if submitted then
                Attr.disabled True

              else
                onClick <| SelectChose id
            ]
            [ get_option config value options
            , Html.i
                [ Attr.class "lia-icon"
                , Attr.class <|
                    if open then
                        "icon-chevron-up"

                    else
                        "icon-chevron-down"
                ]
                []
            ]
        , options
            |> List.indexedMap (option config id)
            |> Html.div
                [ Attr.class "lia-dropdown-options is-hidden"
                ]
        ]


option : Config sub -> Int -> Int -> Inlines -> Html (Msg sub)
option config id1 id2 opt =
    opt
        |> (viewer config >> List.map (Html.map Script))
        |> Html.div
            [ Attr.class "lia-dropdown-option"
            , SelectUpdate id1 id2 |> onClick
            ]


get_option : Config sub -> Int -> List Inlines -> Html (Msg sub)
get_option config id list =
    case ( id, list ) of
        ( 0, x :: _ ) ->
            x |> (viewer config >> List.map (Html.map Script)) |> Html.span []

        ( i, _ :: xs ) ->
            get_option config (i - 1) xs

        ( _, [] ) ->
            Html.text "choose"


view_text : Config sub -> String -> Int -> Int -> Bool -> Html (Msg sub)
view_text config str lines idx submitted =
    let
        attr =
            [ onInput <| TextUpdate idx
            , blockKeydown (TextUpdate idx str)
            , Attr.placeholder (surveyText config.lang)
            , Attr.value str
            , Attr.disabled submitted
            ]
    in
    case lines of
        1 ->
            Html.input (Attr.class "lia-input lia-quiz__input" :: attr) []

        _ ->
            Html.textarea (Attr.class "lia-input lia-quiz__input" :: Attr.rows lines :: attr) []


view_vector : List ( String, Inlines ) -> (Bool -> ( String, Inlines ) -> Html (Msg sub)) -> Bool -> Html (Msg sub)
view_vector questions fn submitted =
    let
        fnX =
            fn submitted
    in
    List.map fnX questions
        |> Html.div [ Attr.class "lia-quiz__answers" ]


view_matrix :
    Config sub
    -> List Inlines
    -> List Inlines
    -> (Bool -> ( Int, Inlines ) -> Html (Msg sub))
    -> Bool
    -> Html (Msg sub)
view_matrix config header questions fn submitted =
    let
        fnX =
            fn submitted
    in
    Html.div [ Attr.class "lia-table-responsive has-thead-sticky has-last-col-sticky" ]
        [ Html.table [ Attr.class "lia-table lia-survey-matrix is-alternating" ]
            [ header
                |> List.map ((viewer config >> List.map (Html.map Script)) >> Html.th [ Attr.class "lia-table__head lia-survey-matrix__head" ])
                |> Html.thead [ Attr.class "lia-table__head lia-survey-matric__head" ]
            , questions
                |> List.indexedMap Tuple.pair
                |> List.map fnX
                |> Html.tbody [ Attr.class "lia-table__body lia-survey-matrix__body" ]
            ]
        ]


vector : Config sub -> Bool -> (String -> Msg sub) -> (String -> Bool) -> Bool -> ( String, Inlines ) -> Html (Msg sub)
vector config button msg fn submitted ( var, elements ) =
    Html.label [ Attr.class "lia-label" ]
        [ input button (msg var) (fn var) submitted
        , Html.span [] [ inline config elements ]
        ]


matrix :
    Config sub
    -> Bool
    -> (Int -> String -> Msg sub)
    -> (Int -> String -> Bool)
    -> List String
    -> Bool
    -> ( Int, Inlines )
    -> Html (Msg sub)
matrix config button msg fn vars submitted ( row, elements ) =
    let
        msgX =
            msg row

        fnX =
            fn row
    in
    Html.tr [ Attr.class "lia-table__row lia-survey-matrix__row" ] <|
        List.append
            (List.map
                (\var ->
                    Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ]
                        [ input button (msgX var) (fnX var) submitted ]
                )
                vars
            )
            [ Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ] [ inline config elements ] ]


input : Bool -> Msg sub -> Bool -> Bool -> Html (Msg sub)
input button msg checked submitted =
    Html.input
        [ Attr.class <|
            if button then
                "lia-checkbox"

            else
                "lia-radio"
        , Attr.type_ <|
            if button then
                "checkbox"

            else
                "radio"
        , if submitted then
            Attr.disabled True

          else
            onClick msg
        , Attr.checked checked
        ]
        []


inline : Config sub -> Inlines -> Html (Msg sub)
inline config elements =
    Html.span [] <| (viewer config >> List.map (Html.map Script)) elements
