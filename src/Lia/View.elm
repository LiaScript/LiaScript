module Lia.View exposing (view)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Html.Lazy exposing (lazy2)
import Lia.Helper exposing (..)
import Lia.Model exposing (Model)
import Lia.Type exposing (..)
import Lia.Utils


view : Model -> Html Msg
view model =
    case model.mode of
        Slides ->
            view_slides model

        Plain ->
            view_plain model


view_plain : Model -> Html Msg
view_plain model =
    let
        f =
            view_slide { model | visible = 999 }
    in
    Html.div
        [ Attr.style
            [ ( "width", "100%" )
            , ( "overflow", "auto" )
            , ( "height", "100%" )
            ]
        ]
        (List.map f model.lia)


view_slides : Model -> Html Msg
view_slides model =
    let
        loadButton str msg =
            Html.button
                [ onClick msg
                , Attr.style [ ( "width", "calc(50% - 20px)" ) ]
                ]
                [ Html.text str ]

        content =
            Html.div []
                [ Html.div []
                    [ Html.button
                        [ onClick ContentsTable
                        , Attr.style [ ( "width", "40px" ) ]
                        ]
                        [ Html.text "T" ]
                    , loadButton "<<" PrevSlide
                    , loadButton ">>" NextSlide
                    ]
                , Html.div
                    [ Attr.style
                        [ ( "overflow", "auto" )
                        , ( "height", "100%" )
                        ]
                    ]
                    [ case get_slide model.slide model.lia of
                        Just slide ->
                            lazy2 view_slide model slide

                        Nothing ->
                            Html.text ""
                    ]
                ]
    in
    if model.contents then
        Html.div []
            [ Html.div
                [ Attr.style
                    [ ( "width", "200px" )
                    , ( "float", "left" )
                    ]
                ]
                [ view_contents model
                ]
            , Html.div
                [ Attr.style
                    [ ( "width", "calc(100% - 200px)" )
                    , ( "float", "right" )
                    ]
                ]
                [ content
                ]
            ]
    else
        content


view_contents : Model -> Html Msg
view_contents model =
    let
        f ( n, ( h, i ) ) =
            Html.div []
                [ Html.a
                    [ onClick (Load n)
                    , h
                        |> String.split " "
                        |> String.join "_"
                        |> String.append "#"
                        |> Attr.href
                    , Attr.style
                        [ ( "padding-left"
                          , toString ((i - 1) * 20) ++ "px"
                          )
                        , ( "color"
                          , if model.slide == n then
                                "#33f"
                            else
                                "#333"
                          )
                        ]
                    ]
                    [ Html.text h ]
                ]
    in
    model.lia
        |> get_headers
        |> List.map f
        |> (\h ->
                Html.div []
                    (Html.input
                        [ Attr.type_ "input"
                        , Attr.style [ ( "margin-bottom", "24px" ) ]

                        --, Attr.value <| Lia.Helper.question_state_text idx model.quiz
                        --, onInput (Input idx)
                        ]
                        []
                        :: h
                    )
           )


view_slide : Model -> Slide -> Html Msg
view_slide model slide =
    Html.div []
        (view_header slide.indentation slide.title
            :: view_body model slide.body
        )


view_header : Int -> String -> Html Msg
view_header indentation title =
    case indentation of
        0 ->
            Html.h1 [] [ Html.text title ]

        1 ->
            Html.h2 [] [ Html.text title ]

        2 ->
            Html.h3 [] [ Html.text title ]

        3 ->
            Html.h4 [] [ Html.text title ]

        4 ->
            Html.h5 [] [ Html.text title ]

        _ ->
            Html.h6 [] [ Html.text title ]


view_body : Model -> List Block -> List (Html Msg)
view_body model body =
    let
        f =
            view_block model
    in
    List.map f body


draw_circle : Int -> Html Msg
draw_circle int =
    Html.span
        [ Attr.style
            [ ( "border-radius", "50%" )
            , ( "width", "15px" )
            , ( "height", "14px" )
            , ( "padding", "3px" )
            , ( "display", "inline-block" )
            , ( "background", "#000" )
            , ( "border", "2px solid #666" )
            , ( "color", "#fff" )
            , ( "text-align", "center" )
            , ( "font", "12px Arial Bold, sans-serif" )
            ]
        ]
        [ Html.text (toString int) ]


view_block : Model -> Block -> Html Msg
view_block model block =
    case block of
        Paragraph elements ->
            Html.p [] (List.map (\e -> view_inline model e) elements)

        HorizontalLine ->
            Html.hr [] []

        Table header format body ->
            view_table model header (Array.fromList format) body

        Quote elements ->
            Html.blockquote [] (List.map (\e -> view_inline model e) elements)

        CodeBlock language code ->
            Html.pre [] [ Html.code [] [ Lia.Utils.highlight language code ] ]

        Quiz quiz idx ->
            Html.div [] [ view_quiz model quiz idx ]

        EBlock idx sub_blocks ->
            Html.div
                [ Attr.id (toString idx)
                , Attr.hidden (idx > model.visible)
                ]
                (Html.div
                    [ Attr.style
                        [ ( "display", "flex" )
                        , ( "justify-content", "center" )
                        ]
                    ]
                    [ draw_circle idx ]
                    :: List.map (\sub -> view_block model sub) sub_blocks
                )


