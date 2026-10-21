module View exposing (view)

import Browser
import Const
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Index.View as Index
import Lia.Script
import Model exposing (Log, Model, State(..))
import Update exposing (Msg(..))
import Url


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
                course (blocking model.log) model :: overlay model

            Idle ->
                [ Html.map UpdateIndex <| Index.view model.session model.lia.settings model.index
                ]

            Loading ->
                loading model.log

            Loading_Zip ->
                loading model.log

            Parsing _ _ ->
                parsing model

            Error _ ->
                [ course False model ]
    }


{-| While the loading screen is on top, the course below cannot be reached by
keyboard or screen readers.
-}
course : Bool -> Model -> Html Msg
course blocked model =
    model.lia
        |> Lia.Script.view
            model.session.screen
            model.hasIndex
        |> Html.map LiaScript
        |> List.singleton
        |> Html.div
            (if blocked then
                [ Attr.attribute "inert" ""
                , Attr.attribute "aria-hidden" "true"
                ]

             else
                []
            )


{-| The loading screen stays on top, as long as files are loaded or some failed.
-}
blocking : List Log -> Bool
blocking =
    List.any (.ok >> (/=) (Just True))


{-| The loading screen stays on top of the course until all templates, scripts
and styles are loaded. If some failed, the user gets warned and can proceed
anyway. The course has to be rendered below, otherwise its scripts and styles
are not loaded (`InitSection`).
-}
overlay : Model -> List (Html Msg)
overlay model =
    let
        pending =
            List.any (.ok >> (==) Nothing) model.log
    in
    if blocking model.log then
        [ Html.div
            [ Attr.attribute "role"
                (if pending then
                    "dialog"

                 else
                    "alertdialog"
                )
            , Attr.attribute "aria-modal" "true"
            , Attr.attribute "aria-labelledby" "lia-loading-title"
            , Attr.attribute "aria-describedby" "lia-loading-text"
            , Attr.style "position" "fixed"
            , Attr.style "top" "0"
            , Attr.style "right" "0"
            , Attr.style "bottom" "0"
            , Attr.style "left" "0"
            , Attr.style "overflow-y" "auto"
            , Attr.style "z-index" "100000"
            , Attr.style "background" "white"
            ]
            (if pending then
                loading model.log

             else
                warning model.log
            )
        ]

    else
        []


warning : List Log -> List (Html Msg)
warning logs =
    screen
        [ title "Warning"
        , Html.p [ Attr.id "lia-loading-text" ]
            [ Html.text "Some resources could not be loaded, parts of this course might not work as expected." ]
        , Html.button
            [ Attr.class "lia-btn"
            , Attr.id "lia-proceed"
            , Events.onClick Proceed
            ]
            [ Html.text "Proceed" ]
        ]
        logs


parsing : Model -> List (Html msg)
parsing model =
    let
        percent =
            model.code
                |> Maybe.withDefault ""
                |> String.length
                |> toFloat
    in
    screen
        [ -- Html.h1 [] [ Html.text ("Parsing - " ++ (String.fromInt <| Array.length model.lia.sections)) ]
          title ("Parsing : " ++ (String.slice 0 5 <| String.fromFloat (100 - (percent / model.size * 100))) ++ "%")
        , status model.log

        --, Html.div [ Attr.class "lds-dual-ring" ] []
        , Html.progress [ Attr.attribute "aria-label" "Parsing", Attr.style "width" "70%", Attr.max "100", Attr.value (String.slice 0 5 <| String.fromFloat (100 - (percent / model.size * 100))) ] []
        ]
        model.log


{-| The header (title, spinner, ...) above the list of loaded files. The list
scrolls if it gets too long, the whole screen on small displays.
-}
screen : List (Html msg) -> List Log -> List (Html msg)
screen header logs =
    [ Html.main_
        [ Attr.style "display" "flex"
        , Attr.style "flex-direction" "column"
        , Attr.style "align-items" "center"
        , Attr.style "justify-content" "center"
        , Attr.style "min-height" "100vh"
        , Attr.style "box-sizing" "border-box"
        , Attr.style "padding" "1em"
        , Attr.style "text-align" "center"
        , Attr.class "notranslate"
        , Attr.attribute "translate" "no"

        -- the texts are not translated
        , Attr.lang "en"
        ]
        (Html.div [ Attr.style "width" "100%" ] header :: showLogs logs)
    ]


title : String -> Html msg
title text =
    Html.h1 [ Attr.id "lia-loading-title" ] [ Html.text text ]


loading : List Log -> List (Html msg)
loading logs =
    screen
        [ title "Loading"
        , status logs
        , Html.div [ Attr.class "lds-dual-ring", Attr.attribute "aria-hidden" "true" ] []
        ]
        logs


