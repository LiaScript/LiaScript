module Lia.Sync.View exposing (view)

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Index.View.Popup as Popup
import Lia.Settings.Update exposing (Msg(..))
import Lia.Sync.Classroom as Classroom
import Lia.Sync.Types as Sync exposing (ClassroomMode(..), State(..), Sync)
import Lia.Sync.Update exposing (Msg(..), SyncMsg(..))
import Lia.Sync.Via as Backend exposing (Backend)
import Lia.Utils exposing (btn, btnIcon)
import Time


view : Sync.Settings -> Html Msg
view settings =
    let
        open =
            case settings.state of
                Sync.Disconnected ->
                    True

                _ ->
                    False
    in
    Html.div
        [ --Attr.style "min-width" "320px"
          Attr.style "width" "80%"
        , Attr.style "max-width" "600px"
        , Attr.style "overflow" "auto"
        ]
        [ Html.h1
            [ Attr.style "text-align" "center"
            , Attr.id "lia-modal-focus"
            , Attr.tabindex 0
            ]
            [ Html.text "Classroom "
            , settings.sync.select
                |> Maybe.map
                    (Tuple.second
                        >> Backend.icon
                        >> List.singleton
                        >> Html.span
                            [ Attr.style "font-size" "xxx-large"
                            , Attr.style "vertical-align" "middle"
                            ]
                    )
                |> Maybe.withDefault (Html.text "")
            ]
        , select open settings.sync
        , case settings.sync.select of
            Nothing ->
                Html.div []
                    [ savedList Nothing settings
                    , Backend.info
                    ]

            Just ( support, via ) ->
                Html.div []
                    [ savedList (Just via) settings
                    , Backend.input
                        { active = open && support
                        , msg = Room
                        , type_ = "text"
                        , value = settings.room
                        , placeholder = "Just any kind of typeable name"
                        , label =
                            Html.span []
                                [ Html.text "room "
                                , btnIcon
                                    { title = "generate random"
                                    , tabbable = open && support
                                    , msg =
                                        if open && support then
                                            Just Random_Generate

                                        else
                                            Nothing
                                    , icon = "icon-refresh"
                                    }
                                    [ Attr.class "lia-btn--transparent icon-sm"
                                    , Attr.style "padding" "0"
                                    ]
                                ]
                        , autocomplete = Just "room"
                        }
                    , viewMode settings.mode
                    , Backend.input
                        { active = open && support
                        , msg = Password
                        , label = Html.text "maybe password"
                        , type_ = "password"
                        , value = settings.password
                        , placeholder = ""
                        , autocomplete = Just "password"
                        }
                    , Backend.input
                        { active = open && support
                        , msg = Name
                        , label = Html.text "optional username"
                        , type_ = "text"
                        , value = settings.name
                        , placeholder = "Enter your name to be displayed to others"
                        , autocomplete = Just "name"
                        }
                    , Backend.view (open && support) via
                        |> Html.map Config
                        |> Html.map Backend
                    , Html.div []
                        [ Backend.checkbox
                            { active = True
                            , msg = EnabledScript settings.scriptsEnabled
                            , label = Html.text "Allow scripts to be executed in the chat"
                            , value = settings.scriptsEnabled
                            }
                        ]
                    , Html.div []
                        [ Backend.checkbox
                            { active =
                                open
                                    && support
                                    && (via /= Backend.Local)
                            , msg = TogglePersistent
                            , label = Html.text "Remember this classroom (saves settings and caches its content locally)"
                            , value = settings.persistent || via == Backend.Local
                            }
                        ]
                    , button settings
                    , viewError settings.error
                    , Backend.infoOn support via
                    ]
        ]


viewError : Maybe String -> Html msg
viewError message =
    case message of
        Nothing ->
            Html.text ""

        Just msg ->
            Html.div
                [ Attr.style "margin-block-start" "2rem", Attr.style "font-weight" "bold" ]
                [ Html.text <| "Error: " ++ msg ]


{-| Show the locally saved classrooms. The "Own Notes" entry (if it has ever
been connected to) is always pinned as its own tile rather than a regular
deletable row, on both the overview and its own backend page.

On the overview page (`context == Nothing`) every other saved entry is
listed alongside that pinned tile. On a backend-specific page
(`context == Just via`) the list is narrowed down to entries saved for that
backend; if none match (and it isn't the Local page, which always has its
pinned tile), nothing is rendered at all.

-}
savedList : Maybe Backend -> Sync.Settings -> Html Msg
savedList context settings =
    case settings.state of
        Sync.Disconnected ->
            let
                notes =
                    settings.saved |> List.filter isNotesEntry |> List.head

                header rows =
                    Html.div [ Attr.style "margin-block-start" "2rem" ]
                        [ Html.span [ Attr.class "lia-label" ] [ Html.text "Saved Classrooms" ]
                        , listContainer rows
                        ]
            in
            case context of
                Nothing ->
                    settings.saved
                        |> List.filter (isNotesEntry >> not)
                        |> List.map (savedItem settings.deletePopup)
                        |> (::) (notesTile notes)
                        |> header

                Just Backend.Local ->
                    settings.saved
                        |> List.filter (\entry -> matchesBackend Backend.Local entry && not (isNotesEntry entry))
                        |> List.map (savedItem settings.deletePopup)
                        |> (::) (notesTile notes)
                        |> header

                Just via ->
                    case List.filter (matchesBackend via) settings.saved of
                        [] ->
                            Html.text ""

                        entries ->
                            header (List.map (savedItem settings.deletePopup) entries)

        _ ->
            Html.text ""


