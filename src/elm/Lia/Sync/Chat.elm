module Lia.Sync.Chat exposing
    ( Chat
    , Msg
    , handle
    , init
    , update
    , view
    )

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Json.Decode as JD
import Json.Encode as JE
import Port.Event exposing (Event)


type alias Message =
    { user : String
    , msg : String
    }


type alias Chat =
    { visible : Bool
    , messages : Array Message
    , input : String
    }


type Msg
    = Input String
    | Send
    | Handle Event


init : Chat
init =
    Chat True Array.empty ""


handle : Chat -> Event -> Chat
handle chat event =
    chat
        |> update (Handle event) ""
        |> Tuple.first


update : Msg -> String -> Chat -> ( Chat, Maybe Event )
update msg username chat =
    case msg of
        Input str ->
            ( { chat | input = str }, Nothing )

        Send ->
            ( { chat
                | messages = Array.push (Message username chat.input) chat.messages
                , input = ""
              }
            , Message username chat.input
                |> encodeMsg
            )

        Handle event ->
            case event.topic of
                "msg" ->
                    ( { chat
                        | messages =
                            event.message
                                |> decodeMsg
                                |> Maybe.map (\m -> Array.push m chat.messages)
                                |> Maybe.withDefault chat.messages
                      }
                    , Nothing
                    )

                _ ->
                    ( chat, Nothing )


encodeMsg : Message -> Maybe Event
encodeMsg { user, msg } =
    [ ( "user", JE.string user )
    , ( "msg", JE.string msg )
    ]
        |> JE.object
        |> Event "msg" -1
        |> Just


decodeMsg : JD.Value -> Maybe Message
decodeMsg =
    JD.decodeValue
        (JD.map2 Message
            (JD.field "user" JD.string)
            (JD.field "msg" JD.string)
        )
        >> Result.toMaybe


view : Chat -> Html Msg
view chat =
    if chat.visible then
        [ chat.messages
            |> Array.toList
            |> List.indexedMap viewMessage
            |> Html.div []
        , viewInput chat.input
        ]
            |> Html.div
                [ Attr.style "z-index" "1000"
                , Attr.style "position" "inherit"
                , Attr.style "top" "100px"
                , Attr.style "right" "400px"
                , Attr.style "background" "red"
                ]

    else
        Html.text ""


viewMessage : Int -> Message -> Html msg
viewMessage _ msg =
    Html.div []
        [ Html.text msg.user
        , Html.br [] []
        , Html.text msg.msg
        ]


viewInput : String -> Html Msg
viewInput str =
    Html.div []
        [ Html.input
            [ Attr.value str
            , Html.Events.onInput Input
            ]
            []
        , Html.button
            [ Html.Events.onClick Send ]
            [ Html.text "send" ]
        ]
