module Index.View.Card exposing (card)

import Accessibility.Role exposing (definition)
import Array
import Const
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import I18n.Translations exposing (Lang(..))
import Index.Model exposing (Course, Modal(..), Release)
import Index.Update exposing (Msg(..))
import Index.View.Base as Base
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Log exposing (Level(..))
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View as Inline
import Lia.Utils exposing (btn, btnIcon)


card : Bool -> Course -> Html Msg
card hasShareAPI course =
    get_active course
        |> Maybe.map (article hasShareAPI course)
        |> Maybe.withDefault (Html.text "something went wrong")


article : Bool -> Course -> Release -> Html Msg
article hasShareAPI course { title, definition } =
    Html.article [ Attr.class "lia-card" ]
        [ versions course
        , definition.macro
            |> getIcon
            |> icon
        , logo definition.logo
        , Html.div [ Attr.class "lia-card__content" ]
            [ header title definition.macro
            , body definition.comment
            , controls hasShareAPI title definition course
            , footer definition.author
            ]
        ]


getIcon : Dict String String -> String
getIcon =
    Dict.get "icon"
        >> Maybe.withDefault Const.icon


versions : Course -> Html Msg
versions course =
    let
        last =
            Dict.size course.versions - 1
    in
    course.versions
        |> Dict.toList
        |> List.map (\( key, value ) -> ( key, value.definition.version ))
        |> List.sortBy Tuple.first
        |> List.indexedMap
            (\i ( key, value ) ->
                btn
                    { tabbable = True
                    , title = "load version " ++ value
                    , msg =
                        Activate course.id
                            (if last == i then
                                Nothing

                             else
                                Just value
                            )
                            |> Just
                    }
                    [ Attr.class "lia-btn lia-btn--small-tag"
                    , Attr.class <|
                        case course.active of
                            Just id ->
                                if id == key then
                                    "active"

                                else
                                    "lia-btn--outline"

                            Nothing ->
                                if last == i then
                                    "active"

                                else
                                    "lia-btn--outline"
                    ]
                    [ "V " ++ value |> Html.text
                    ]
            )
        |> Html.div [ Attr.class "lia-card__version" ]


icon : String -> Html Msg
icon url =
    Html.img
        [ Attr.class "lia-card__icon"
        , Attr.src url
        , Attr.alt "Logo"
        , Attr.attribute "loading" "lazy"
        ]
        []


logo : String -> Html msg
logo url =
    if String.isEmpty url then
        Html.text ""

    else
        Html.img
            [ Attr.class "lia-card__logo"
            , Attr.src url
            , Attr.attribute "loading" "lazy"
            ]
            []


header : Inlines -> Dict String String -> Html Msg
header title macro =
    Html.header [ Attr.class "lia-card__header" ]
        [ title
            |> inlines
            |> Html.h2 [ Attr.class "lia-card__title" ]
        , macro
            |> Dict.get "tags"
            |> Maybe.map
                (String.replace ";" " | "
                    >> Html.text
                    >> List.singleton
                    >> Html.h4 [ Attr.class "lia-card__subtitle" ]
                )
            |> Maybe.withDefault (Html.text "")
        ]


body : Inlines -> Html Msg
body comment =
    comment
        |> inlines
        |> Html.p [ Attr.class "lia-card__body" ]


controls : Bool -> Inlines -> Definition -> Course -> Html Msg
controls hasShareAPI title definition course =
    Html.div [ Attr.class "lia-card__controls" ]
        [ btnIcon
            { msg = Just <| Delete course.id
            , title = "Delete this course"
            , tabbable = True
            , icon = "icon-trash"
            }
            [ Attr.class "lia-btn--tag lia-btn--transparent text-red-dark border-red-dark px-1" ]
        , btnIcon
            { msg = Just <| Reset course.id course.active
            , title = "Reset all stored states (quizzes, tasks, surveys, codes)"
            , tabbable = True
            , icon = "icon-refresh"
            }
            [ Attr.class "lia-btn--tag lia-btn--transparent text-yellow-dark border-yellow-dark px-1" ]
        , if hasShareAPI then
            btnIcon
                { msg =
                    Just <|
                        Share
                            { title = stringify title
                            , text = stringify definition.comment
                            , url = Const.urlLiascriptCourse ++ course.id
                            , image =
                                if String.isEmpty definition.logo then
                                    Nothing

                                else
                                    Just definition.logo
                            }
                , title = "Share course via"
                , tabbable = True
                , icon = "icon-social"
                }
                [ Attr.class "lia-btn--transparent lia-btn--tag px-1 text-turquoise border-turquoise" ]

          else
            btnIcon
                { msg =
                    Just <|
                        Share
                            { title = stringify title
                            , text = stringify definition.comment
                            , url = Const.urlLiascriptCourse ++ course.id
                            , image = Nothing
                            }
                , title = "Copy URL to clipboard"
                , tabbable = True
                , icon = "icon-copy"
                }
                [ Attr.class "lia-btn--transparent lia-btn--tag px-1 text-turquoise border-turquoise" ]
        , Html.a
            [ Attr.class "lia-btn lia-btn--transparent lia-btn--tag px-1 text-turquoise border-turquoise"
            , Attr.href <| "mailto:" ++ definition.email
            , Attr.classList [ ( "hide", String.isEmpty definition.email ) ]
            , Attr.title ("Send an email to: " ++ definition.email)
            ]
            [ Html.i [ Attr.class "icon icon-mail" ] []
            ]
        , case course.active of
            Nothing ->
                Html.a
                    [ Base.href course.id
                    , Attr.class "lia-btn lia-btn--transparent lia-btn--tag px-1 border-turquoise"
                    , Attr.title "Open this course"
                    , Attr.style "border" "2.5px solid"
                    ]
                    [ Html.i [ Attr.class "icon icon-login text-turquoise" ] [] ]

            Just _ ->
                btnIcon
                    { msg = Just <| Restore course.id course.active
                    , title = "Open this course"
                    , tabbable = True
                    , icon = "icon-login"
                    }
                    [ Attr.class "lia-btn--transparent lia-btn--tag px-1 text-turquoise border-turquoise"
                    , Attr.style "border" "2.5px solid"
                    ]
        ]


footer : String -> Html msg
footer author =
    if String.isEmpty author then
        Html.text ""

    else
        Html.footer [ Attr.class "lia-card__footer lia-card__author" ]
            [ Html.text author ]


get_active : Course -> Maybe Release
get_active course =
    case course.active of
        Nothing ->
            course.versions
                |> Dict.toList
                |> List.sortBy Tuple.first
                |> List.reverse
                |> List.head
                |> Maybe.map Tuple.second

        Just id ->
            course.versions
                |> Dict.get id


inlines : Inlines -> List (Html Msg)
inlines =
    List.map (Inline.view_inf Array.empty En False False Nothing Nothing Nothing >> Html.map (always NoOp))
