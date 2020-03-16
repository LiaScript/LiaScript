module Lia.Markdown.View exposing (view)

import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy2)
import Lia.Markdown.Chart.View as Charts
import Lia.Markdown.Code.View as Codes
import Lia.Markdown.Effect.Model as Comments
import Lia.Markdown.Footnote.Model as Footnotes
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines, MultInlines, htmlBlock, isHTML)
import Lia.Markdown.Inline.View exposing (annotation, attributes, viewer)
import Lia.Markdown.Quiz.View as Quizzes
import Lia.Markdown.Survey.View as Surveys
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Section exposing (Section)
import Lia.Settings.Model exposing (Mode(..))
import Session exposing (Screen)
import SvgBob
import Translations exposing (Lang)


type alias Config =
    { mode : Mode
    , view : Inlines -> List (Html Msg)
    , section : Section
    , ace_theme : String
    , lang : Lang
    , light : Bool
    , screen : Screen
    }


view : Lang -> Mode -> Section -> String -> Bool -> Screen -> Html Msg
view lang mode section ace_theme light screen =
    let
        config =
            Config mode
                (viewer mode <|
                    if mode == Textbook then
                        9999

                    else
                        section.effect_model.visible
                )
                section
                ace_theme
                lang
                light
                screen
    in
    case section.error of
        Just msg ->
            Html.section [ Attr.class "lia-content" ]
                [ view_header config
                , Html.text msg
                ]

        Nothing ->
            lazy2 view_body ( config, section.footnote2show, section.footnotes ) section.body


view_body : ( Config, Maybe String, Footnotes.Model ) -> List Markdown -> Html Msg
view_body ( config, footnote2show, footnotes ) body =
    body
        |> List.map (view_block config)
        |> (::) (view_footnote (view_block config) footnote2show footnotes)
        |> (::) (view_header config)
        |> (\s ->
                if config.mode == Textbook then
                    List.append s [ Footnote.block (view_block config) footnotes ]

                else
                    s
           )
        |> Html.section [ Attr.class "lia-content" ]


view_footnote : (Markdown -> Html Msg) -> Maybe String -> Footnotes.Model -> Html Msg
view_footnote viewer key footnotes =
    case Maybe.andThen (Footnotes.getNote footnotes) key of
        Just notes ->
            Html.div
                [ onClick FootnoteHide
                , Attr.style "position" "fixed"
                , Attr.style "display" "block"
                , Attr.style "width" "100%"
                , Attr.style "height" "100%"
                , Attr.style "top" "0"
                , Attr.style "left" "0"
                , Attr.style "right" "0"
                , Attr.style "bottom" "0"
                , Attr.style "background-color" "rgba(0,0,0,0.6)"
                , Attr.style "z-index" "2"
                , Attr.style "cursor" "pointer"
                , Attr.style "overflow" "auto"
                ]
                [ Html.div
                    [ Attr.style "position" "absolute"
                    , Attr.style "top" "50%"
                    , Attr.style "left" "50%"
                    , Attr.style "font-size" "20px"
                    , Attr.style "color" "white"
                    , Attr.style "transform" "translate(-50%,-50%)"
                    , Attr.style "-ms-transform" "translate(-50%,-50%)"
                    ]
                    (List.map viewer notes)
                ]

        Nothing ->
            Html.text ""


view_header : Config -> Html Msg
view_header config =
    config.view config.section.title
        |> (case config.section.indentation of
                1 ->
                    Html.h1 [ Attr.class "lia-inline lia-h1" ]

                2 ->
                    Html.h2 [ Attr.class "lia-inline lia-h2" ]

                3 ->
                    Html.h3 [ Attr.class "lia-inline lia-h3" ]

                4 ->
                    Html.h4 [ Attr.class "lia-inline lia-h4" ]

                5 ->
                    Html.h5 [ Attr.class "lia-inline lia-h5" ]

                _ ->
                    Html.h6 [ Attr.class "lia-inline lia-h6" ]
           )
        |> List.singleton
        |> Html.header []


