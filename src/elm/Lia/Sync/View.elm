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
import Lia.Sync.Types as Sync exposing (State(..), Sync)
import Lia.Sync.Update exposing (Msg(..), SyncMsg(..))
import Lia.Sync.Via as Backend exposing (Backend)
import Lia.Utils exposing (btn, btnIcon)


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
                    [ savedList settings
                    , Backend.info
                    ]

            Just ( support, via ) ->
                Html.div []
                    [ Backend.input
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
                        , autocomplete = Nothing
                        }
                    , Backend.input
                        { active = open && support
                        , msg = Password
                        , label = Html.text "maybe password"
                        , type_ = "password"
                        , value = settings.password
                        , placeholder = ""
                        , autocomplete = Nothing
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


savedList : Sync.Settings -> Html Msg
savedList settings =
    case settings.state of
        Sync.Disconnected ->
            Html.div [ Attr.style "margin-block-start" "2rem" ]
                [ Html.span [ Attr.class "lia-label" ] [ Html.text "Saved Classrooms" ]
                , Html.div []
                    (notesTile :: List.map (savedItem settings.deletePopup) settings.saved)
                ]

        _ ->
            Html.text ""


notesTile : Html Msg
notesTile =
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
            ]
        ]


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
