module LiaHtml exposing (Msg, activated, book, plain)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia exposing (E(..), Slide)


type Msg
    = Load Int


plain : List Slide -> Html Msg
plain slides =
    Html.div [] (List.map view_slide slides)


book : List Slide -> Int -> Html Msg
book slides active =
    Html.div []
        [ Html.div
            [ Attr.style
                [ ( "width", "15%" )
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
                [ ( "width", "85%" )
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


view_body : List E -> List (Html Msg)
view_body body =
    List.map view_element body


view_element : E -> Html Msg
view_element string =
    case string of
        Paragraph elems ->
            Html.p [] (List.map view_element elems)

        CodeBlock lang_ code_ ->
            Html.pre [] [ Html.code [] [ Html.text code_ ] ]

        Code str ->
            Html.pre [] [ Html.text str ]

        Base str ->
            Html.text str

        Line ->
            Html.hr [] []

        Bold lia ->
            Html.b [] [ view_element lia ]

        Italic lia ->
            Html.em [] [ view_element lia ]

        Underline lia ->
            Html.u [] [ view_element lia ]

        Link text_ url_ ->
            Html.a [ Attr.href url_ ] [ Html.text text_ ]

        Quote elems ->
            Html.blockquote [] (List.map view_element elems)

        Image alt_ url_ ->
            Html.img [ Attr.src url_ ] [ Html.text alt_ ]

        Movie alt_ url_ ->
            Html.iframe [ Attr.src url_ ] [ Html.text alt_ ]



--        Lia cmd params ->
--            text (cmd ++ " : " ++ toString params)
-- SUBSCRIPTIONS
-- HTTP
