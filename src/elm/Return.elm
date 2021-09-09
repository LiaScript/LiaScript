module Return exposing
    ( Return
    , batchCmd
    , batchEvent
    , batchEvents
    , cmd
    , mapCmd
    , mapEvents
    , mapVal
    , replace
    , script
    , val
    )

import Lia.Markdown.Effect.Script.Types as Script
import Port.Event as Event exposing (Event)


type alias Return model msg sub =
    { value : model
    , command : Cmd msg
    , events : List Event
    , sub : Maybe (Script.Msg sub)
    }


val : model -> Return model cmd sub
val model =
    Return
        model
        Cmd.none
        []
        Nothing


batchEvent : Event -> Return model msg sub -> Return model msg sub
batchEvent e r =
    { r | events = e :: r.events }


batchEvents : List Event -> Return model msg sub -> Return model msg sub
batchEvents e r =
    { r | events = List.append r.events e }


mapEvents : String -> Int -> Return model msg sub -> Return model msg sub
mapEvents topic id r =
    { r | events = List.map (Event.encode >> Event topic id) r.events }


cmd : Cmd msg -> Return model msg sub -> Return model msg sub
cmd c r =
    { r | command = c }


mapCmd : (msgA -> msgB) -> Return model msgA sub -> Return model msgB sub
mapCmd fn { value, command, sub, events } =
    { value = value
    , command = Cmd.map fn command
    , events = events
    , sub = sub
    }


batchCmd : List (Cmd msg) -> Return model msg sub -> Return model msg sub
batchCmd cmds r =
    { r | command = Cmd.batch (r.command :: cmds) }


script : Script.Msg sub -> Return model msg sub -> Return model msg sub
script s r =
    { r | sub = Just s }


mapVal : (model -> model_) -> Return model msg sub -> Return model_ msg sub
mapVal fn { value, command, events, sub } =
    { value = fn value
    , command = command
    , events = events
    , sub = sub
    }


replace : Return model_ msg sub -> model -> Return model msg sub
replace r m =
    mapVal (always m) r



--{ r | value = fn r.value }
