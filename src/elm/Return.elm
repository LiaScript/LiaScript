module Return exposing
    ( Return
    , cmd
    , event
    , events
    , map
    , script
    , value
    )

import Lia.Markdown.Effect.Script.Update as Script
import Port.Event exposing (Event)


type alias Return model msg sub =
    { value : model
    , cmd : Cmd msg
    , script : Maybe (Script.Msg sub)
    , events : List Event
    }


value : model -> Return model cmd sub
value model =
    Return
        model
        Cmd.none
        Nothing
        []


event : Event -> Return model msg sub -> Return model msg sub
event e r =
    { r | events = e :: r.events }


events : List Event -> Return model msg sub -> Return model msg sub
events e r =
    { r | events = List.append r.events e }


cmd : Cmd msg -> Return model msg sub -> Return model msg sub
cmd c r =
    { r | cmd = c }


script : Script.Msg sub -> Return model msg sub -> Return model msg sub
script s r =
    { r | script = Just s }


map : (model -> model_) -> Return model msg sub -> Return model_ msg sub
map fn r =
    { value = fn r.value
    , cmd = r.cmd
    , script = r.script
    , events = r.events
    }



--{ r | value = fn r.value }
