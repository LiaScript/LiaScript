port module Lia.Sync.Update exposing
    ( Msg(..)
    , subscriptions
    , update
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Sync.Chat as Chat
import Lia.Sync.Types exposing (Settings, State(..))
import Port.Event as Event exposing (Event)


port syncOut : Event -> Cmd msg


port syncIn : (Event -> msg) -> Sub msg


subscriptions : Sub Msg
subscriptions =
    syncIn Handle


type Msg
    = Room String
    | Username String
    | Password String
    | Connect
    | Disconnect
    | Handle Event
    | UpdateChat Chat.Msg


update : Msg -> Settings -> ( Settings, Cmd Msg )
update msg model =
    case msg of
        Handle event ->
            let
                _ =
                    Debug.log "SYNC" event
            in
            case event.topic of
                "connect" ->
                    if bool event.message then
                        ( { model | state = Connected }, Cmd.none )

                    else
                        ( { model | state = Disconnected }, Cmd.none )

                "chat" ->
                    ( { model
                        | chat =
                            event.message
                                |> Event.decode
                                |> Result.map (Chat.handle model.chat)
                                |> Result.withDefault model.chat
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        UpdateChat subMsg ->
            case Chat.update subMsg model.username model.chat of
                ( chat, Nothing ) ->
                    ( { model | chat = chat }, Cmd.none )

                ( chat, Just event ) ->
                    ( { model | chat = chat }
                    , event
                        |> Event.encode
                        |> Event "chat" -1
                        |> syncOut
                    )

        Password str ->
            ( { model | password = str }, Cmd.none )

        Username str ->
            ( { model | username = str }, Cmd.none )

        Room str ->
            ( { model | room = str }, Cmd.none )

        Connect ->
            ( { model | state = Pending }
            , [ ( "course", JE.string model.course )
              , ( "room", JE.string model.room )
              , ( "username", JE.string model.username )
              , ( "password"
                , if String.isEmpty model.password then
                    JE.null

                  else
                    JE.string model.password
                )
              ]
                |> JE.object
                |> Event "connect" -1
                |> syncOut
            )

        Disconnect ->
            ( { model | state = Pending }
            , JE.null
                |> Event "disconnect" -1
                |> syncOut
            )


bool : JE.Value -> Bool
bool =
    JD.decodeValue JD.bool
        >> Result.toMaybe
        >> Maybe.withDefault False