{-| Does this saved entry belong to the given backend? Compared by backend
_type_ (e.g. any saved GUN room matches a GUN backend, regardless of its
stored relay-server URL) via `Backend.eq`.
-}
matchesBackend : Backend -> Classroom.Entry -> Bool
matchesBackend via entry =
    entry.backend
        |> Backend.fromString
        |> Maybe.map (Backend.eq via)
        |> Maybe.withDefault False


{-| The "Own Notes" entry is the one saved (Local, `notesRoomName`) room —
it is pinned to its own tile rather than shown as a regular deletable row.
-}
isNotesEntry : Classroom.Entry -> Bool
isNotesEntry entry =
    entry.room == Classroom.notesRoomName && matchesBackend Backend.Local entry


{-| Bordered, height-capped, scrollable box for the saved-classrooms rows, so
a long list doesn't push the rest of the modal down.
-}
listContainer : List (Html msg) -> Html msg
listContainer =
    Html.div
        [ Attr.style "border" "1px solid rgb(var(--color-border))"
        , Attr.style "border-radius" "4px"
        , Attr.style "max-height" "12rem"
        , Attr.style "overflow-y" "auto"
        , Attr.style "padding" "0 10px"
        ]


{-| Format a stored `updated` timestamp (epoch milliseconds) as
`DD.MM.YYYY HH:MM`, in UTC (no user-local timezone is plumbed through the
app anywhere yet).
-}
formatDate : Int -> String
formatDate ms =
    let
        posix =
            Time.millisToPosix ms

        pad n =
            n |> String.fromInt |> String.padLeft 2 '0'

        month =
            case Time.toMonth Time.utc posix of
                Time.Jan ->
                    1

                Time.Feb ->
                    2

                Time.Mar ->
                    3

                Time.Apr ->
                    4

                Time.May ->
                    5

                Time.Jun ->
                    6

                Time.Jul ->
                    7

                Time.Aug ->
                    8

                Time.Sep ->
                    9

                Time.Oct ->
                    10

                Time.Nov ->
                    11

                Time.Dec ->
                    12
    in
    pad (Time.toDay Time.utc posix)
        ++ "."
        ++ pad month
        ++ "."
        ++ String.fromInt (Time.toYear Time.utc posix)
        ++ " "
        ++ pad (Time.toHour Time.utc posix)
        ++ ":"
        ++ pad (Time.toMinute Time.utc posix)


{-| The pinned "Own Notes" shortcut. Shows the last-used date once the
notes room has actually been connected to at least once; before that,
there is nothing to show a date for.
-}
notesTile : Maybe Classroom.Entry -> Html Msg
notesTile entry =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "align-items" "center"
        , Attr.style "justify-content" "space-between"
        , Attr.style "padding" "5px 0"
        ]
        [ Html.button
            [ Event.onClick OpenNotes
            , Attr.class "lia-btn lia-btn--transparent"
            ]
            [ Backend.icon Backend.Local
            , Html.text "Own Notes (offline)"
            , entry
                |> Maybe.map (.updated >> dateSpan)
                |> Maybe.withDefault (Html.text "")
            ]
        ]


dateSpan : Int -> Html msg
dateSpan updated =
    Html.span
        [ Attr.style "opacity" "0.6"
        , Attr.style "font-size" "smaller"
        , Attr.style "padding-inline-start" "8px"
        ]
        [ Html.text (formatDate updated) ]


savedItem : Maybe ( String, String ) -> Classroom.Entry -> Html Msg
savedItem deletePopup entry =
    Html.div
        [ Attr.style "display" "flex"
        , Attr.style "align-items" "center"
        , Attr.style "justify-content" "space-between"
        , Attr.style "padding" "5px 0"
        ]
        [ Html.button
            [ Event.onClick (LoadClassroom entry)
            , Attr.class "lia-btn lia-btn--transparent"
            ]
            [ entry.backend
                |> Backend.fromString
                |> Maybe.map Backend.icon
                |> Maybe.withDefault (Html.text "")
            , Html.text entry.room
            , dateSpan entry.updated
            ]
        , case deletePopup of
            Just ( room, backend ) ->
                if room == entry.room && backend == entry.backend then
                    Popup.view
                        { text = "Delete this saved classroom and its locally cached content? This cannot be undone."
                        , action = { msg = ConfirmDeleteClassroom entry.room entry.backend, text = "Delete" }
                        , escape = CancelDeleteClassroom
                        }

                else
                    deleteBtn entry

            Nothing ->
                deleteBtn entry
        ]


