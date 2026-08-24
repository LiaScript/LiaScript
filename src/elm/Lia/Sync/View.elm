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
import Lia.Utils exposing (btn, btnIcon, formatDate)


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
        [ Attr.class "lia-classroom" ]
        [ Html.h1
            [ Attr.style "text-align" "center"
            , Attr.id "lia-modal-focus"
            , Attr.tabindex 0
            ]
            [ Html.text "Classroom" ]
        , case settings.sync.select of
            Nothing ->
                Html.div [ Attr.class "lia-classroom__overview" ]
                    [ select open settings.sync
                    , savedList settings
                    , Backend.info
                    ]

            Just ( support, via ) ->
                Html.div [ Attr.class "lia-classroom__columns" ]
                    [ Html.div [ Attr.class "lia-classroom__form" ]
                        [ select open settings.sync
                        , Backend.input
                            { active = open && support
                            , msg = Room
                            , type_ = "text"
                            , value = settings.room
                            , placeholder = "Just any kind of typeable name"
                            , label =
                                Html.span []
                                    [ Html.text "Room "
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
                        , Backend.input
                            { active = open && support
                            , msg = Name
                            , label = Html.text "Your name (optional)"
                            , type_ = "text"
                            , value = settings.name
                            , placeholder = "Enter your name to be displayed to others"
                            , autocomplete = Just "name"
                            }
                        , Backend.input
                            { active = open && support
                            , msg = Password
                            , label =
                                Html.span []
                                    [ Html.text "Password (optional)"
                                    , btn
                                        { title =
                                            if settings.passwordVisible then
                                                "hide password"

                                            else
                                                "show password"
                                        , tabbable = open && support
                                        , msg = Just TogglePasswordVisibility
                                        }
                                        [ Attr.class "lia-btn--transparent lia-btn--small-tag" ]
                                        [ Html.text <|
                                            if settings.passwordVisible then
                                                "hide"

                                            else
                                                "show"
                                        ]
                                    ]
                            , type_ =
                                if settings.passwordVisible then
                                    "text"

                                else
                                    "password"
                            , value = settings.password
                            , placeholder = ""
                            , autocomplete = Just "password"
                            }
                        , viewMode (open && support) settings.mode
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
                        , if settings.persistent && via /= Backend.Local then
                            Html.div [ Attr.class "lia-classroom__local-fields" ]
                                [ Backend.input
                                    { active = open && support
                                    , msg = LocalName
                                    , label = Html.text "Name (local)"
                                    , type_ = "text"
                                    , value = settings.title
                                    , placeholder = "A name to recognize this room by, e.g. \"Media Informatics Monday\""
                                    , autocomplete = Nothing
                                    }
                                , Backend.input
                                    { active = open && support
                                    , msg = LocalNote
                                    , label = Html.text "Note (local)"
                                    , type_ = "text"
                                    , value = settings.notes
                                    , placeholder = "Optional, e.g. \"Lecture, Monday 10:00\""
                                    , autocomplete = Nothing
                                    }
                                ]

                          else
                            Html.text ""
                        , button settings
                        , viewError settings.error
                        ]
                    , Html.div [ Attr.class "lia-classroom__divider" ] []
                    , Html.div [ Attr.class "lia-classroom__info" ]
                        [ Html.div [ Attr.class "lia-classroom__info-header" ]
                            [ Html.div [ Attr.class "lia-classroom__card-icon" ]
                                [ Backend.icon via ]
                            , Html.div []
                                [ Html.h2 [] [ Backend.toString False via |> Html.text ]
                                , Html.p [ Attr.class "lia-classroom__tagline" ] [ Html.text (Backend.tagline via) ]
                                ]
                            ]
                        , Html.div [ Attr.class "lia-classroom__badges" ]
                            (via |> Backend.badges |> List.map Backend.badge)
                        , Backend.infoOn support via
                        , Backend.view
                            (open && support)
                            via
                            |> Html.map Config
                            |> Html.map Backend
                        ]
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


{-| Show the locally saved classrooms as a card grid. Only shown on the
overview page (no backend selected yet) — once a backend is picked, the
form takes over and the cards would just be visual clutter. The "Own Notes"
entry (if it has ever been connected to) is always pinned as its own tile
rather than a regular deletable row.
-}
savedList : Sync.Settings -> Html Msg
savedList settings =
    case settings.state of
        Sync.Disconnected ->
            let
                notes =
                    settings.saved |> List.filter isNotesEntry |> List.head
            in
            settings.saved
                |> List.filter (isNotesEntry >> not)
                |> List.map (savedCard settings.deletePopup)
                |> (::) (notesCard notes)
                |> (\cards ->
                        Html.div [ Attr.style "margin-block-start" "2rem" ]
                            [ Html.span [ Attr.class "lia-label" ] [ Html.text "Your classrooms" ]
                            , Html.div [ Attr.class "lia-classroom__cards" ] cards
                            ]
                   )

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


{-| The pinned "Own Notes" shortcut. Shows the last-used date once the
notes room has actually been connected to at least once; before that,
there is nothing to show a date for. Not user-editable (title/notes),
unlike regular saved-classroom cards, since it may not have a persisted
entry yet.
-}
notesCard : Maybe Classroom.Entry -> Html Msg
notesCard entry =
    Html.article [ Attr.class "lia-card lia-classroom__card" ]
        [ cardTop (Backend.icon Backend.Local) "Offline"
        , Html.div [ Attr.class "lia-card__content" ]
            [ Html.header [ Attr.class "lia-card__header" ]
                [ Html.span [ Attr.class "lia-card__title" ] [ Html.text "Own Notes" ]
                ]
            , Html.p [ Attr.class "lia-card__subtitle" ] [ Html.text "Offline local notes" ]
            , Html.footer [ Attr.class "lia-card__footer" ]
                [ entry
                    |> Maybe.map (.updated >> dateSpan)
                    |> Maybe.withDefault (Html.text "")
                , btnIcon
                    { msg = Just OpenNotes
                    , title = "Open your own notes"
                    , tabbable = True
                    , icon = "icon-login"
                    }
                    [ Attr.class "lia-btn--transparent lia-btn--tag px-1"
                    , Attr.style "color" "turquoise"
                    , Attr.style "border" "1px solid turquoise"
                    ]
                ]
            ]
        ]


dateSpan : Int -> Html msg
dateSpan updated =
    Html.span [ Attr.class "lia-classroom__date" ] [ Html.text (formatDate updated) ]


{-| A card's top row: the (already prominent) backend icon on the left, and
a small text-only backend-name badge on the right — no icon in the badge
itself, since the icon to its left already identifies the backend.
-}
cardTop : Html msg -> String -> Html msg
cardTop backendIcon label =
    Html.div [ Attr.class "lia-classroom__card-top" ]
        [ Html.div [ Attr.class "lia-classroom__card-icon" ] [ backendIcon ]
        , Html.span [ Attr.class "lia-classroom__card-backend" ] [ Html.text label ]
        ]


{-| The mode (Shared/Summary/Details) a saved classroom was last used with,
plus — since only the initiator sees the aggregated overview outside of
Shared mode — whether this browser was that initiator the last time it
connected (mirrored from the live `"ownership"` event, see
`Lia.Sync.Update`).
-}
modeBadge : Int -> Bool -> Html msg
modeBadge modeInt owner =
    let
        ( emoji, label, modifier ) =
            case Sync.toClassroomMode modeInt of
                Shared ->
                    ( "☮️", "Shared", "lia-classroom__mode--shared" )

                Summary ->
                    ( "🛂", "Summary", "lia-classroom__mode--summary" )

                Details ->
                    ( "🛰️", "Details", "lia-classroom__mode--details" )
    in
    Html.span [ Attr.class "lia-classroom__mode", Attr.class modifier ]
        [ Html.text (emoji ++ " " ++ label)
        , if owner then
            Html.text " ✨ owner"

          else
            Html.text ""
        ]


{-| A saved classroom's card, shown only on the overview page. Icon on the
left; the custom (editable) title and the room's actual name to its right;
the backend badge on the far right. Title is freely editable (local update
on every keystroke via `EditMeta`, persisted on blur via `SaveMeta`). Notes
are read-only here (and only shown if one was actually written) — editing
notes happens on the classroom's own configuration page, which doesn't
render cards at all.
-}
savedCard : Maybe ( String, String ) -> Classroom.Entry -> Html Msg
savedCard deletePopup entry =
    Html.article [ Attr.class "lia-card lia-classroom__card" ]
        [ Html.div [ Attr.class "lia-classroom__card-top" ]
            [ Html.div [ Attr.class "lia-classroom__card-icon" ]
                [ entry.backend
                    |> Backend.fromString
                    |> Maybe.map Backend.icon
                    |> Maybe.withDefault (Html.text "")
                ]
            , Html.div [ Attr.class "lia-classroom__card-heading" ]
                [ Html.input
                    [ Attr.class "lia-classroom__card-title"
                    , Attr.value (entry.title |> Maybe.withDefault "")
                    , Attr.placeholder entry.room
                    , Event.onInput (\title -> EditMeta entry title (entry.notes |> Maybe.withDefault ""))
                    , Event.onBlur (SaveMeta entry)
                    ]
                    []
                , Html.p [ Attr.class "lia-card__subtitle" ] [ Html.text entry.room ]
                ]
            , Html.span [ Attr.class "lia-classroom__card-backend" ]
                [ entry.backend
                    |> Backend.fromString
                    |> Maybe.map (Backend.toString False)
                    |> Maybe.withDefault ""
                    |> Html.text
                ]
            ]
        , Html.div [ Attr.class "lia-card__content" ]
            [ case entry.notes of
                Just notes ->
                    if String.isEmpty notes then
                        Html.text ""

                    else
                        Html.p [ Attr.class "lia-classroom__card-notes-view" ] [ Html.text notes ]

                Nothing ->
                    Html.text ""
            , Html.footer [ Attr.class "lia-card__footer" ]
                [ Html.div [ Attr.class "lia-classroom__card-meta" ]
                    [ modeBadge entry.mode entry.owner
                    , dateSpan entry.updated
                    ]
                , Html.div [ Attr.class "lia-classroom__card-controls" ]
                    [ case deletePopup of
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
                    , btnIcon
                        { msg = Just (LoadClassroom entry)
                        , title = "Edit this classroom's settings before connecting"
                        , tabbable = True
                        , icon = "icon-pencil"
                        }
                        [ Attr.class "lia-btn--transparent lia-btn--tag px-1 border-grey" ]
                    , btnIcon
                        { msg = Just (ConnectClassroom entry)
                        , title = "Connect to this classroom"
                        , tabbable = True
                        , icon = "icon-login"
                        }
                        [ Attr.class "lia-btn--transparent lia-btn--tag px-1"
                        , Attr.style "color" "turquoise"
                        , Attr.style "border" "1px solid turquoise"
                        ]
                    ]
                ]
            ]
        ]


deleteBtn : Classroom.Entry -> Html Msg
deleteBtn entry =
    btnIcon
        { msg = Just (AskDeleteClassroom entry.room entry.backend)
        , title = "Delete this saved classroom"
        , tabbable = True
        , icon = "icon-trash"
        }
        [ Attr.class "lia-btn--tag lia-btn--transparent px-1"
        , Attr.style "color" "red"
        , Attr.style "border" "1px solid red"
        ]


select : Bool -> Sync -> Html Msg
select editable sync =
    Html.map Backend <|
        Html.label []
            [ Html.span [ Attr.class "lia-label" ] [ Html.text "Backend" ]
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
        [ maybeSelect via
        , via
            |> Maybe.map (Tuple.second >> Backend.badges >> String.join " · ")
            |> Maybe.map (Html.text >> List.singleton >> Html.span [ Attr.class "lia-classroom__option-tags" ])
            |> Maybe.withDefault (Html.text "")
        ]


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


viewMode : Bool -> ClassroomMode -> Html Msg
viewMode active mode =
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
                [ if active then
                    Event.onInput ClassroomMode

                  else
                    Attr.disabled True
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
                    [ Html.text "☮️ Shared" ]
                , Html.option
                    [ Attr.value "1"
                    , Attr.selected <| mode == Summary
                    ]
                    [ Html.text "🛂 Summary" ]
                , Html.option
                    [ Attr.value "2"
                    , Attr.selected <| mode == Details
                    ]
                    [ Html.text "🛰️ Details" ]
                ]
            , Html.span []
                [ Html.text <|
                    case mode of
                        Shared ->
                            "All are equal and see the summary of quizzes and surveys."

                        Summary ->
                            "Only the initiator can see the summaries."

                        Details ->
                            "(Kremlin mode) The initiator can see also details per participant."
                ]
            ]
        ]
