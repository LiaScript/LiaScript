module Lia.View exposing (view)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Html.Lazy exposing (lazy2)
import Lia.Code.View as Codes
import Lia.Effect.Model as Effect
import Lia.Effect.View as Effects
import Lia.Helper exposing (..)
import Lia.Index.View
import Lia.Inline.Types exposing (Inline)
import Lia.Inline.View as Elem
import Lia.Model exposing (Model)
import Lia.Quiz.View
import Lia.Types exposing (..)
import Lia.Update exposing (Msg(..))


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
            view_slide { model | effect_model = Effect.init_silent }
    in
    Html.div
        [ Attr.style
            [ ( "width", "100%" )
            , ( "overflow", "auto" )
            , ( "height", "100%" )
            ]
        ]
        (List.map f model.slides)


view_slides : Model -> Html Msg
view_slides model =
    let
        loadButton str msg =
            Html.button
                [ onClick msg
                , Attr.class "button_slide"
                ]
                [ Html.text str ]

        content =
            Html.div []
                [ Html.div []
                    [ Html.button
                        [ onClick ToggleContentsTable
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
                    [ case get_slide model.current_slide model.slides of
                        Just slide ->
                            lazy2 view_slide model slide

                        Nothing ->
                            Html.text ""
                    ]
                ]
    in
    Html.div [ Attr.class "screen" ]
        (if model.contents then
            [ Html.div [ Attr.class "table_of_contents" ] [ view_contents model ]
            , content
            ]
         else
            [ content ]
        )


view_contents : Model -> Html Msg
view_contents model =
    let
        f ( n, ( h, i ) ) =
            Html.div []
                [ Html.a
                    [ onClick (Load n)
                    , Attr.class
                        ("toc"
                            ++ toString i
                            ++ (if model.current_slide == n then
                                    " active"
                                else
                                    ""
                               )
                        )
                    , h
                        |> String.split " "
                        |> String.join "_"
                        |> String.append "#"
                        |> Attr.href

                    --Attr.style
                    --  [ ( "padding-left"
                    --    , toString ((i - 1) * 20) ++ "px"
                    --    )
                    --  , ( "color"
                    --    , if model.current_slide == n then
                    --          "#33f"
                    --      else
                    --          "#333"
                    --    )
                    --  ]
                    ]
                    [ Html.text h ]
                ]
    in
    model.slides
        |> get_headers
        |> (\list ->
                case model.index.results of
                    Nothing ->
                        list

                    Just index ->
                        list |> List.filter (\( l, x ) -> List.member l index)
           )
        |> List.map f
        |> (\h ->
                Html.div []
                    (List.append
                        [ Html.map UpdateIndex <| Lia.Index.View.view model.index ]
                        h
                    )
           )


view_slide : Model -> Slide -> Html Msg
view_slide model slide =
    Html.div []
        --Attr.class "lia", Attr.class "section" ]
        (view_header slide.indentation slide.title
            :: view_body model slide.body
        )


view_header : Int -> String -> Html Msg
view_header indentation title =
    let
        html_title =
            [ Html.text title ]
    in
    case indentation of
        0 ->
            Html.h1 [] html_title

        1 ->
            Html.h2 [] html_title

        2 ->
            Html.h3 [] html_title

        3 ->
            Html.h4 [] html_title

        4 ->
            Html.h5 [] html_title

        _ ->
            Html.h6 [] html_title


view_body : Model -> List Block -> List (Html Msg)
view_body model body =
    let
        f =
            view_block model
    in
    List.map f body


view_block : Model -> Block -> Html Msg
view_block model block =
    case block of
        Paragraph elements ->
            Html.p [] (List.map (\e -> Elem.view model.effect_model.visible e) elements)

        HLine ->
            Html.hr [] []

        Table header format body ->
            view_table model header (Array.fromList format) body

        Quote elements ->
            Html.blockquote [] (List.map (\e -> Elem.view model.effect_model.visible e) elements)

        CodeBlock code ->
            Html.map UpdateCode <| Codes.view model.code_model code

        Quiz quiz ->
            Html.map UpdateQuiz <| Lia.Quiz.View.view model.quiz_model quiz

        EBlock idx effect_name sub_blocks ->
            Effects.view_block model.effect_model (view_block model) idx effect_name sub_blocks

        BulletList list ->
            Html.ul []
                (List.map
                    (\l -> Html.li [] (List.map (\ll -> view_block model ll) l))
                    list
                )

        OrderedList list ->
            Html.ol []
                (List.map
                    (\l -> Html.li [] (List.map (\ll -> view_block model ll) l))
                    list
                )

        EComment idx comment ->
            Effects.comment model.effect_model (view_block model) idx [ Paragraph comment ]


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
                                |> List.map (\element -> Elem.view model.effect_model.visible element)
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



-- SUBSCRIPTIONS
-- HTTP