deleteBtn : Classroom.Entry -> Html Msg
deleteBtn entry =
    btnIcon
        { msg = Just (AskDeleteClassroom entry.room entry.backend)
        , title = "Delete this saved classroom"
        , tabbable = True
        , icon = "icon-trash"
        }
        [ Attr.class "lia-btn--tag lia-btn--transparent text-red-dark border-red-dark px-1" ]


select : Bool -> Sync -> Html Msg
select editable sync =
    Html.map Backend <|
        Html.label []
            [ Html.span [ Attr.class "lia-label" ] [ Html.text "via Backend" ]
            , Html.br [] []
            , Html.div
                [ Attr.class "lia-dropdown"
                , if editable then
                    not sync.open
                        |> Open
                        |> Event.onClick

                  else
                    Attr.disabled True
                , A11y_Key.onKeyDown
                    [ not sync.open
                        |> Open
                        |> A11y_Key.enter
                    , not sync.open
                        |> Open
                        |> A11y_Key.space
                    ]
                ]
                [ Html.div
                    [ Attr.class "lia-dropdown__selected"
                    , A11y_Aria.hidden False
                    , A11y_Role.button
                    , Attr.tabindex 0
                    , A11y_Aria.expanded sync.open
                    ]
                    [ maybeSelect sync.select
                    , Html.i
                        [ Attr.class <|
                            "icon"
                                ++ (if sync.open then
                                        " icon-chevron-up"

                                    else
                                        " icon-chevron-down"
                                   )
                        , A11y_Role.button
                        ]
                        []
                    ]
                , sync.support
                    |> (if sync.open then
                            List.map (Just >> option)
                                >> (::) (option Nothing)

                        else
                            always []
                       )
                    |> Html.div
                        [ Attr.class "lia-dropdown__options"
                        , Attr.tabindex -1
                        , Attr.class <|
                            if sync.open then
                                "is-visible"

                            else
                                "is-hidden"
                        ]
                ]
            ]


option : Maybe ( Bool, Backend ) -> Html SyncMsg
option via =
    Html.div
        [ Event.onClick (Select via)
        , Attr.tabindex 0
        , A11y_Key.onKeyDown
            [ Select via
                |> A11y_Key.enter
            , Select via
                |> A11y_Key.space
            ]
        ]
        [ maybeSelect via ]


maybeSelect : Maybe ( Bool, Backend ) -> Html msg
maybeSelect =
    Maybe.map (Tuple.second >> selectString)
        >> Maybe.withDefault (Html.text "None")


selectString : Backend -> Html msg
selectString via =
    Html.span []
        [ Backend.icon via
        , Backend.toString False via |> Html.text
        ]


button : Sync.Settings -> Html Msg
button settings =
    case settings.state of
        Disconnected ->
            btn
                { title = "connect"
                , msg =
                    if String.isEmpty settings.room then
                        Nothing

                    else
                        Just Connect
                , tabbable = True
                }
                [ Attr.style "margin-block-start" "2rem" ]
                [ Html.text "connect" ]

        Connected _ ->
            btn
                { title = "disconnect"
                , msg = Just Disconnect
                , tabbable = True
                }
                [ Attr.style "margin-block-start" "2rem" ]
                [ Html.text "disconnect" ]

        Pending ->
            btn
                { title = "pending"
                , msg = Nothing
                , tabbable = False
                }
                [ Attr.style "margin-block-start" "2rem" ]
                [ Html.text "pending" ]


viewMode mode =
    Html.label
        [ Attr.class "lia-label"
        , Attr.style "margin-block-start" "2rem"
        , Attr.style "display" "flex"
        , Attr.style "flex-direction" "column"
        , Attr.style "align-items" "flex-start"
        ]
        [ Html.span
            [ Attr.class "lia-label"
            ]
            [ Html.text "mode" ]
        , Html.div
            [ Attr.style "display" "flex"
            , Attr.style "flex-direction" "row"
            , Attr.style "gap" "1rem"
            , Attr.style "align-items" "center"
            ]
            [ Html.select
                [ Event.onInput ClassroomMode
                , Attr.style "background" <|
                    case mode of
                        Shared ->
                            "green"

                        Summary ->
                            "orange"

                        Details ->
                            "red"
                ]
                [ Html.option
                    [ Attr.value "0"
                    , Attr.selected <| mode == Shared
                    ]
                    [ Html.text "Shared" ]
                , Html.option
                    [ Attr.value "1"
                    , Attr.selected <| mode == Summary
                    ]
                    [ Html.text "Summary" ]
                , Html.option
                    [ Attr.value "2"
                    , Attr.selected <| mode == Details
                    ]
                    [ Html.text "Details" ]
                ]
            , Html.span []
                [ Html.text <|
                    case mode of
                        Shared ->
                            "All are equal and see the summary of quizzes and surveys."

                        Summary ->
                            "Only the initiator can see the summaries."

                        Details ->
                            "The initiator can see also details per participant."
                ]
            ]
        ]
