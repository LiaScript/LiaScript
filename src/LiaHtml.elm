module LiaHtml exposing (Msg, activated, book, plain)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia exposing (Block(..), Inline(..), Reference(..), Slide)


type Msg
    = Load Int


plain : List Slide -> Html Msg
plain slides =
    Html.div
        [ Attr.style [ ( "width", "100%" ) ]
        ]
        (List.map view_slide slides)


book : List Slide -> Int -> Html Msg
book slides active =
    Html.div []
        [ Html.div
            [ Attr.style
                [ ( "width", "200px" )
                , ( "float", "left" )
                ]
            ]
            ((slides
                |> Lia.get_headers
                |> List.map
                    (\( n, ( h, i ) ) ->
                        Html.div [ onClick (Load n) ]
                            [ Html.a [] [ Html.text (String.repeat i "-" ++ h) ] ]
                    )
             )
                ++ [ Html.button [ onClick (Load (active - 1)) ] [ Html.text "<<" ]
                   , Html.button [ onClick (Load (active + 1)) ] [ Html.text ">>" ]
                   ]
            )
        , Html.div
            [ Attr.style
                [ ( "width", "calc(100% - 200px)" )
                , ( "float", "right" )
                ]
            ]
            [ case Lia.get_slide active slides of
                Just slide ->
                    view_slide slide

                Nothing ->
                    Html.text ""
            ]
        ]


activated : Msg -> Int
activated msg =
    case msg of
        Load active ->
            active


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
            Html.pre [] [ Html.code [] [ Html.text code ] ]


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
            Html.pre [] [ Html.text e ]

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

        Ref e ->
            view_reference e


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