view_block : Config -> Markdown -> Html Msg
view_block config block =
    case block of
        HLine attr ->
            Html.hr (annotation "lia-horiz-line" attr) []

        Paragraph attr [ element ] ->
            case htmlBlock element of
                Just ( name, attributes, inlines ) ->
                    HTML.view
                        (config.view
                            >> List.head
                            >> Maybe.withDefault
                                (Html.p (annotation "lia-paragraph" attr) (config.view [ element ]))
                        )
                        attr
                        (Node name attributes [ inlines ])

                Nothing ->
                    Html.p (annotation "lia-paragraph" attr) (config.view [ element ])

        Paragraph attr elements ->
            Html.p (annotation "lia-paragraph" attr) (config.view elements)

        Effect attr ( id_in, id_out, sub_blocks ) ->
            if config.mode == Textbook then
                Html.div []
                    [ viewCircle id_in
                    , Html.div
                        (annotation "" Nothing)
                        (List.map (view_block config) sub_blocks)
                    ]

            else
                let
                    visible =
                        (id_in <= config.section.effect_model.visible)
                            && (id_out > config.section.effect_model.visible)
                in
                Html.div [ Attr.hidden (not visible) ]
                    [ viewCircle id_in
                    , Html.div
                        ((Attr.id <|
                            if id_in == config.section.effect_model.visible then
                                "focused"

                            else
                                String.fromInt id_in
                         )
                            :: annotation "lia-effect" attr
                        )
                        (List.map (view_block config) sub_blocks)
                    ]

        BulletList attr list ->
            list
                |> view_bulletlist config
                |> Html.ul (annotation "lia-list lia-unordered" attr)

        OrderedList attr list ->
            list
                |> view_list config
                |> Html.ol (annotation "lia-list lia-ordered" attr)

        Table attr header format body id ->
            config.section.table_vector
                |> Array.get id
                |> Maybe.withDefault ( -1, False )
                |> view_table config attr header format body id

        Quote attr elements ->
            elements
                |> List.map (\e -> view_block config e)
                |> Html.blockquote (annotation "lia-quote" attr)

        HTML attr node ->
            HTML.view (view_block config) attr node

        Code attr code ->
            code
                |> Codes.view config.lang config.ace_theme attr config.section.code_vector
                |> Html.map UpdateCode

        Quiz attr quiz Nothing ->
            Html.div (annotation "lia-quiz lia-card" attr)
                [ Quizzes.view config.mode config.lang quiz config.section.quiz_vector
                    |> Html.map UpdateQuiz
                ]

        Quiz attr quiz (Just ( answer, hidden_effects )) ->
            Html.div (annotation "lia-quiz lia-card" attr) <|
                case Quizzes.view_solution config.section.quiz_vector quiz of
                    ( empty, True ) ->
                        List.append
                            [ Html.map UpdateQuiz <| Quizzes.view config.mode config.lang quiz config.section.quiz_vector ]
                            ((if empty then
                                Html.text ""

                              else
                                Html.hr [] []
                             )
                                :: List.map (view_block config) answer
                            )

                    _ ->
                        [ Quizzes.view config.mode config.lang quiz config.section.quiz_vector
                            |> Html.map UpdateQuiz
                        ]

        Survey attr survey ->
            config.section.survey_vector
                |> Surveys.view config.mode config.lang attr survey
                |> Html.map UpdateSurvey

        Comment ( id1, id2 ) ->
            case
                ( config.mode
                , id1 == config.section.effect_model.visible
                , Comments.get_paragraph id1 id2 config.section.effect_model
                )
            of
                ( Textbook, _, Just ( attr, par ) ) ->
                    par
                        |> Paragraph attr
                        |> view_block config

                _ ->
                    Html.text ""

        Chart attr chart ->
            Charts.view attr config.screen.width chart

        ASCII attr txt ->
            txt
                |> SvgBob.init SvgBob.default
                |> SvgBob.getSvg (attributes attr)
                |> (\svg ->
                        if config.light then
                            svg

                        else
                            Html.div
                                [ Attr.style "-webkit-filter" "invert(100%)"
                                , Attr.style "filter" "invert(100%)"
                                ]
                                [ svg ]
                   )


viewCircle : Int -> Html msg
viewCircle id =
    Html.span [ Attr.class "lia-effect-circle" ] [ Html.text (String.fromInt id) ]


