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
import Lia.Utils exposing (btn, btnIcon, formatDate, icon)


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
                    [ Html.p [ Attr.class "lia-classroom__subtitle" ]
                        [ Html.text "Work together with your class in real time — share quizzes, surveys, and live sessions. No accounts needed." ]
                    , Html.div [ Attr.class "lia-classroom__quick-row" ]
                        [ Html.div [ Attr.class "lia-classroom__quick-btn-wrap" ]
                            [ Html.span [ Attr.class "lia-label", A11y_Aria.hidden True ] [ Html.text "\u{00A0}" ]
                            , Html.br [] []
                            , btnIcon
                                { msg = Just OpenNotes
                                , title = "Just for me — local notes, no connection"
                                , tabbable = True
                                , icon = "icon-pencil"
                                }
                                [ Attr.class "lia-classroom__notes-btn" ]
                            ]
                        , Html.div [ Attr.class "lia-classroom__dropdown-wrap" ] [ select "Connect to a classroom" open settings.sync ]
                        ]
                    , savedList settings
                    , infoDetails
                    ]

            Just ( support, via ) ->
                Html.div [ Attr.class "lia-classroom__columns" ]
                    [ Html.div [ Attr.class "lia-classroom__form" ]
                        [ select "Backend" open settings.sync
                        , Html.label []
                            [ Html.span
                                [ Attr.class "lia-label"
                                , Attr.style "margin-block-start" "2rem"
                                , Attr.style "width" "100%"
                                ]
                                [ Html.text "Room" ]
                            , Html.div [ Attr.class "lia-classroom__field-row" ]
                                [ Html.input
                                    [ if open && support then
                                        Event.onInput Room

                                      else
                                        Attr.disabled True
                                    , Attr.value settings.room
                                    , Attr.style "color" "black"
                                    , Attr.type_ "text"
                                    , Attr.style "width" "100%"
                                    , Attr.placeholder "Just any kind of typeable name"
                                    , Attr.name "room"
                                    , Attr.attribute "autocomplete" "room"
                                    ]
                                    []
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
                                    [ Attr.class "lia-btn--outline lia-classroom__field-btn" ]
                                ]
                            ]
                        , if via /= Backend.Local then
                            Backend.input
                                { active = open && support
                                , msg = Name
                                , label = Html.text "Your name (optional)"
                                , type_ = "text"
                                , value = settings.name
                                , placeholder = "Enter your name to be displayed to others"
                                , autocomplete = Just "name"
                                }

                          else
                            Html.text ""
                        , Backend.input
                            { active = open && support
                            , msg = Password
                            , label =
                                Html.span
                                    [ Attr.style "display" "flex"
                                    , Attr.style "justify-content" "space-between"
                                    , Attr.style "align-items" "center"
                                    , Attr.style "width" "100%"
                                    ]
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
                        , if via /= Backend.Local then
                            viewMode (open && support) settings.mode

                          else
                            Html.text ""
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
                        , if settings.persistent || via == Backend.Local then
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


{-| The long, static "how does this work" explanation, tucked behind a
collapsed `<details>` disclosure instead of always taking up space on the
overview page - styled the same way as `Backend.Via`'s own "Infrastructure
settings" disclosure, for visual consistency.
-}
infoDetails : Html msg
infoDetails =
    Html.details [ Attr.style "margin-block-start" "2rem" ]
        [ Html.summary
            [ Attr.style "cursor" "pointer"
            , Attr.style "font-weight" "bold"
            , Attr.style "color" "white"
            ]
            [ Html.text "What can a classroom do?" ]
        , Backend.info
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
form takes over and the cards would just be visual clutter. The local
"Own Notes" room is excluded here - it has its own quick-access button
next to the backend dropdown instead of a grid tile.
-}
savedList : Sync.Settings -> Html Msg
savedList settings =
    case settings.state of
        Sync.Disconnected ->
            case settings.saved |> List.filter (isNotesEntry >> not) of
                [] ->
                    Html.text ""

                entries ->
                    Html.div [ Attr.style "margin-block-start" "2rem" ]
                        [ Html.span [ Attr.class "lia-label" ] [ Html.text "Your classrooms" ]
                        , Html.div [ Attr.class "lia-classroom__cards" ]
                            (List.map (savedCard settings.deletePopup) entries)
                        ]

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


dateSpan : Int -> Html msg
dateSpan updated =
    Html.span [ Attr.class "lia-classroom__date" ] [ Html.text (formatDate updated) ]


{-| The mode (Shared/Summary/Details) a saved classroom was last used with,
plus — since only the initiator sees the aggregated overview outside of
Shared mode — whether this browser was that initiator the last time it
connected (mirrored from the live `"ownership"` event, see
`Lia.Sync.Update`).
-}
modeBadge : Int -> Html msg
modeBadge modeInt =
    let
        ( label, modifier ) =
            case Sync.toClassroomMode modeInt of
                Shared ->
                    ( "Shared", "lia-classroom__mode--shared" )

                Summary ->
                    ( "Summary", "lia-classroom__mode--summary" )

                Details ->
                    ( "Details", "lia-classroom__mode--details" )
    in
    Html.span
        [ Attr.class "lia-classroom__mode" ]
        [ Html.span [ Attr.class "lia-classroom__mode-dot", Attr.class modifier ] []
        , Html.text label
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
    let
        meta =
            { title = entry.title |> Maybe.withDefault ""
            , notes = entry.notes |> Maybe.withDefault ""
            , name = entry.name |> Maybe.withDefault ""
            }
    in
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
                    , Attr.value meta.title
                    , Attr.placeholder entry.room
                    , Event.onInput (\title -> EditMeta entry { meta | title = title })
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
            [ Html.textarea
                [ Attr.class "lia-classroom__card-notes"
                , Attr.rows 1
                , Attr.placeholder "Add a comment…"
                , Attr.value meta.notes
                , Event.onInput (\notes -> EditMeta entry { meta | notes = notes })
                , Event.onBlur (SaveMeta entry)
                ]
                []
            , Html.footer [ Attr.class "lia-card__footer" ]
                [ Html.div [ Attr.class "lia-classroom__card-row" ]
                    [ Html.div [ Attr.class "lia-classroom__card-mode-row" ]
                        [ modeBadge entry.mode ]
                    , if entry.owner then
                        Html.span [ Attr.class "lia-classroom__card-tag" ] [ Html.text "Initiator" ]

                      else
                        Html.text ""
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
                            , title = "Connect to this classroom"
                            , tabbable = True
                            , icon = "icon-login"
                            }
                            [ Attr.class "lia-classroom__card-ghost lia-classroom__card-ghost--accent" ]
                        ]
                    ]
                , Html.div [ Attr.class "lia-classroom__card-meta-row" ]
                    [ if String.isEmpty meta.name then
                        Html.text ""

                      else
                        Html.span [ Attr.class "lia-classroom__card-user" ]
                            [ icon "icon-person" [ Attr.class "lia-classroom__card-user-icon" ]
                            , Html.span [ Attr.class "lia-classroom__card-user-name" ] [ Html.text meta.name ]
                            ]
                    , dateSpan entry.updated
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
        [ Attr.class "lia-classroom__card-ghost lia-classroom__card-ghost--danger" ]


select : String -> Bool -> Sync -> Html Msg
select label editable sync =
    Html.map Backend <|
        Html.label []
            [ Html.span [ Attr.class "lia-label" ] [ Html.text label ]
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
                    [ case sync.select of
                        Nothing ->
                            Html.text "Choose a backend…"

                        Just ( _, via ) ->
                            selectString via
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
    let
        attrs =
            [ Attr.style "margin-block-start" "2rem"
            , Attr.style "width" "100%"
            ]
    in
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
                attrs
                [ Html.text "connect" ]

        Connected _ ->
            btn
                { title = "disconnect"
                , msg = Just Disconnect
                , tabbable = True
                }
                attrs
                [ Html.text "disconnect" ]

        Pending ->
            btn
                { title = "pending"
                , msg = Nothing
                , tabbable = False
                }
                attrs
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
