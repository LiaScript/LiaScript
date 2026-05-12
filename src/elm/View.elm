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
            --  Running ->
            --      [ model.lia
            --          |> Lia.Script.view
            --              model.session.screen
            --              model.hasIndex
            --          |> Html.map LiaScript
            --      ]
            Idle ->
                [ Html.map UpdateIndex <| Index.view model.session model.lia.settings model.index
                ]

            Loading ->
                loading model.log

            Loading_Zip ->
                loading model.log

            --Parsing _ _ ->
            _ ->
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
                , showLogs model.log
                ]

    --Error _ ->
    --    [ model.lia
    --        |> Lia.Script.view
    --            model.session.screen
    --            model.hasIndex
    --        |> Html.map LiaScript
    --    ]
    --_ ->
    --    loading model.log
    }


base_div : List (Html msg) -> Html msg
base_div =
    Html.div
        [ Attr.style "width" "100%"
        , Attr.style "text-align" "center"
        , Attr.style "top" "25%"
        , Attr.style "position" "absolute"
        , Attr.class "notranslate"
        , Attr.attribute "translate" "no"
        ]


loading : List ( String, Maybe Bool, Maybe String ) -> List (Html msg)
loading logs =
    [ base_div
        [ Html.h1 [] [ Html.text "Loading" ]
        , Html.br [] []
        , Html.div [ Attr.class "lds-dual-ring" ] []
        ]
    , showLogs logs
    ]


showLogs : List ( String, Maybe Bool, Maybe String ) -> Html msg
showLogs logs =
    logs
        |> List.map showLog
        |> Html.div
            [ Attr.style "position" "fixed"
            , Attr.style "bottom" "2em"
            , Attr.style "left" "50%"
            , Attr.style "transform" "translateX(-50%)"
            , Attr.style "background" "rgba(255,255,255,0.72)"
            , Attr.style "backdrop-filter" "blur(8px)"
            , Attr.style "-webkit-backdrop-filter" "blur(8px)"
            , Attr.style "border" "none"
            , Attr.style "border-radius" "10px"
            , Attr.style "box-shadow" "0 4px 24px rgba(0,0,0,0.10), 0 1px 4px rgba(0,0,0,0.07)"
            , Attr.style "font-family" "monospace"
            , Attr.style "font-size" "0.85em"
            , Attr.style "width" "500px"
            , Attr.style "max-height" "40vh"
            , Attr.style "overflow-y" "auto"
            , Attr.style "text-align" "left"
            , Attr.style "overflow-x" "hidden"
            ]


showLog : ( String, Maybe Bool, Maybe String ) -> Html msg
showLog ( url, state, error ) =
    let
        ( stateLabel, badgeColor ) =
            case state of
                Nothing ->
                    ( "pending", "#666" )

                Just True ->
                    ( "done", "#2a9d2a" )

                Just False ->
                    ( "failed", "#c0392b" )

        rowBg =
            case state of
                Just False ->
                    "rgba(220,53,69,0.07)"

                _ ->
                    "transparent"

        errorRow =
            case error of
                Just msg ->
                    [ Html.div
                        [ Attr.style "color" "#e74c3c"
                        , Attr.style "font-size" "0.9em"
                        , Attr.style "margin-top" "2px"
                        ]
                        [ Html.text msg ]
                    ]

                Nothing ->
                    []
    in
    Html.div
        [ Attr.style "background" rowBg
        , Attr.style "border-bottom" "1px solid rgba(0,0,0,0.06)"
        ]
        [ Html.div
            [ Attr.style "display" "flex"
            , Attr.style "justify-content" "space-between"
            , Attr.style "align-items" "flex-start"
            , Attr.style "padding" "5px 12px"
            , Attr.style "color" "#555"
            ]
            [ Html.span
                [ Attr.style "color" "#aaa"
                , Attr.style "min-width" "5em"
                , Attr.style "padding-top" "1px"
                ]
                [ Html.text "loading" ]
            , Html.div
                [ Attr.style "flex" "1"
                , Attr.style "padding" "0 1em"
                , Attr.style "overflow" "hidden"
                ]
                (Html.span
                    [ Attr.style "display" "block"
                    , Attr.style "color" "#555"
                    , Attr.style "overflow" "hidden"
                    , Attr.style "text-overflow" "ellipsis"
                    , Attr.style "white-space" "nowrap"
                    ]
                    [ Html.text (shortUrl url) ]
                    :: errorRow
                )
            , Html.span
                [ Attr.style "background" badgeColor
                , Attr.style "color" "#fff"
                , Attr.style "border-radius" "4px"
                , Attr.style "padding" "1px 8px"
                , Attr.style "font-size" "0.85em"
                , Attr.style "min-width" "4.5em"
                , Attr.style "text-align" "center"
                ]
                [ Html.text stateLabel ]
            ]
        ]


shortUrl : String -> String
shortUrl url =
    if String.length url > 40 then
        String.slice 0 15 url
            ++ "..."
            ++ String.dropLeft (String.length url - 22) url

    else
        url
