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


handle : Event -> Settings -> Return Settings Msg sub
handle event =
    update (Handle event)


update : Msg -> Settings -> Return Settings Msg sub
update msg model =
    case msg of
        Handle event ->
            Return.val <|
                case Event.destructure event of
                    Just ( "connect", _, message ) ->
                        if bool message then
                            { model | state = Connected }

                        else
                            { model | state = Disconnected }

                    Just ( "disconnect", _, _ ) ->
                        { model | state = Disconnected }

                    _ ->
                        model

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
                        |> Event.init "connect"
                    )

        Disconnect ->
            { model | state = Pending }
                |> Return.val
                |> Return.sync (Event.empty "disconnect")


bool : JE.Value -> Bool
bool =
    JD.decodeValue JD.bool
        >> Result.toMaybe
        >> Maybe.withDefault False
