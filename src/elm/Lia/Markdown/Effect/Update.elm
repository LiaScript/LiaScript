module Lia.Markdown.Effect.Update exposing
    ( Msg(..)
    , handle
    , has_next
    , has_previous
    , init
    , next
    , previous
    , ttsCancel
    , ttsReplay
    , update
    , updateSub
    )

import Browser.Dom as Dom
import Json.Decode as JD
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Effect.Model
    exposing
        ( Model
        , current_comment
        )
import Lia.Markdown.Effect.Script.Types as Script_ exposing (Scripts)
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Section exposing (SubSection)
import Port.Event exposing (Event)
import Port.TTS as TTS
import Return exposing (Return)
import Task


type Msg sub
    = Init Bool
    | Next
    | Previous
    | Send (List Event)
    | Mute Int
    | Rendered Bool Dom.Viewport
    | Handle Event
    | Script (Script_.Msg sub)


updateSub :
    { update : Scripts SubSection -> sub -> SubSection -> Return SubSection sub sub
    , handle : Scripts SubSection -> JE.Value -> SubSection -> Return SubSection sub sub
    , globals : Maybe Definition
    }
    -> Script_.Msg sub
    -> Model SubSection
    -> Return (Model SubSection) (Msg sub) sub
updateSub main msg =
    update main True (Script msg)


update :
    { update : Scripts SubSection -> sub -> SubSection -> Return SubSection sub sub
    , handle : Scripts SubSection -> JE.Value -> SubSection -> Return SubSection sub sub
    , globals : Maybe Definition
    }
    -> Bool
    -> Msg sub
    -> Model SubSection
    -> Return (Model SubSection) (Msg sub) sub
update main sound msg model =
    markRunning <|
        case msg of
            Init run_all_javascript ->
                model
                    |> Return.value
                    |> Return.cmd (Task.perform (Rendered run_all_javascript) Dom.getViewport)

            Next ->
                if has_next model then
                    { model | visible = model.visible + 1 }
                        |> execute main sound False 0

                else
                    Return.value model

            Previous ->
                if has_previous model then
                    { model | visible = model.visible - 1 }
                        |> execute main sound False 0

                else
                    Return.value model

            Mute id ->
                { model | speaking = Nothing }
                    |> Return.value
                    |> Return.event (TTS.mute id)

            Send event ->
                let
                    events =
                        scrollTo True "focused"
                            :: scrollTo False "lia-notes-active"
                            :: event
                in
                model
                    |> Return.value
                    |> Return.events
                        (case current_comment model of
                            Just ( id, _ ) ->
                                if sound then
                                    TTS.readFrom -1 id :: events

                                else
                                    events

                            _ ->
                                TTS.cancel :: events
                        )

            Rendered run_all_javascript _ ->
                execute main sound run_all_javascript 0 model

            Script childMsg ->
                model.javascript
                    |> Script.update main childMsg
                    |> Return.map (\v -> { model | javascript = v })
                    |> Return.cmdMap Script

            Handle event ->
                case event.topic of
                    "speak" ->
                        Return.value <|
                            case event.message |> JD.decodeValue JD.string of
                                Ok "start" ->
                                    { model | speaking = Just event.section }

                                Ok "stop" ->
                                    { model | speaking = Nothing }

                                _ ->
                                    model

                    _ ->
                        model.javascript
                            |> Script.update main (Script_.Handle event)
                            |> Return.map (\v -> { model | javascript = v })
                            |> Return.cmdMap Script


scrollTo : Bool -> String -> Event
scrollTo force =
    JE.string
        >> Event "scrollTo"
            (if force then
                -1

             else
                0
            )


markRunning : Return (Model a) (Msg sub) sub -> Return (Model a) (Msg sub) sub
markRunning return =
    return
        |> Return.map
            (\model ->
                { model
                    | javascript =
                        List.foldl
                            (\e js ->
                                if e.section < 0 then
                                    js

                                else
                                    Script.setRunning e.section True js
                            )
                            model.javascript
                            return.events
                }
            )


execute :
    { update : Scripts SubSection -> sub -> SubSection -> Return SubSection sub sub
    , handle : Scripts SubSection -> JE.Value -> SubSection -> Return SubSection sub sub
    , globals : Maybe Definition
    }
    -> Bool
    -> Bool
    -> Int
    -> Model SubSection
    -> Return (Model SubSection) (Msg sub) sub
execute main sound run_all delay model =
    let
        javascript =
            if run_all then
                Script.getAll model.javascript

            else
                Script.getVisible model.visible model.javascript
    in
    update main
        sound
        (javascript
            |> List.map (Script.execute delay)
            --|> (::) (Event "persistent" -1 (JE.string "load"))
            |> Send
        )
        model


has_next : Model a -> Bool
has_next model =
    model.visible < model.effects


has_previous : Model a -> Bool
has_previous model =
    model.visible > 0


init : Bool -> Msg sub
init run_all_javascript =
    Init run_all_javascript


next : Msg sub
next =
    Next


previous : Msg sub
previous =
    Previous


handle : Event -> Msg sub
handle =
    Handle


ttsReplay :
    Bool
    -> Model SubSection
    -> Maybe Event
ttsReplay sound model =
    case ( sound, current_comment model ) of
        ( True, Just ( id, _ ) ) ->
            Just <| TTS.readFrom -1 id

        _ ->
            Nothing


ttsCancel : Event
ttsCancel =
    TTS.cancel
