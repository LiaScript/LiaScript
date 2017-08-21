module Lia.Quiz.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Inline.View as Elem
import Lia.Quiz.Model exposing (..)
import Lia.Quiz.Update exposing (Msg(..))
import Lia.Type exposing (Inline, Quiz(..))
import Lia.Utils


view : Model -> Quiz -> Int -> List (List Inline) -> Html Msg
view model quiz idx hints =
    let
        quiz_html =
            case quiz of
                TextInput _ ->
                    view_quiz_text_input model idx

                SingleChoice rslt questions ->
                    view_quiz_single_choice model rslt questions idx

                MultipleChoice questions ->
                    view_quiz_multiple_choice model questions idx

        hint_count =
            get_hint_counter idx model
    in
    List.append quiz_html
        [ quiz_check_button model idx
        , Html.text " "
        , Html.sup [] [ Html.a [ Attr.href "#", onClick (ShowHint idx) ] [ Html.text "?" ] ]
        , Html.div [] (view_hints model hint_count hints)
        ]
        |> Html.p []


view_hints : Model -> Int -> List (List Inline) -> List (Html Msg)
view_hints model counter hints =
    if counter > 0 then
        case hints of
            [] ->
                []

            x :: xs ->
                Html.p [] (Lia.Utils.stringToHtml "&#x1f4a1;" :: List.map (Elem.view 999) x)
                    :: view_hints model (counter - 1) xs
    else
        []


view_quiz_text_input : Model -> Int -> List (Html Msg)
view_quiz_text_input model idx =
    [ Html.input
        [ Attr.type_ "input"
        , Attr.value <| question_state_text idx model
        , onInput (Input idx)
        ]
        []
    ]


quiz_check_button : Model -> Int -> Html Msg
quiz_check_button model idx =
    case quiz_state idx model of
        ( Just b, trial_counts ) ->
            Html.button
                (if b then
                    [ Attr.style [ ( "color", "green" ) ] ]
                 else
                    [ Attr.style [ ( "color", "red" ) ], onClick (Check idx) ]
                )
                [ Html.text ("Check " ++ toString trial_counts) ]

        ( Nothing, _ ) ->
            Html.button [ onClick (Check idx) ] [ Html.text "Check" ]


view_quiz_single_choice : Model -> Int -> List (List Inline) -> Int -> List (Html Msg)
view_quiz_single_choice model rslt questions idx =
    questions
        |> List.indexedMap (,)
        |> List.map
            (\( i, elements ) ->
                Html.p []
                    [ Html.input
                        [ Attr.type_ "radio"
                        , Attr.checked <| question_state idx i model
                        , onClick (RadioButton idx i)
                        ]
                        []
                    , Html.span [] (List.map (\e -> Elem.view 999 e) elements)
                    ]
            )


view_quiz_multiple_choice : Model -> List ( Bool, List Inline ) -> Int -> List (Html Msg)
view_quiz_multiple_choice model questions idx =
    questions
        |> List.indexedMap (,)
        |> List.map
            (\( i, ( _, q ) ) ->
                Html.p []
                    [ Html.input
                        [ Attr.type_ "checkbox"
                        , Attr.checked (question_state idx i model)
                        , onClick (CheckBox idx i)
                        ]
                        []
                    , Html.span [] (List.map (\x -> Elem.view 999 x) q)
                    ]
            )
