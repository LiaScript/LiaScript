port module Lia.Sync.Update exposing
    ( Msg(..)
    , subscriptions
    , update
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Sync.Types exposing (Settings, State(..))
import Port.Event exposing (Event)


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

                _ ->
                    ( model, Cmd.none )

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
