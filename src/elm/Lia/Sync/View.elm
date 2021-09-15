module Lia.Sync.View exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Lia.Sync.Types as Sync exposing (State(..))
import Lia.Sync.Update exposing (Msg(..))
import Lia.Utils exposing (btn)


view : Sync.Settings -> Html Msg
view settings =
    Html.div []
        [ Html.h1 [] [ Html.text "Classroom" ]
        , input Room "room" "input" settings.room
        , Html.br [] []
        , Html.br [] []
        , input Username "user" "input" settings.username
        , Html.br [] []
        , Html.br [] []
        , input Password "maybe password" "password" settings.password
        , Html.br [] []
        , Html.br [] []
        , case settings.state of
            Disconnected ->
                btn
                    { title = "connect"
                    , msg = Just Connect
                    , tabbable = True
                    }
                    []
                    [ Html.text "connect" ]

            Connected ->
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