view_table : Config -> Annotation -> MultInlines -> List String -> List MultInlines -> Int -> ( Int, Bool ) -> Html Msg
view_table config attr header format body id ( column, dir ) =
    let
        str i list =
            if i == 0 then
                List.head list

            else
                List.tail list
                    |> Maybe.withDefault []
                    |> str (i - 1)

        sort =
            if column /= -1 then
                if dir then
                    List.sortBy (str column >> Maybe.map stringify >> Maybe.withDefault "")

                else
                    List.sortBy (str column >> Maybe.map stringify >> Maybe.withDefault "") >> List.reverse

            else
                identity

        view_row1 =
            List.map (config.view >> Html.td [ Attr.align "left" ])

        view_head1 =
            List.indexedMap
                (\i r ->
                    Html.td [ Attr.align "left" ]
                        [ Html.span [ Attr.style "float" "left" ] (config.view r)
                        , Html.div
                            [ Attr.class "lia-icon"
                            , Attr.style "float" "right"
                            , Attr.style "cursor" "pointer"
                            , Attr.style "margin-right" "-17px"
                            , onClick <| Sort id i
                            ]
                            [ Html.div
                                [ Attr.style "height" "6px"
                                , Attr.style "color" <|
                                    if column == i && dir then
                                        "red"

                                    else
                                        "gray"
                                ]
                                [ Html.text "arrow_drop_up" ]
                            , Html.div
                                [ Attr.style "height" "6px"
                                , Attr.style "color" <|
                                    if column == i && not dir then
                                        "red"

                                    else
                                        "gray"
                                ]
                                [ Html.text "arrow_drop_down" ]
                            ]
                        ]
                )

        view_row2 =
            List.map2
                (\f -> config.view >> Html.td [ Attr.align f ])
                format

        view_head2 =
            List.map2 Tuple.pair format
                >> List.indexedMap
                    (\i ( f, r ) ->
                        Html.th [ Attr.align f, Attr.style "height" "100%" ]
                            [ Html.span
                                (if f /= "right" then
                                    [ Attr.style "float" f, Attr.style "height" "100%" ]

                                 else
                                    [ Attr.style "height" "100%" ]
                                )
                                (config.view r)
                            , Html.span
                                [ Attr.class "lia-icon"
                                , Attr.style "float" "right"
                                , Attr.style "cursor" "pointer"
                                , Attr.style "margin-right" "-17px"
                                , Attr.style "margin-top" "-10px"

                                --  , Attr.style "height" "100%"
                                --  , Attr.style "position" "relative"
                                --  , Attr.style "vertical-align" "top"
                                , onClick <| Sort id i
                                ]
                                [ Html.div
                                    [ Attr.style "height" "6px"
                                    , Attr.style "color" <|
                                        if column == i && dir then
                                            "red"

                                        else
                                            "gray"
                                    ]
                                    [ Html.text "arrow_drop_up" ]
                                , Html.div
                                    [ Attr.style "height" "6px"
                                    , Attr.style "color" <|
                                        if column == i && not dir then
                                            "red"

                                        else
                                            "gray"
                                    ]
                                    [ Html.text "arrow_drop_down" ]
                                ]
                            ]
                    )
    in
    Html.table (annotation "lia-table" attr) <|
        if header == [] then
            case sort body of
                [] ->
                    []

                head :: tail ->
                    tail
                        |> List.map (view_row1 >> Html.tr [ Attr.class "lia-inline lia-table-row" ])
                        |> List.append
                            (head
                                |> view_head1
                                |> Html.tr [ Attr.class "lia-inline lia-table-row" ]
                                |> List.singleton
                            )

        else
            body
                |> sort
                |> List.map (view_row2 >> Html.tr [ Attr.class "lia-inline lia-table-row" ])
                |> List.append
                    [ header
                        |> view_head2
                        |> Html.thead [ Attr.class "lia-inline lia-table-head", Attr.style "height" "100%" ]
                    ]


view_list : Config -> List ( String, List Markdown ) -> List (Html Msg)
view_list config list =
    let
        viewer ( value, sub_list ) =
            List.map (view_block config) sub_list
                |> Html.li [ Attr.value value ]
    in
    list
        |> List.map viewer


view_bulletlist : Config -> List (List Markdown) -> List (Html Msg)
view_bulletlist config list =
    let
        viewer =
            List.map (view_block config)
                >> Html.li []
    in
    list
        |> List.map viewer
