module Lia.Sync.View exposing (view)

import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Lia.Settings.Update exposing (Msg(..))
import Lia.Sync.Types as Sync exposing (State(..), Sync)
import Lia.Sync.Update exposing (Msg(..), SyncMsg(..))
import Lia.Sync.Via as Backend exposing (Backend)
import Lia.Utils exposing (btn)


view : Sync.Settings -> Html Msg
view settings =
    Html.div []
        [ Html.h1 [] [ Html.text "Classroom" ]
        , select settings.sync
        , Html.br [] []
        , Html.br [] []
        , case settings.sync.select of
            Nothing ->
                Html.text ""

            _ ->
                Html.div []
                    [ input Room "room" "input" settings.room
                    , Html.br [] []
                    , Html.br [] []
                    , input Username "user" "input" settings.username
                    , Html.br [] []
                    , Html.br [] []
                    , input Password "maybe password" "password" settings.password
                    , Html.br [] []
                    , Html.br [] []
                    , button settings.state
                    ]
        ]


input msg label type_ value =
    Html.label []
        [ Html.span [ Attr.class "lia-label" ] [ Html.text label ]
        , Html.br [] []
        , Html.input
            [ Event.onInput msg
            , Attr.value value
            , Attr.style "color" "black"
            , Attr.type_ type_
            ]
            []
        ]


select : Sync -> Html Msg
select sync =
    Html.map Backend <|
        Html.label []
            [ Html.span [ Attr.class "lia-label" ] [ Html.text "via Backend" ]
            , Html.br [] []
            , Html.div
                [ Attr.class "lia-dropdown"
                , not sync.open
                    |> Open
                    |> Event.onClick
                ]
                [ Html.div
                    [ Attr.class "lia-dropdown__selected"
                    , A11y_Widget.hidden False
                    , A11y_Role.button
                    , A11y_Widget.expanded sync.open
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
                    |> List.map (Just >> option)
                    |> (::) (option Nothing)
                    |> Html.div
                        [ Attr.class "lia-dropdown__options"
                        , Attr.class <|
                            if sync.open then
                                "is-visible"

                            else
                                "is-hidden"
                        ]
                ]
            ]


option : Maybe Backend -> Html SyncMsg
option via =
    Html.div
        [ Event.onClick (Select via) ]
        [ maybeSelect via ]


maybeSelect : Maybe Backend -> Html msg
maybeSelect =
    Maybe.map selectString >> Maybe.withDefault (Html.text "None")


selectString : Backend -> Html msg
selectString via =
    Html.span []
        [ Backend.icon via
        , Backend.toString via |> Html.text
        ]


button : State -> Html Msg
button state =
    case state of
        Disconnected ->
            btn
                { title = "connect"
                , msg = Just Connect
                , tabbable = True
                }
                []
                [ Html.text "connect" ]

        Connected _ ->
            btn
                { title = "disconnect"
                , msg = Just Disconnect
                , tabbable = True
                }
                []
                [ Html.text "disconnect" ]

        Pending ->
            btn
                { title = "pending"
                , msg = Nothing
                , tabbable = False
                }
                []
                [ Html.text "pending" ]
