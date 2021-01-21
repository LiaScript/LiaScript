module View exposing (view)

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Index.View as Index
import Lia.Script
import Model exposing (Model, State(..))
import Update exposing (Msg(..))


{-| The current view is defined by the current state of the App. See
`src/elm/Model.elm` for more information about states.

> `Running` means that a course has been parsed and rendered, that is now in
> total control of the view.

-}
view : Model -> Browser.Document Msg
view model =
    { title = model.lia.title
    , body =
        case model.state of
            Running ->
                [ model.lia
                    |> Lia.Script.view
                        model.session.screen
                        model.session.share
                        model.hasIndex
                    |> Html.map LiaScript
                ]

            Idle ->
                [ Html.map UpdateIndex <| Index.view model.session model.index
                ]

            Loading ->
                [ base_div
                    [ Html.h1 [] [ Html.text "Loading" ]
                    , Html.br [] []
                    , Html.div [ Attr.class "lds-dual-ring" ] []
                    ]
                ]

            Parsing _ _ ->
                if model.parse_steps == 1 then
                    [ model.lia_
                        |> Lia.Script.view
                            model.session.screen
                            model.session.share
                            model.hasIndex
                        |> Html.map LiaScript
                    ]

                else
                    let
                        percent =
                            model.code
                                |> Maybe.map Tuple.first
                                |> Maybe.withDefault ""
                                |> String.length
                                |> toFloat
                    in
                    [ base_div
                        [ -- Html.h1 [] [ Html.text ("Parsing - " ++ (String.fromInt <| Array.length model.lia.sections)) ]
                          Html.h1 [] [ Html.text ("Parsing : " ++ (String.slice 0 5 <| String.fromFloat (100 - (percent / model.size * 100))) ++ "%") ]
                        , Html.br [] []

                        --, Html.div [ Attr.class "lds-dual-ring" ] []
                        , Html.progress [ Attr.style "width" "70%", Attr.max "100", Attr.value (String.slice 0 5 <| String.fromFloat (100 - (percent / model.size * 100))) ] []
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


base_div : List (Html msg) -> Html msg
base_div =
    Html.div
        [ Attr.style "width" "100%"
        , Attr.style "text-align" "center"
        , Attr.style "top" "25%"
        , Attr.style "position" "absolute"
        ]
