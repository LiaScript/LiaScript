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
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View as Inline
import Lia.Parser.PatReplace exposing (link)
import Lia.Settings.Types exposing (Settings)
import Lia.Settings.View as Settings
import Lia.Utils exposing (blockKeydown, btn, btnIcon, string2Color)
import Session exposing (Session)
import Translations exposing (Lang(..))


view : Session -> Settings -> Model -> Html Msg
view session settings model =
    Html.div [ Attr.class "p-1" ]
        [ [ ( Settings.menuSettings session.screen.width, "settings" )
          ]
            |> Settings.header False En session.screen settings Const.icon
            |> Html.map UpdateSettings
        , Html.main_ [ Attr.class "lia-slide__content" ]
            [ Html.h1 [] [ Html.text "Lia: Open-courSes" ]
            , searchBar model.input
            , if List.isEmpty model.courses && model.initialized then
                Html.section [] <|
                    [ Html.br [] []
                    , Html.p
                        [ Attr.class "lia-paragraph" ]
                        [ Html.text "If you cannot see any courses in this list, try out one of the following links, to get more information about this project and to visit some examples and free interactive books."
                        ]
                    , Html.u
                        []
                        [ Html.li []
                            [ Html.a
                                [ Attr.href Const.urlLiascript, Attr.target "_blank" ]
                                [ Html.text "Project-Website" ]
                            ]
                        , Html.li []
                            [ Html.a
                                [ href "https://raw.githubusercontent.com/liaScript/docs/master/README.md", Attr.target "_blank" ]
                                [ Html.text "Project-Documentation" ]
                            ]
                        , Html.li []
                            [ Html.a
                                [ href "https://raw.githubusercontent.com/liaScript/index/master/README.md", Attr.target "_blank" ]
                                [ Html.text "Index" ]
                            ]
                        ]
                    , Html.br [] []
                    , Html.p
                        [ Attr.class "lia-paragraph" ]
                        [ Html.text "At the end, we hope to learn from your courses." ]
                    , Html.p
                        [ Attr.class "lia-paragraph" ]
                        [ Html.text "Have a nice one ;-) ..." ]
                    ]

              else if model.initialized then
                model.courses
                    |> List.map (card session.share)
                    |> Html.div [ Attr.class "preview-grid" ]

              else
                Html.text ""
            ]
        ]


searchBar : String -> Html Msg
searchBar url =
    Html.div []
        [ Html.input
            [ Attr.type_ "url"
            , onInput Input
            , Attr.value url
            , Attr.placeholder "course-url"
            , Attr.class "lia-input border-grey-light max-w-50 mr-1"
            , blockKeydown NoOp
            ]
            []
        , if url == "" then
            btn
                { tabbable = False
                , title = "load"
                , msg = Nothing
                }
                []
                [ Html.text "load course"
                ]

          else
            btn
                { tabbable = True
                , title = "load"
                , msg =
                    url
                        |> link
                        |> (++) "./?"
                        |> LoadCourse
                        |> Just
                }
                []
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
            Html.article [ Attr.class "lia-card" ]
                [ viewVersions course
                , viewMedia course.id definition.logo
                , Html.div [ Attr.class "lia-card__content" ]
                    [ viewHeader title definition.macro
                    , viewBody definition.comment
                    , viewControls share title definition.comment course
                    , viewFooter definition
                    ]
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
                    [ Attr.class "lia-btn--tag"
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


viewMedia : String -> String -> Html msg
viewMedia courseUrl logoUrl =
    Html.div [ Attr.class "lia-card__media" ]
        [ Html.aside [ Attr.class "lia-card__aside" ]
            [ Html.figure [ Attr.class "lia-card__figure" ]
                [ Html.img
                    [ Attr.class "lia-card__image"
                    , logoUrl
                        |> String.trim
                        |> Attr.src
                    , Attr.attribute "loading" "lazy"
                    , defaultBackground courseUrl
                    ]
                    []
                ]
            ]
        ]


viewHeader : Inlines -> Dict String String -> Html Msg
viewHeader title macro =
    Html.header [ Attr.class "lia-card__header" ]
        [ title
            |> inlines
            |> Html.h3 [ Attr.class "lia-card__title" ]
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


viewBody : Inlines -> Html Msg
viewBody comment =
    Html.div [ Attr.class "lia-card__body" ] <|
        case comment of
            [] ->
                []

            _ ->
                [ comment
                    |> inlines
                    |> Html.p [ Attr.class "lia-card__copy" ]
                ]


viewControls : Bool -> Inlines -> Inlines -> Course -> Html Msg
viewControls hasShareAPI title comment course =
    Html.div [ Attr.class "lia-card__controls" ]
        [ btnIcon
            { msg = Just <| Delete course.id
            , title = "delete"
            , tabbable = True
            , icon = "icon-trash"
            }
            [ Attr.class "lia-btn--tag lia-btn--transparent text-red-dark border-red-dark px-1" ]
        , btnIcon
            { msg = Just <| Reset course.id course.active
            , title = "reset"
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
                            , text = stringify comment
                            , url = Const.urlLiascriptCourse ++ course.id
                            }
                , title = "share"
                , tabbable = True
                , icon = "icon-social"
                }
                [ Attr.class "lia-btn--transparent lia-btn--tag px-1 text-turquoise border-turquoise" ]

          else
            Html.text ""
        , case course.active of
            Nothing ->
                Html.a
                    [ href course.id
                    , Attr.class "lia-btn lia-btn--transparent lia-btn--tag px-1 border-turquoise"
                    , Attr.title "open"
                    ]
                    [ Html.i [ Attr.class "icon icon-login text-turquoise" ] [] ]

            Just _ ->
                btnIcon
                    { msg = Just <| Restore course.id course.active
                    , title = "open"
                    , tabbable = True
                    , icon = "icon-sign-in"
                    }
                    [ Attr.class "lia-btn--transparent lia-btn--tag px-1 text-turquoise border-turquoise"
                    ]
        ]


viewFooter : Definition -> Html msg
viewFooter definition =
    Html.footer [ Attr.class "lia-card__footer" ]
        [ Html.img
            [ Attr.class "lia-card__logo"
            , definition.macro
                |> getIcon
                |> Attr.src
            , Attr.alt "Logo"
            , Attr.height 50
            , Attr.attribute "loading" "lazy"
            ]
            []
        , case ( String.trim definition.author, String.trim definition.email ) of
            ( "", "" ) ->
                Html.text ""

            ( "", email ) ->
                contact email email

            ( author, "" ) ->
                Html.span [ Attr.class "lia-card__contact" ] [ Html.text author ]

            ( author, email ) ->
                contact author email
        ]


contact : String -> String -> Html msg
contact title mail =
    Html.a [ Attr.class "lia-card__contact", Attr.href <| "mailto:" ++ mail ]
        [ Html.text title
        , Html.i [ Attr.class "icon icon-mail ml-1 align-middle" ] []
        ]


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
    List.map (Inline.view_inf Array.empty En False False Nothing Nothing Nothing >> Html.map (always NoOp))


defaultBackground : String -> Attribute msg
defaultBackground url =
    Attr.style "background-image" <| "radial-gradient(circle farthest-side at right bottom," ++ string2Color 255 url ++ " 30%,#ddd)"