view_quiz : Model -> Quiz -> Int -> Html Msg
view_quiz model quiz idx =
    case quiz of
        TextInput _ ->
            view_quiz_text_input model idx

        SingleChoice rslt questions ->
            view_quiz_single_choice model rslt questions idx

        MultipleChoice questions ->
            view_quiz_multiple_choice model questions idx


view_quiz_text_input : Model -> Int -> Html Msg
view_quiz_text_input model idx =
    Html.p []
        [ Html.input
            [ Attr.type_ "input"
            , Attr.value <| Lia.Helper.question_state_text idx model.quiz
            , onInput (Input idx)
            ]
            []
        , quiz_check_button model idx
        ]


quiz_check_button : Model -> Int -> Html Msg
quiz_check_button model idx =
    case Lia.Helper.quiz_state idx model.quiz of
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


view_quiz_single_choice : Model -> Int -> List (List Inline) -> Int -> Html Msg
view_quiz_single_choice model rslt questions idx =
    questions
        |> List.indexedMap (,)
        |> List.map
            (\( i, elements ) ->
                Html.p []
                    [ Html.input
                        [ Attr.type_ "radio"
                        , Attr.checked <| Lia.Helper.question_state idx i model.quiz
                        , onClick (RadioButton idx i)
                        ]
                        []
                    , Html.span [] (List.map (\e -> view_inline model e) elements)
                    ]
            )
        |> (\l -> List.append l [ quiz_check_button model idx ])
        |> Html.div []


view_quiz_multiple_choice : Model -> List ( Bool, List Inline ) -> Int -> Html Msg
view_quiz_multiple_choice model questions idx =
    questions
        |> List.indexedMap (,)
        |> List.map
            (\( i, ( _, q ) ) ->
                Html.p []
                    [ Html.input
                        [ Attr.type_ "checkbox"
                        , Attr.checked (Lia.Helper.question_state idx i model.quiz)
                        , onClick (CheckBox idx i)
                        ]
                        []
                    , Html.span [] (List.map (\x -> view_inline model x) q)
                    ]
            )
        |> (\l -> List.append l [ quiz_check_button model idx ])
        |> Html.div []


view_table : Model -> List (List Inline) -> Array String -> List (List (List Inline)) -> Html Msg
view_table model header format body =
    let
        style_ =
            Attr.style
                [ ( "border-style", "solid" )
                , ( "border-color", "#e0e0eb" )
                , ( "border-width", "1px" )
                ]

        view_row model f row =
            row
                |> List.indexedMap (,)
                |> List.map
                    (\( i, col ) ->
                        f
                            [ style_
                            , Attr.align
                                (case Array.get i format of
                                    Just a ->
                                        a

                                    Nothing ->
                                        "left"
                                )
                            ]
                            (col
                                |> List.map (\element -> view_inline model element)
                            )
                    )
    in
    Html.table
        [ Attr.attribute "cellspacing" "0"
        , Attr.attribute "cellpadding" "8"
        , style_
        ]
        (Html.thead []
            (view_row model Html.th header)
            :: List.map
                (\r ->
                    Html.tr []
                        (view_row model Html.td r)
                )
                body
        )


view_inline : Model -> Inline -> Html Msg
view_inline model element =
    case element of
        Code e ->
            Html.code [] [ Html.text e ]

        Chars e ->
            Html.text e

        Bold e ->
            Html.b [] [ view_inline model e ]

        Italic e ->
            Html.em [] [ view_inline model e ]

        Underline e ->
            Html.u [] [ view_inline model e ]

        Superscript e ->
            Html.sup [] [ view_inline model e ]

        Ref e ->
            view_reference e

        Formula mode e ->
            Lia.Utils.formula mode e

        Symbol e ->
            Lia.Utils.stringToHtml e

        HTML e ->
            Lia.Utils.stringToHtml e

        EInline idx elements ->
            Html.span
                [ Attr.id (toString idx)
                , Attr.hidden (idx > model.visible)
                ]
                (draw_circle idx
                    :: List.map (\e -> view_inline model e) elements
                )


view_reference : Reference -> Html Msg
view_reference ref =
    case ref of
        Link alt_ url_ ->
            Html.a [ Attr.href url_ ] [ Html.text alt_ ]

        Image alt_ url_ ->
            Html.img [ Attr.src url_ ] [ Html.text alt_ ]

        Movie alt_ url_ ->
            Html.iframe [ Attr.src url_ ] [ Html.text alt_ ]



--        EList elems ->
--            Html.ul []
--                (elems
--                    |> List.map (\e -> List.map view_element e)
--                    |> List.map (\e -> Html.li [] e)
--                )
--        Lia cmd params ->
--            text (cmd ++ " : " ++ toString params)
-- SUBSCRIPTIONS
-- HTTP
