module Lia.View exposing (view)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Html.Lazy exposing (lazy2)
import Lia.Effect.Model as Effect
import Lia.Effect.View as Effects
import Lia.Helper exposing (..)
import Lia.Index.View
import Lia.Inline.Type exposing (Inline)
import Lia.Inline.View as Elem
import Lia.Model exposing (Model)
import Lia.Quiz.View
import Lia.Type exposing (..)
import Lia.Update exposing (Msg(..))
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
            view_slide { model | effects = Effect.Model 999 999 }
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
                    [ case get_slide model.current_slide model.slides of
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
                          , if model.current_slide == n then
                                "#33f"
                            else
                                "#333"
                          )
                        ]
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


view_block : Model -> Block -> Html Msg
view_block model block =
    case block of
        Paragraph elements ->
            Html.p [] (List.map (\e -> Elem.view model.effects.visible e) elements)

        HorizontalLine ->
            Html.hr [] []

        Table header format body ->
            view_table model header (Array.fromList format) body

        Quote elements ->
            Html.blockquote [] (List.map (\e -> Elem.view model.effects.visible e) elements)

        CodeBlock language code ->
            Html.pre [] [ Html.code [] [ Lia.Utils.highlight language code ] ]

        Quiz quiz ->
            Html.map UpdateQuiz <| Lia.Quiz.View.view model.quiz quiz

        EBlock idx sub_blocks ->
            Effects.view_block model.effects (view_block model) idx sub_blocks


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
                                |> List.map (\element -> Elem.view model.effects.visible element)
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
