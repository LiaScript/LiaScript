module Return exposing
    ( Return
    , batchCmd
    , batchEvent
    , batchEvents
    , cmd
    , doSync
    , mapCmd
    , mapEvents
    , mapVal
    , mapValCmd
    , replace
    , script
    , val
    )

import Lia.Markdown.Effect.Script.Types as Script
import Service.Event as Event exposing (Event)


type alias Return model msg sub =
    { value : model
    , command : Cmd msg
    , events : List Event
    , sub : Maybe (Script.Msg sub)
    , synchronize : Bool
    }


val : model -> Return model cmd sub
val model =
    Return
        model
        Cmd.none
        []
        Nothing
        False


batchEvent : Event -> Return model msg sub -> Return model msg sub
batchEvent e r =
    { r
        | events =
            if Event.notNone e then
                e :: r.events

            else
                r.events
    }


batchEvents : List Event -> Return model msg sub -> Return model msg sub
batchEvents e r =
    { r
        | events =
            e
                |> List.filter Event.notNone
                |> List.append r.events
    }


upgrade : String -> Int -> List Event -> List Event
upgrade topic id =
    List.map (Event.pushWithId topic id)


mapEvents : String -> Int -> Return model msg sub -> Return model msg sub
mapEvents topic id r =
    { r | events = upgrade topic id r.events }


cmd : Cmd msg -> Return model msg sub -> Return model msg sub
cmd c r =
    { r | command = c }


mapCmd : (msgA -> msgB) -> Return model msgA sub -> Return model msgB sub
mapCmd fn { value, command, sub, events, synchronize } =
    { value = value
    , command = Cmd.map fn command
    , events = events
    , sub = sub
    , synchronize = synchronize
    }


mapValCmd : (modelA -> modelB) -> (msgA -> msgB) -> Return modelA msgA sub -> Return modelB msgB sub
mapValCmd fnVal fnMsg { value, command, sub, events, synchronize } =
    { value = fnVal value
    , command = Cmd.map fnMsg command
    , events = events
    , sub = sub
    , synchronize = synchronize
    }


batchCmd : List (Cmd msg) -> Return model msg sub -> Return model msg sub
batchCmd cmds r =
    { r | command = Cmd.batch (r.command :: cmds) }


script : Script.Msg sub -> Return model msg sub -> Return model msg sub
script s r =
    { r | sub = Just s }


mapVal : (modelA -> modelB) -> Return modelA msg sub -> Return modelB msg sub
mapVal fn { value, command, events, sub, synchronize } =
    { value = fn value
    , command = command
    , events = events
    , sub = sub
    , synchronize = synchronize
    }


replace : Return model_ msg sub -> model -> Return model msg sub
replace r m =
    mapVal (always m) r


doSync : Return model msg sub -> Return model msg sub
doSync r =
    { r | synchronize = True }
