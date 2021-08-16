port module Lia.Sync.Update exposing
    ( Msg(..)
    , send
    , subscriptions
    , update
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Sync.Types exposing (Settings, State(..), isConnected)
import Port.Event as Event exposing (Event)
import Return exposing (Return)


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


update : Msg -> Settings -> Return Settings Msg sub
update msg model =
    case msg of
        Handle event ->
            let
                _ =
                    Debug.log "SYNC" event
            in
            case event.topic of
                "connect" ->
                    Return.val <|
                        if bool event.message then
                            { model | state = Connected }

                        else
                            { model | state = Disconnected }

                "sync" ->
                    model
                        |> Return.val
                        |> Return.batchEvents
                            (case Event.decode event.message of
                                Ok message ->
                                    [ message ]

                                Err _ ->
                                    []
                            )

                _ ->
                    Return.val model

        Password str ->
            { model | password = str }
                |> Return.val

        Username str ->
            { model | username = str }
                |> Return.val

        Room str ->
            { model | room = str }
                |> Return.val

        Connect ->
            { model | state = Pending }
                |> Return.val
                |> Return.cmd
                    ([ ( "course", JE.string model.course )
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
                        |> sync "connect"
                    )

        Disconnect ->
            { model | state = Pending }
                |> Return.val
                |> Return.cmd (sync "disconnect" JE.null)


sync : String -> JE.Value -> Cmd Msg
sync topic =
    Event topic -1 >> syncOut


send : Settings -> List Event -> Cmd Msg
send settings events =
    if isConnected settings then
        events
            |> List.map (Event.encode >> sync "sync")
            |> Cmd.batch

    else
        Cmd.none


bool : JE.Value -> Bool
bool =
    JD.decodeValue JD.bool
        >> Result.toMaybe
        >> Maybe.withDefault False