{-| Explains what is currently loaded, based on the files that are not finished
yet.
-}
status : List Log -> Html msg
status logs =
    let
        pending kinds =
            List.any (\log -> log.ok == Nothing && List.member log.kind kinds) logs

        progress kinds =
            let
                all =
                    List.filter (.kind >> (\kind -> List.member kind kinds)) logs
            in
            String.fromInt (List.length (List.filter (.ok >> (/=) Nothing) all))
                ++ " of "
                ++ String.fromInt (List.length all)
    in
    Html.p [ Attr.id "lia-loading-text", Attr.attribute "aria-live" "polite" ]
        [ Html.text <|
            if pending [ "readme" ] then
                "Downloading the course …"

            else if List.any (\log -> log.ok == Nothing && String.startsWith Const.urlProxy log.url) logs then
                "Some files could not be downloaded directly, retrying via a proxy, this may take a while …"

            else if pending [ "template" ] then
                "Loading templates, they add macros and functionality to this course ("
                    ++ progress [ "template" ]
                    ++ ") …"

            else if pending [ "js", "css" ] then
                "Loading scripts and styles required by this course ("
                    ++ progress [ "js", "css" ]
                    ++ ") …"

            else
                "Preparing the course …"
        ]


showLogs : List Log -> List (Html msg)
showLogs logs =
    if List.isEmpty logs then
        []

    else
        [ logs
            |> List.map showLog
            |> Html.ul
                [ Attr.attribute "aria-label" "Files"

                -- the list scrolls, which has to work with the keyboard too
                , Attr.tabindex 0
                , Attr.style "list-style" "none"
                , Attr.style "margin" "2em 0 0 0"
                , Attr.style "padding" "0"
                , Attr.style "width" "100%"
                , Attr.style "max-width" "500px"
                , Attr.style "box-sizing" "border-box"
                , Attr.style "background" "rgba(255,255,255,0.72)"
                , Attr.style "border-radius" "10px"
                , Attr.style "box-shadow" "0 4px 24px rgba(0,0,0,0.10), 0 1px 4px rgba(0,0,0,0.07)"
                , Attr.style "font-family" "monospace"
                , Attr.style "font-size" "0.85em"
                , Attr.style "max-height" "40vh"
                , Attr.style "overflow-y" "auto"
                , Attr.style "overflow-x" "hidden"
                , Attr.style "text-align" "left"
                ]
        ]


showLog : Log -> Html msg
showLog { kind, url, ok } =
    let
        ( file, host ) =
            splitUrl url

        ( stateLabel, badgeColor ) =
            case ok of
                Nothing ->
                    ( "pending", "#666" )

                Just True ->
                    ( "done", "#1e7b1e" )

                Just False ->
                    ( "failed", "#c0392b" )

        rowBg =
            case ok of
                Just False ->
                    "rgba(220,53,69,0.07)"

                _ ->
                    "transparent"
    in
    Html.li
        [ Attr.style "background" rowBg
        , Attr.style "border-bottom" "1px solid rgba(0,0,0,0.06)"
        ]
        [ Html.div
            [ Attr.style "display" "flex"
            , Attr.style "align-items" "center"
            , Attr.style "padding" "5px 12px"
            , Attr.style "color" "#555"
            ]
            [ Html.div
                [ Attr.style "flex" "1"
                , Attr.style "min-width" "0"
                , Attr.style "padding-right" "0.5em"
                ]
                [ Html.span
                    [ Attr.style "display" "block"
                    , Attr.style "color" "#6b6b6b"
                    , Attr.style "font-size" "0.8em"
                    , Attr.style "overflow" "hidden"
                    , Attr.style "text-overflow" "ellipsis"
                    , Attr.style "white-space" "nowrap"
                    ]
                    [ Html.text kind
                    , Html.span [ Attr.attribute "aria-hidden" "true" ] [ Html.text " · " ]
                    , Html.text host
                    ]
                , Html.span
                    [ Attr.style "display" "block"
                    , Attr.title url
                    , Attr.style "color" "#555"
                    , Attr.style "overflow" "hidden"
                    , Attr.style "text-overflow" "ellipsis"
                    , Attr.style "white-space" "nowrap"
                    ]
                    [ Html.text file ]
                ]
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


{-| The file name and the host of an url, the full url is shown as a title.

    splitUrl "https://x.org/a/b.js?v=1" == ( "b.js", "x.org" )

-}
splitUrl : String -> ( String, String )
splitUrl url =
    if String.startsWith Const.urlProxy url then
        ( url |> String.dropLeft (String.length Const.urlProxy) |> splitUrl |> Tuple.first
        , "via proxy"
        )

    else
        case Url.fromString url of
            Just { host, port_, path } ->
                ( path
                    |> String.split "/"
                    |> List.filter ((/=) "")
                    |> List.reverse
                    |> List.head
                    |> Maybe.withDefault host
                , port_
                    |> Maybe.map (String.fromInt >> (++) (host ++ ":"))
                    |> Maybe.withDefault host
                )

            Nothing ->
                ( url, "" )
