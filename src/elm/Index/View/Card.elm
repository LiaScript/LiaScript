module Index.View.Card exposing (card)

import Accessibility.Aria as A11y_Aria
import Accessibility.Role as A11y_Role
import Array
import Const
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import I18n.Translations exposing (Lang(..))
import Index.Model exposing (Action(..), Course, Release, cardID)
import Index.Update exposing (Msg(..))
import Index.View.Base as Base
import Index.View.Popup as Popup
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View as Inline
import Lia.Utils exposing (btn, btnIcon)


{-| `compact` is used by the kanban board: `Nothing` shows the whole card,
`Just open` only the title with an open button and a toggle for the details.
`extra` is appended as the last row of the details, e.g. the column select of
the kanban board.
-}
card : { share : Bool, compact : Maybe Bool, extra : List (Html Msg) } -> Course -> Html Msg
card config course =
    get_active course
        |> Maybe.map (article config course)
        |> Maybe.withDefault (Html.text "something went wrong")


article : { share : Bool, compact : Maybe Bool, extra : List (Html Msg) } -> Course -> Release -> Html Msg
article { share, compact, extra } course { title, definition } =
    let
        details =
            compact /= Just False
    in
    Html.article
        [ Attr.class "lia-card"
        , Attr.classList [ ( "lia-card--compact", not details ) ]
        , A11y_Aria.label (stringify title)

        -- the title of a compact card might be cut off
        , if details then
            Attr.class ""

          else
            Attr.title (stringify title)

        -- focusable by script only, see the deletion of a course
        , Attr.id (cardID course.id)
        , Attr.tabindex -1
        ]
        (versions course
            :: (if details then
                    [ icon (getIcon definition.macro)
                    , logo definition.logo
                    ]

                else
                    [ thumb course.id (getIcon definition.macro) definition.logo ]
               )
            ++ [ Html.div [ Attr.class "lia-card__content" ]
                    (header title definition.macro
                        :: (if details then
                                [ body definition.comment
                                , controls share title definition course
                                , footer definition.author
                                ]
                                    ++ extra

                            else
                                []
                           )
                        ++ (case compact of
                                Just open ->
                                    [ Html.div [ Attr.class "lia-card__toggle" ]
                                        [ btnIcon
                                            { title =
                                                if open then
                                                    "Hide details"

                                                else
                                                    "Show details"
                                            , tabbable = True
                                            , msg = Just (ToggleDetails course.id)
                                            , icon =
                                                if open then
                                                    "icon-chevron-up"

                                                else
                                                    "icon-chevron-down"
                                            }
                                            [ Attr.class "lia-btn--transparent"
                                            , A11y_Aria.expanded open
                                            ]
                                        , if open then
                                            Html.text ""

                                          else
                                            openButton course
                                        ]
                                    ]

                                Nothing ->
                                    []
                           )
                    )
               ]
        )


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
        |> Html.div
            [ Attr.class "lia-card__version"
            , A11y_Role.group
            , A11y_Aria.label "Course versions"
            ]


icon : String -> Html Msg
icon url =
    Html.img
        [ Attr.class "lia-card__icon"
        , Attr.src url

        -- the kanban board drags the whole card, not the image
        , Attr.draggable "false"
        , Attr.alt ""
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
            , Attr.draggable "false"
            , Attr.attribute "loading" "lazy"
            , Attr.alt ""
            , hideOnError
            ]
            []


{-| The image of a compact card, the logo covers the course icon, if there is
no logo or it cannot be loaded, the icon remains.
-}
thumb : String -> String -> String -> Html msg
thumb courseID iconUrl logoUrl =
    Html.div [ Attr.class "lia-card__thumb" ]
        [ Html.img
            [ Attr.class "lia-card__thumb-icon"

            -- the LiaScript bird is zoomed into its head and gets a color
            -- per course
            , if iconUrl == Const.icon then
                Attr.class "lia-card__thumb-icon--default"

              else
                Attr.class ""
            , if iconUrl == Const.icon then
                Attr.style "filter" ("hue-rotate(" ++ String.fromInt (hue courseID) ++ "deg)")

              else
                Attr.class ""
            , Attr.src iconUrl
            , Attr.draggable "false"
            , Attr.alt ""
            ]
            []
        , if String.isEmpty logoUrl then
            Html.text ""

          else
            Html.img
                [ Attr.class "lia-card__thumb-logo"
                , Attr.src logoUrl
                , Attr.draggable "false"
                , Attr.attribute "loading" "lazy"
                , Attr.alt ""
                , hideOnError
                ]
                []
        ]


