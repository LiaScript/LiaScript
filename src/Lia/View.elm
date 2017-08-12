module Lia.View exposing (view)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Html.Lazy exposing (lazy)
import Json.Encode
import Lia.Helper exposing (..)
import Lia.Type exposing (..)
import Lia.Utils


view : Mode -> List Slide -> Int -> Html Msg
view mode slides num =
    case mode of
        Slides ->
            view_slides slides num

        Plain ->
            view_plain slides


view_plain : List Slide -> Html Msg
view_plain slides =
    Html.div
        [ Attr.style [ ( "width", "100%" ) ]
        ]
        (List.map view_slide slides)


view_slides : List Slide -> Int -> Html Msg
view_slides slides active =
    Html.div []
        [ Html.div
            [ Attr.style
                [ ( "width", "200px" )
                , ( "float", "left" )
                ]
            ]
            ((slides
                |> get_headers
                |> List.map
                    (\( n, ( h, i ) ) ->
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
                                    ]
                                ]
                                [ Html.text h ]
                            ]
                    )
             )
                ++ [ Html.button
                        [ onClick (Load (active - 1))
                        , Attr.style [ ( "width", "100px" ) ]
                        ]
                        [ Html.text "<<" ]
                   , Html.button
                        [ onClick (Load (active + 1))
                        , Attr.style [ ( "width", "40%" ) ]
                        ]
                        [ Html.text ">>" ]
                   ]
            )
        , Html.div
            [ Attr.style
                [ ( "width", "calc(100% - 200px)" )
                , ( "float", "right" )
                ]
            ]
            [ case get_slide active slides of
                Just slide ->
                    lazy view_slide slide

                Nothing ->
                    Html.text ""
            ]
        ]



--activated : Msg -> Int
--activated msg =
--    case msg of
--        Load active ->
--            active


view_slide : Slide -> Html Msg
view_slide slide =
    Html.div []
        (view_header slide.indentation slide.title
            :: view_body slide.body
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


view_body : List Block -> List (Html Msg)
view_body body =
    List.map view_block body


view_block : Block -> Html Msg
view_block block =
    case block of
        Paragraph elements ->
            Html.p [] (List.map view_inline elements)

        HorizontalLine ->
            Html.hr [] []

        Table header format body ->
            view_table header (Array.fromList format) body

        Quote elements ->
            Html.blockquote [] (List.map view_inline elements)

        CodeBlock language code ->
            Html.pre [] [ Html.code [] [ Lia.Utils.highlight language code ] ]


view_table : List (List Inline) -> Array String -> List (List (List Inline)) -> Html Msg
view_table header format body =
    let
        style_ =
            Attr.style
                [ ( "border-style", "solid" )
                , ( "border-color", "#e0e0eb" )
                , ( "border-width", "1px" )
                ]

        view_row =
            \f row ->
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
                                    |> List.map (\element -> view_inline element)
                                )
                        )
    in
    Html.table
        [ Attr.attribute "cellspacing" "0"
        , Attr.attribute "cellpadding" "8"
        , style_
        ]
        (Html.thead []
            (view_row Html.th header)
            :: List.map
                (\r ->
                    Html.tr []
                        (view_row Html.td r)
                )
                body
        )


view_inline : Inline -> Html Msg
view_inline element =
    case element of
        Code e ->
            Html.code [] [ Html.text e ]

        Chars e ->
            Html.text e

        Symbol e ->
            Html.text e

        Bold e ->
            Html.b [] [ view_inline e ]

        Italic e ->
            Html.em [] [ view_inline e ]

        Underline e ->
            Html.u [] [ view_inline e ]

        Superscript e ->
            Html.sup [] [ view_inline e ]

        Ref e ->
            view_reference e

        HTML e ->
            Html.span [ Attr.property "innerHTML" (Json.Encode.string e) ] []

        Formula mode e ->
            Lia.Utils.formula mode e



--Html.div [ Attr.property "innerHTML" (Json.Encode.string ("<script type=\"math/text\">" ++ e ++ "</script>")) ] []


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
