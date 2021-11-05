module Return exposing
    ( Return
    , batchCmd
    , batchEvent
    , batchEvents
    , cmd
    , error
    , log
    , mapCmd
    , mapEvents
    , mapSync
    , mapVal
    , mapValCmd
    , replace
    , script
    , sync
    , syncAppend
    , syncMsg
    , val
    , warn
    )

import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script
import Port.Event as Event exposing (Event)


type alias Return model msg sub =
    { value : model
    , command : Cmd msg
    , events : List Event
    , sub : Maybe (Script.Msg sub)
    , debug : List Event
    , synchronize : List Event
    }


val : model -> Return model cmd sub
val model =
    Return
        model
        Cmd.none
        []
        Nothing
        []
        []


batchEvent : Event -> Return model msg sub -> Return model msg sub
batchEvent e r =
    { r | events = e :: r.events }


batchEvents : List Event -> Return model msg sub -> Return model msg sub
batchEvents e r =
    { r | events = List.append r.events e }


upgrade : String -> Int -> List Event -> List Event
upgrade topic id =
    List.map (Event.pushWithId topic id)


mapEvents : String -> Int -> Return model msg sub -> Return model msg sub
mapEvents topic id r =
    { r
        | events = upgrade topic id r.events
        , synchronize = upgrade topic id r.synchronize
    }


cmd : Cmd msg -> Return model msg sub -> Return model msg sub
cmd c r =
    { r | command = c }


mapCmd : (msgA -> msgB) -> Return model msgA sub -> Return model msgB sub
mapCmd fn { value, command, sub, events, debug, synchronize } =
    { value = value
    , command = Cmd.map fn command
    , events = events
    , sub = sub
    , debug = debug
    , synchronize = synchronize
    }


mapValCmd : (modelA -> modelB) -> (msgA -> msgB) -> Return modelA msgA sub -> Return modelB msgB sub
mapValCmd fnVal fnMsg { value, command, sub, events, debug, synchronize } =
    { value = fnVal value
    , command = Cmd.map fnMsg command
    , events = events
    , sub = sub
    , debug = debug
    , synchronize = synchronize
    }


batchCmd : List (Cmd msg) -> Return model msg sub -> Return model msg sub
batchCmd cmds r =
    { r | command = Cmd.batch (r.command :: cmds) }


script : Script.Msg sub -> Return model msg sub -> Return model msg sub
script s r =
    { r | sub = Just s }


mapVal : (modelA -> modelB) -> Return modelA msg sub -> Return modelB msg sub
mapVal fn { value, command, events, sub, debug, synchronize } =
    { value = fn value
    , command = command
    , events = events
    , sub = sub
    , debug = debug
    , synchronize = synchronize
    }


replace : Return model_ msg sub -> model -> Return model msg sub
replace r m =
    mapVal (always m) r


sync : Event -> Return model msg sub -> Return model msg sub
sync event r =
    { r | synchronize = Event.push "sync" event :: r.synchronize }


syncMsg : Int -> JE.Value -> Return model msg sub -> Return model msg sub
syncMsg id msg r =
    { r | synchronize = Event.initWithId "sync" id msg :: r.synchronize }


mapSync : String -> Maybe Int -> Return model msg sub -> Return model msg sub
mapSync topic id r =
    { r
        | synchronize =
            case id of
                Nothing ->
                    List.map (Event.push topic) r.synchronize

                Just i ->
                    upgrade topic i r.synchronize
    }


syncAppend : List Event -> Return model msg sub -> Return model msg sub
syncAppend events r =
    { r | synchronize = List.append events r.synchronize }


log : String -> Return model msg sub -> Return model msg sub
log =
    debug_ 0


warn : String -> Return model msg sub -> Return model msg sub
warn =
    debug_ 1


error : String -> Return model msg sub -> Return model msg sub
error =
    debug_ 2


debug_ : Int -> String -> Return model msg sub -> Return model msg sub
debug_ id message r =
    { r | debug = Event.initWithId "log" id (JE.string message) :: r.debug }
