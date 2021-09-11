module Lia.Sync.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Sync.Types exposing (Settings, State(..))
import Port.Event as Event exposing (Event)
import Return exposing (Return)


type Msg
    = Room String
    | Username String
    | Password String
    | Connect
    | Disconnect
    | Handle Event


handle : JE.Value -> Settings -> Return Settings Msg sub
handle json =
    case Event.decode json |> Debug.log "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs" of
        Ok event ->
            update (Handle event)

        Err _ ->
            Return.val >> Return.warn "Sync.handle: "


update : Msg -> Settings -> Return Settings Msg sub
update msg model =
    case msg of
        Handle event ->
            case event.topic of
                "connect" ->
                    if bool event.message then
                        Return.val { model | state = Connected }

                    else
                        Return.val { model | state = Disconnected }

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
                |> Return.sync
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
                        |> Event "connect" -1
                    )

        Disconnect ->
            { model | state = Pending }
                |> Return.val
                |> Return.sync (Event "disconnect" -1 JE.null)


bool : JE.Value -> Bool
bool =
    JD.decodeValue JD.bool
        >> Result.toMaybe
        >> Maybe.withDefault False