{-| A stable hue (0 - 359) for an url, djb2 hash kept below a prime, such
that it stays within the safe integer range.
-}
hue : String -> Int
hue =
    String.foldl (\char hash -> modBy 1000003 (hash * 33 + Char.toCode char)) 5381
        >> modBy 360


{-| Broken logo urls are common, a broken image would be shown otherwise.
-}
hideOnError : Html.Attribute msg
hideOnError =
    Attr.attribute "onerror" "this.style.display='none'"


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
                    >> Html.h3 [ Attr.class "lia-card__subtitle" ]
                )
            |> Maybe.withDefault (Html.text "")
        ]


body : Inlines -> Html Msg
body comment =
    comment
        |> inlines
        |> Html.p [ Attr.class "lia-card__body" ]


popup : Action -> Maybe Action -> String -> Msg -> Html Msg
popup action open courseID msg =
    case ( action, open ) of
        ( Popup_Delete, Just Popup_Delete ) ->
            Popup.view
                { text =
                    "Are you sure you want to permanently delete this course and all of its stored states? "
                        ++ "This action cannot be undone."
                , action =
                    { msg = msg
                    , text = "Delete"
                    }
                , escape = PopupClose
                , abort = PopupAbort (Popup.triggerID "delete" courseID)
                }

        ( Popup_Reset, Just Popup_Reset ) ->
            Popup.view
                { text =
                    "Are you sure you want to reset this course? "
                        ++ "This will permanently remove all stored states, including quizzes, tasks, surveys, and code entries. "
                        ++ "This action cannot be undone."
                , action =
                    { msg = msg
                    , text = "Reset"
                    }
                , escape = PopupClose
                , abort = PopupAbort (Popup.triggerID "reset" courseID)
                }

        _ ->
            Html.text ""


controls : Bool -> Inlines -> Definition -> Course -> Html Msg
controls hasShareAPI title definition course =
    Html.div
        [ Attr.class "lia-card__controls"
        , A11y_Role.group
        , A11y_Aria.label "Course actions"
        ]
        [ popup Popup_Delete course.popup course.id (Delete True course.id)
        , popup Popup_Reset course.popup course.id (Reset True course.id course.active)
        , btnIcon
            { msg = Just <| Delete False course.id
            , title = "Delete this course"
            , tabbable = True
            , icon = "icon-trash"
            }
            [ Attr.class "lia-btn--tag lia-btn--transparent text-red-dark border-red-dark px-1"
            , Attr.id (Popup.triggerID "delete" course.id)
            ]
        , btnIcon
            { msg = Just <| Reset False course.id course.active
            , title = "Reset all stored states (quizzes, tasks, surveys, codes)"
            , tabbable = True
            , icon = "icon-refresh"
            }
            [ Attr.class "lia-btn--tag lia-btn--transparent text-yellow-dark border-yellow-dark px-1"
            , Attr.id (Popup.triggerID "reset" course.id)
            ]
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
        , btnIcon
            { msg = Just <| SaveOffline course.id
            , title = "Download media for offline use (images, audio and video)"
            , tabbable = True
            , icon = "icon-download"
            }
            [ Attr.class "lia-btn--transparent lia-btn--tag px-1 text-turquoise border-turquoise" ]
        , Html.a
            [ Attr.class "lia-btn lia-btn--transparent lia-btn--tag px-1 text-turquoise border-turquoise"
            , Attr.href <| "mailto:" ++ definition.email
            , Attr.classList [ ( "hide", String.isEmpty definition.email ) ]
            , Attr.title ("Send an email to: " ++ definition.email)
            , A11y_Aria.label ("Send an email to: " ++ definition.email)
            ]
            [ Html.i [ A11y_Aria.hidden True, Attr.class "icon icon-mail" ] []
            ]
        , openButton course
        ]


openButton : Course -> Html Msg
openButton course =
    case course.active of
        Nothing ->
            Html.a
                [ Base.href course.id
                , Attr.class "lia-btn lia-btn--transparent lia-btn--tag px-1 border-turquoise"
                , Attr.title "Open this course"
                , Attr.style "border" "2.5px solid"
                , A11y_Aria.label "Open this course"
                ]
                [ Html.i [ A11y_Aria.hidden True, Attr.class "icon icon-login text-turquoise" ] [] ]

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
    List.map (Inline.view_inf Array.empty En False False Nothing Nothing Nothing >> Html.map (always None))
