module Index.View exposing (view)

import Accessibility.Key exposing (tabbable)
import Array
import Const
import Dict
import Html exposing (Attribute, Html)
import Html.Attributes as Attr exposing (title)
import Html.Events exposing (onClick)
import Index.Model exposing (Course, Model, Release)
import Index.Update exposing (Msg(..))
import Lia.Markdown.Code.Editor exposing (onChange)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View as Inline
import Lia.Parser.PatReplace exposing (link)
import Lia.Settings.Types exposing (Mode(..))
import Lia.Utils exposing (btn)
import Session exposing (Session)
import Translations exposing (Lang(..))


view : Session -> Model -> Html Msg
view session model =
    Html.div []
        [ Html.h1 [] [ Html.text "Lia: Open-courSes" ]
        , searchBar model.input
        , Html.div [] <|
            if List.isEmpty model.courses && model.initialized then
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

            else
                []
        ]


searchBar : String -> Html Msg
searchBar url =
    Html.div []
        [ Html.input
            [ Attr.type_ "input"
            , onChange Input
            , Attr.value url
            , Attr.placeholder "course-url"
            ]
            []
        , Html.a [ href url ]
            [ Html.text "load course"
            ]
        ]


getIcon =
    Dict.get "icon"
        >> Maybe.withDefault Const.icon


card : Bool -> Course -> Html Msg
card share course =
    case get_active course of
        Just { title, definition } ->
            [ case ( String.trim definition.author, String.trim definition.logo ) of
                ( str_a, "" ) ->
                    Html.div []
                        [ Html.img
                            [ definition.macro
                                |> getIcon
                                |> Attr.src
                            ]
                            []
                        , author str_a
                        ]

                ( str_a, str_l ) ->
                    Html.div []
                        [ Html.img
                            [ definition.macro
                                |> getIcon
                                |> Attr.src
                            ]
                            []
                        , Html.img [ Attr.src str_l ] []
                        , author str_a
                        ]
            , [ title
                    |> inlines
                    |> Html.p
                        [ Attr.style "white-space" "nowrap"
                        , Attr.style "overflow" "hidden"
                        , Attr.style "text-overflow" "ellipsis"
                        ]
              , definition.comment
                    |> inlines
                    |> Html.p []
              ]
                |> Html.div []
            , Html.hr [] []
            , [ viewVersions course
              , Html.text course.last_visit
              ]
                |> Html.div []
            , btn
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
            , if share then
                btn
                    { msg =
                        Just <|
                            Share
                                (title |> stringify)
                                ((definition.comment |> stringify) ++ "\n")
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
                |> Html.div []

        _ ->
            Html.text "something went wrong"


author : String -> Html msg
author str =
    (if str == "" then
        "Author: by Annonymous"

     else
        "Author: by " ++ str
    )
        |> Html.text


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
                let
                    color =
                        case course.active of
                            Just active ->
                                if active == key then
                                    "#000"

                                else
                                    "#888"

                            Nothing ->
                                if last == i then
                                    "#000"

                                else
                                    "#888"
                in
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
                    [ Attr.style "color" color
                    , Attr.class "lia-btn--outline"
                    ]
                    [ "V " ++ value |> Html.text
                    ]
            )
        |> Html.div []


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
