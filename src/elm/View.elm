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
                        model.hasIndex
                    |> Html.map LiaScript
                ]

            Idle ->
                [ Html.map UpdateIndex <| Index.view model.session model.lia.settings model.index
                ]

            Loading ->
                loading

            Loading_Zip ->
                loading

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

                    --, Html.div [ Attr.class "lds-dual-ring" ] []
                    , Html.progress [ Attr.style "width" "70%", Attr.max "100", Attr.value (String.slice 0 5 <| String.fromFloat (100 - (percent / model.size * 100))) ] []
                    ]
                ]

            Error _ ->
                [ model.lia
                    |> Lia.Script.view
                        model.session.screen
                        model.hasIndex
                    |> Html.map LiaScript
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


loading : List (Html msg)
loading =
    [ base_div
        [ Html.h1 [] [ Html.text "Loading" ]
        , Html.br [] []
        , Html.div [ Attr.class "lds-dual-ring" ] []
        ]
    ]
