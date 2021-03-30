module Index.View exposing (view)

import Accessibility.Role exposing (definition)
import Array
import Const
import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr exposing (title)
import Html.Events exposing (onInput)
import Index.Model exposing (Course, Model, Release)
import Index.Update exposing (Msg(..))
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Editor exposing (onChange)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View as Inline
import Lia.Parser.PatReplace exposing (link)
import Lia.Settings.Types exposing (Mode(..))
import Lia.Utils exposing (blockKeydown, btn)
import Session exposing (Session)
import Translations exposing (Lang(..))


view : Session -> Model -> Html Msg
view session model =
    Html.div []
        [ Html.h1 [] [ Html.text "Lia: Open-courSes" ]
        , searchBar model.input
        , if List.isEmpty model.courses && model.initialized then
            Html.div [] <|
                [ [ "If you cannot see any courses in this list, try out one of the following links, to get more information about this project and to visit some examples and free interactive books."
                        |> Html.text
                  ]
                    |> Html.p []
                , Html.a [ Attr.href "https://LiaScript.github.io" ]
                    [ Html.text "Project-Website" ]
                , Html.a [ href "https://raw.githubusercontent.com/liaScript/docs/master/README.md" ]
                    [ Html.text "Project-Description"
                    ]
                , Html.a [ href "https://raw.githubusercontent.com/liaScript/index/master/README.md" ]
                    [ Html.text "Index" ]
                , [ "At the end, I hope to see some of your courses in my list."
                        |> Html.text
                  ]
                    |> Html.p []
                , Html.text "Have a nice one ;-) ..."
                ]

          else if model.initialized then
            model.courses
                |> List.map (card session.share)
                |> Html.div [ Attr.class "preview-grid" ]

          else
            Html.text ""
        ]


searchBar : String -> Html Msg
searchBar url =
    Html.div []
        [ Html.input
            [ Attr.type_ "input"
            , onInput Input
            , Attr.value url
            , Attr.placeholder "course-url"

            --, blockKeydown NoOp
            ]
            []
        , if url == "" then
            Html.text "load course"

          else
            Html.a
                [ href url
                ]
                [ Html.text "load course"
                ]
        ]


getIcon : Dict String String -> String
getIcon =
    Dict.get "icon"
        >> Maybe.withDefault Const.icon


card : Bool -> Course -> Html Msg
card share course =
    case get_active course of
        Just { title, definition } ->
            Html.article [ Attr.class "card" ]
                [ viewVersions course
                , viewMedia definition.logo
                , viewHeader title definition.macro
                , viewBody definition.comment
                , viewControls share title definition.comment course
                , viewFooter definition
                ]

        _ ->
            Html.text "something went wrong"


href : String -> Attribute msg
href =
    link >> (++) "./?" >> Attr.href


viewVersions : Course -> Html Msg
viewVersions course =
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
                    { msg =
                        Just <|
                            Activate course.id
                                (if last == i then
                                    Nothing

                                 else
                                    Just value
                                )
                    , tabbable = True
                    , title = "load version " ++ value
                    }
                    [ Attr.class <|
                        case course.active of
                            Just id ->
                                if id == key then
                                    "active"

                                else
                                    ""

                            Nothing ->
                                if last == i then
                                    "active"

                                else
                                    ""
                    ]
                    [ "V " ++ value |> Html.text
                    ]
            )
        |> Html.div [ Attr.class "card__version" ]


viewMedia : String -> Html msg
viewMedia url =
    Html.div [ Attr.class "card__media" ]
        [ Html.aside [ Attr.class "card__aside" ]
            [ Html.figure [ Attr.class "card__figure" ]
                [ Html.img
                    [ Attr.class "card__image"
                    , Attr.src <|
                        case String.trim url of
                            "" ->
                                ""

                            logo ->
                                logo
                    ]
                    []
                ]
            ]
        ]


viewHeader : Inlines -> Dict String String -> Html Msg
viewHeader title macro =
    Html.header [ Attr.class "card__header" ]
        [ title
            |> inlines
            |> Html.h3 [ Attr.class "card__title" ]
        , macro
            |> Dict.get "tags"
            |> Maybe.map
                (String.replace ";" " | "
                    >> Html.text
                    >> List.singleton
                    >> Html.h4 [ Attr.class "card__subtitle" ]
                )
            |> Maybe.withDefault (Html.text "")
        ]


viewBody : Inlines -> Html Msg
viewBody comment =
    Html.div [ Attr.class "card__body" ] <|
        case comment of
            [] ->
                []

            _ ->
                [ comment
                    |> inlines
                    |> Html.p [ Attr.class "card__copy" ]
                ]


viewControls : Bool -> Inlines -> Inlines -> Course -> Html Msg
viewControls hasShareAPI title comment course =
    Html.div [ Attr.class "card__controls" ]
        [ btn
            { msg = Just <| Delete course.id
            , title = "delete"
            , tabbable = True
            }
            []
            [ Html.text "Delete" ]
        , btn
            { msg = Just <| Reset course.id course.active
            , title = "reset"
            , tabbable = True
            }
            []
            [ Html.text "Reset" ]
        , if hasShareAPI then
            btn
                { msg =
                    Just <|
                        Share
                            (title |> stringify)
                            ((comment |> stringify) ++ "\n")
                            ("https://LiaScript.github.io/course/?" ++ course.id)
                , title = "share"
                , tabbable = True
                }
                []
                [ Html.text "Share" ]

          else
            Html.text ""
        , case course.active of
            Nothing ->
                Html.a
                    [ href course.id
                    , Attr.class "lia-btn"
                    ]
                    [ Html.text "Open" ]

            Just _ ->
                btn
                    { msg = Just <| Restore course.id course.active
                    , title = "open"
                    , tabbable = True
                    }
                    []
                    [ Html.text "Open"
                    ]
        ]


viewFooter : Definition -> Html msg
viewFooter definition =
    Html.footer [ Attr.class "card__footer" ]
        [ Html.img
            [ Attr.class "card__logo"
            , definition.macro
                |> getIcon
                |> Attr.src
            , Attr.alt "Logo"
            , Attr.height 50
            ]
            []
        , case ( String.trim definition.author, String.trim definition.email ) of
            ( "", "" ) ->
                Html.text ""

            ( "", email ) ->
                contact email email

            ( author, "" ) ->
                Html.span [ Attr.class "card__contact" ] [ Html.text author ]

            ( author, email ) ->
                contact author email
        ]


contact : String -> String -> Html msg
contact title mail =
    Html.a [ Attr.class "card__contact", Attr.href <| "mailto:" ++ mail ] [ Html.text title ]


get_active : Course -> Maybe Release
get_active course =
    case course.active of
        Nothing ->
            course.versions
                |> Dict.toList
                |> List.sortBy Tuple.first
                |> List.head
                |> Maybe.map Tuple.second

        Just id ->
            course.versions
                |> Dict.get id


inlines : Inlines -> List (Html Msg)
inlines =
    List.map (Inline.view_inf Array.empty En Nothing >> Html.map (always NoOp))
