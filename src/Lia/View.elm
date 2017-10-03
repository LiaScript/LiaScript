module Lia.View exposing (view)

import Array exposing (Array)
import Char
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Html.Lazy exposing (lazy2)
import Lia.Chart.View
import Lia.Code.View as Codes
import Lia.Effect.Model as Effect
import Lia.Effect.View as Effects
import Lia.Helper exposing (..)
import Lia.Index.View
import Lia.Inline.Types exposing (Inline)
import Lia.Inline.View as Elem
import Lia.Model exposing (Model)
import Lia.Quiz.View
import Lia.Survey.View
import Lia.Types exposing (..)
import Lia.Update exposing (Msg(..))
import String


view : Model -> Html Msg
view model =
    case model.mode of
        Slides ->
            view_slides model

        Slides_only ->
            view_slides
                { model
                    | silent = True
                    , effect_model = Effect.init_silent
                }

        Textbook ->
            view_plain model


view_plain : Model -> Html Msg
view_plain model =
    let
        f =
            view_slide { model | effect_model = Effect.init_silent }
    in
    Html.div
        [ Attr.class "lia-plain"
        ]
        (List.map f model.slides)


view_slides : Model -> Html Msg
view_slides model =
    let
        loadButton str msg =
            Html.button
                [ onClick msg
                , Attr.class "lia-btn lia-slide-control lia-left"
                ]
                [ Html.text str ]

        content =
            Html.div
                [ Attr.class "lia-slide"
                ]
                [ Html.div
                    [ Attr.class "lia-toolbar"
                    ]
                    (List.append
                        [ Html.button
                            [ onClick ToggleContentsTable
                            , Attr.class "lia-btn lia-toc-control lia-left"
                            ]
                            [ Html.text "toc" ]
                        , Html.button [ Attr.class "lia-btn lia-left", onClick SwitchMode ]
                            [ case model.mode of
                                Slides ->
                                    Html.text "hearing"

                                _ ->
                                    Html.text "visibility"
                            ]
                        , Html.span [ Attr.class "lia-spacer" ] []
                        , loadButton "navigate_before" PrevSlide
                        , Html.span [ Attr.class "lia-labeled lia-left" ]
                            [ Html.span [ Attr.class "lia-label" ]
                                [ Html.text (toString (model.current_slide + 1))
                                , case model.mode of
                                    Slides ->
                                        Html.text <|
                                            String.concat
                                                [ " ("
                                                , toString (model.effect_model.visible + 1)
                                                , "/"
                                                , toString (model.effect_model.effects + 1)
                                                , ")"
                                                ]

                                    _ ->
                                        Html.text ""
                                ]
                            ]
                        , loadButton "navigate_next" NextSlide
                        , Html.span [ Attr.class "lia-spacer" ] []
                        ]
                        (view_themes model.theme model.theme_light)
                    )
                , Html.div
                    [ Attr.class "lia-content"
                    ]
                    [ case get_slide model.current_slide model.slides of
                        Just slide ->
                            lazy2 view_slide model slide

                        Nothing ->
                            Html.text ""
                    ]
                ]
    in
    Html.div
        [ Attr.class
            ("lia-canvas lia-theme-"
                ++ model.theme
                ++ " lia-variant-"
                ++ (if model.theme_light then
                        "light"
                    else
                        "dark"
                   )
            )
        ]
        (if model.show_contents then
            [ view_contents model
            , content
            ]
         else
            [ content ]
        )


capitalize : String -> String
capitalize s =
    case String.uncons s of
        Just ( c, ss ) ->
            String.cons (Char.toUpper c) ss

        Nothing ->
            s


view_themes : String -> Bool -> List (Html Msg)
view_themes current_theme light =
    let
        themes =
            [ "default", "amber", "blue", "green", "grey", "purple" ]
    in
    [ Html.button [ Attr.class "lia-btn lia-right", onClick ThemeLight ]
        [ if light then
            Html.text "star"
          else
            Html.text "star_border"
        ]
    , Html.select
        [ onInput Theme
        , Attr.class "lia-right lia-select"
        ]
        (themes
            |> List.map
                (\t ->
                    Html.option
                        [ Attr.value t, Attr.selected (capitalize t ++ " Theme" == current_theme) ]
                        [ Html.text (capitalize t ++ " Theme") ]
                )
        )
    ]


view_contents : Model -> Html Msg
view_contents model =
    let
        f ( n, ( h, i ) ) =
            Html.a
                [ onClick (Load n)
                , Attr.class
                    ("lia-toc-l"
                        ++ toString i
                        ++ (if model.current_slide == n then
                                " lia-active"
                            else
                                ""
                           )
                    )
                , h
                    |> String.split " "
                    |> String.join "_"
                    |> String.append "#"
                    |> Attr.href
                ]
                [ Html.text h ]
    in
    model.slides
        |> get_headers
        |> (\list ->
                case model.index_model.results of
                    Nothing ->
                        list

                    Just index ->
                        list |> List.filter (\( l, x ) -> List.member l index)
           )
        |> List.map f
        |> (\h ->
                Html.div
                    [ Attr.class "lia-toc" ]
                    [ Html.map UpdateIndex <| Lia.Index.View.view model.index_model
                    , Html.div
                        [ Attr.class "lia-content"
                        ]
                        h
                    ]
           )


