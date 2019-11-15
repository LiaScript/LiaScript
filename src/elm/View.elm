module View exposing (view)

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia.Script
import Model exposing (Model, State(..))
import Update exposing (Msg(..))


project_url : String
project_url =
    "https://github.com/LiaScript/LiaScript"


view : Model -> Browser.Document Msg
view model =
    { title = model.lia.title
    , body =
        case model.state of
            Running ->
                [ Html.map LiaScript <| Lia.Script.view model.lia ]

            Idle ->
                [ view_idle model.lia.readme ]

            Loading ->
                [ base_div
                    [ Html.h1 [] [ Html.text "Loading" ]
                    , Html.br [] []
                    , Html.div [ Attr.class "lds-dual-ring" ] []
                    ]
                ]

            Parsing _ _ ->
                let
                    percent =
                        model.code
                            |> Maybe.withDefault ""
                            |> String.length
                            |> toFloat
                in
                [ base_div
                    [ -- Html.h1 [] [ Html.text ("Parsing - " ++ (String.fromInt <| Array.length model.lia.sections)) ]
                      Html.h1 [] [ Html.text ("Parsing : " ++ (String.slice 0 5 <| String.fromFloat (100 - (percent / model.size * 100))) ++ "%") ]
                    , Html.br [] []
                    , Html.div [ Attr.class "lds-dual-ring" ] []
                    ]
                ]

            Error info ->
                [ base_div
                    [ Html.h1 [] [ Html.text "Load failed" ]
                    , Html.h6 [] [ Html.text model.lia.readme ]
                    , Html.p
                        [ Attr.style "margin-left" "20%"
                        , Attr.style "margin-right" "20%"
                        ]
                        [ Html.text info ]
                    ]
                ]
    }


view_idle : String -> Html Msg
view_idle url =
    base_div
        [ Html.h1 [] [ Html.text "Lia" ]
        , Html.br [] []
        , Html.br [] []
        , Html.input [ Attr.placeholder "enter course URL", Attr.value url, onInput Input ] []
        , Html.button [ Attr.class "lia-btn", onClick Load ] [ Html.text "load URL" ]
        , Html.br [] []
        , Html.br [] []
        , Html.br [] []
        , Html.a [ Attr.href project_url ] [ Html.text project_url ]
        ]


viewLink : String -> Html msg
viewLink path =
    Html.li [] [ Html.a [ Attr.href path ] [ Html.text path ] ]


base_div : List (Html msg) -> Html msg
base_div =
    Html.div
        [ Attr.style "width" "100%"
        , Attr.style "text-align" "center"
        , Attr.style "top" "25%"
        , Attr.style "position" "absolute"
        ]
