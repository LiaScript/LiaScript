module Index.View.Base exposing
    ( card
    , href
    , view
    )

import Array
import Const
import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Index.Model exposing (Course, Release)
import Index.Update exposing (Msg(..))
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Effect.Parser exposing (comment)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View as Inline
import Lia.Parser.PatReplace exposing (link)
import Lia.Utils exposing (btn, btnIcon)
import List.Extra exposing (greedyGroupsOf)
import Translations exposing (Lang(..))


href : String -> Attribute msg
href =
    link >> (++) "./?" >> Attr.href


view session show =
    List.map (card session.share show)
        >> Html.div [ Attr.class "preview-grid" ]


card : Bool -> { tags : Bool, body : Bool, footer : Bool } -> Course -> Html Msg
card share show course =
    case get_active course of
        Just { title, definition } ->
            Html.article [ Attr.class "lia-card" ]
                [ viewVersions course
                , viewMedia course.id definition.logo
                , Html.div [ Attr.class "lia-card__content" ]
                    [ viewHeader show.tags title definition.macro
                    , if show.body then
                        viewBody definition.comment

                      else
                        Html.text ""
                    , viewControls share show.footer title definition.comment course
                    , if show.footer then
                        viewFooter definition

                      else
                        Html.text ""
                    ]
                ]

        _ ->
            Html.text "something went wrong"


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


viewHeader : Bool -> Inlines -> Dict String String -> Html Msg
viewHeader viewTags title macro =
    Html.header [ Attr.class "lia-card__header" ]
        [ title
            |> inlines
            |> Html.h3 [ Attr.class "lia-card__title" ]
        , if viewTags then
            macro
                |> Dict.get "tags"
                |> Maybe.map
                    (String.replace ";" " | "
                        >> Html.text
                        >> List.singleton
                        >> Html.h4 [ Attr.class "lia-card__subtitle" ]
                    )
                |> Maybe.withDefault (Html.text "")

          else
            Html.text ""
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


viewControls : Bool -> Bool -> Inlines -> Inlines -> Course -> Html Msg
viewControls hasShareAPI showFooter title comment course =
    Html.div
        [ Attr.class "lia-card__controls"
        , if showFooter then
            Attr.class ""

          else
            Attr.style "margin-bottom" "0px"
        ]
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
                            , text = stringify comment ++ "\n"
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


getIcon : Dict String String -> String
getIcon =
    Dict.get "icon"
        >> Maybe.withDefault Const.icon


inlines : Inlines -> List (Html Msg)
inlines =
    List.map (Inline.view_inf Array.empty En Nothing >> Html.map (always NoOp))


defaultBackground : String -> Attribute msg
defaultBackground url =
    Attr.style "background-image" <| "radial-gradient(circle farthest-side at right bottom," ++ url2Color url ++ " 30%,#ddd)"


url2Color : String -> String
url2Color url =
    url
        |> String.toList
        |> List.map Char.toCode
        |> greedyGroupsOf 3
        |> List.foldl
            (\rgb ( r, g, b ) ->
                case rgb of
                    [ r_, g_, b_ ] ->
                        ( r + r_, g + g_, b + b_ )

                    [ r_, g_ ] ->
                        ( r_ + r, g_ + g, b )

                    [ r_ ] ->
                        ( r_ + r, g, b )

                    _ ->
                        ( r, g, b )
            )
            ( 11111, 99, 12 )
        |> (\( r, g, b ) ->
                "rgb("
                    ++ (String.fromInt <| modBy 255 r)
                    ++ ","
                    ++ (String.fromInt <| modBy 255 g)
                    ++ ","
                    ++ (String.fromInt <| modBy 255 b)
                    ++ ")"
           )