view_slide : Model -> Slide -> Html Msg
view_slide model slide =
    slide.body
        |> view_body model
        |> List.append [ view_header slide.indentation slide.title ]
        |> (\b -> List.append b [ Html.footer [] [] ])
        |> Html.div [ Attr.class "lia-section" ]


view_header : Int -> String -> Html Msg
view_header indentation title =
    [ Html.text title ]
        |> (case indentation of
                0 ->
                    Html.h1 [ Attr.class "lia-inline lia-h1" ]

                1 ->
                    Html.h2 [ Attr.class "lia-inline lia-h2" ]

                2 ->
                    Html.h3 [ Attr.class "lia-inline lia-h3" ]

                3 ->
                    Html.h4 [ Attr.class "lia-inline lia-h4" ]

                4 ->
                    Html.h5 [ Attr.class "lia-inline lia-h5" ]

                _ ->
                    Html.h6 [ Attr.class "lia-inline lia-h6" ]
           )


view_body : Model -> List Block -> List (Html Msg)
view_body model body =
    let
        f =
            view_block model
    in
    List.map f body


to_tuple : Int -> Html Msg -> ( Int, Html Msg )
to_tuple i html =
    ( i, html )


zero_tuple : Html Msg -> ( Int, Html Msg )
zero_tuple =
    to_tuple 0


view_block : Model -> Block -> Html Msg
view_block model block =
    case block of
        Paragraph elements ->
            elements
                |> List.map (\e -> Elem.view model.effect_model.visible e)
                |> Html.p [ Attr.class "lia-inline lia-paragraph" ]

        HLine ->
            Html.hr [ Attr.class "lia-inline lia-horiz-line" ] []

        Table header format body ->
            view_table model header (Array.fromList format) body

        Quote elements ->
            elements
                |> List.map (\e -> Elem.view model.effect_model.visible e)
                |> Html.blockquote [ Attr.class "lia-inline lia-quote" ]

        CodeBlock code ->
            code
                |> Codes.view model.code_model
                |> Html.map UpdateCode

        Quiz quiz Nothing ->
            Lia.Quiz.View.view model.quiz_model quiz False
                |> Html.map UpdateQuiz

        Quiz quiz (Just ( answer, hidden_effects )) ->
            if Lia.Quiz.View.view_solution model.quiz_model quiz then
                answer
                    |> view_body model
                    |> List.append [ Html.map UpdateQuiz <| Lia.Quiz.View.view model.quiz_model quiz False ]
                    |> Html.div []
            else
                Lia.Quiz.View.view model.quiz_model quiz True
                    |> Html.map UpdateQuiz

        SurveyBlock survey ->
            survey
                |> Lia.Survey.View.view model.survey_model
                |> Html.map UpdateSurvey

        EBlock idx effect_name sub_blocks ->
            Effects.view_block model.effect_model (view_block model) idx effect_name sub_blocks

        BulletList list ->
            list
                |> List.map (\l -> Html.li [] (List.map (\ll -> view_block model ll) l))
                |> Html.ul [ Attr.class "lia-inline lia-list lia-unordered" ]

        OrderedList list ->
            list
                |> List.map (\l -> Html.li [] (List.map (\ll -> view_block model ll) l))
                |> Html.ol [ Attr.class "lia-inline lia-list lia-ordered" ]

        EComment idx comment ->
            case model.mode of
                Slides ->
                    Effects.comment False model.silent ToggleSpeech model.effect_model (view_block model) idx [ Paragraph comment ]

                _ ->
                    Effects.comment True model.silent ToggleSpeech model.effect_model (view_block model) idx [ Paragraph comment ]

        Chart chart ->
            Lia.Chart.View.view chart


view_table : Model -> List (List Inline) -> Array String -> List (List (List Inline)) -> Html Msg
view_table model header format body =
    let
        view_row model_ f row =
            row
                |> List.indexedMap (,)
                |> List.map
                    (\( i, col ) ->
                        f
                            [ Attr.align
                                (case Array.get i format of
                                    Just a ->
                                        a

                                    Nothing ->
                                        "left"
                                )
                            ]
                            (col
                                |> List.map (\element -> Elem.view model_.effect_model.visible element)
                            )
                    )
    in
    Html.table
        [ Attr.class "lia-inline lia-table" ]
        (Html.thead
            [ Attr.class "lia-inline lia-table-head"
            ]
            (view_row model Html.th header)
            :: List.map
                (\r ->
                    Html.tr [ Attr.class "lia-inline lia-table-row" ]
                        (view_row model Html.td r)
                )
                body
        )



-- SUBSCRIPTIONS
-- HTTP
