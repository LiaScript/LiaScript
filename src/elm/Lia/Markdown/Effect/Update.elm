module Lia.Markdown.Effect.Update exposing
    ( Msg(..)
    , handle
    , has_next
    , has_previous
    , init
    , next
    , previous
    , ttsReplay
    , update
    , updateSub
    )

import Browser.Dom as Dom
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
import Port.Event as Event exposing (Event)
import Port.Service.Console as Console
import Port.Service.Slide as Slide
import Port.Service.TTS as TTS
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
                    |> Return.val
                    |> Return.cmd (Task.perform (Rendered run_all_javascript) Dom.getViewport)

            Next ->
                if has_next model then
                    { model | visible = model.visible + 1 }
                        |> execute main sound False 0

                else
                    Return.val model

            Previous ->
                if has_previous model then
                    { model | visible = model.visible - 1 }
                        |> execute main sound False 0

                else
                    Return.val model

            Mute id ->
                { model | speaking = Nothing }
                    |> Return.val
                    |> Return.batchEvent
                        (TTS.cancel
                            |> Event.pushWithId "playback" id
                        )

            Send event ->
                let
                    events =
                        Slide.scrollIntoView "focused" 350
                            :: Slide.scrollIntoView "lia-notes-active" 350
                            :: event
                in
                model
                    |> Return.val
                    |> Return.batchEvents
                        (case current_comment model of
                            Just ( id, _ ) ->
                                if sound then
                                    TTS.readFrom id :: events

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
                    |> Return.mapValCmd (\v -> { model | javascript = v }) Script

            Handle event ->
                case Event.topicWithId event |> Debug.log "QQQQQQQQQQQQQQQQQQQQQQQQQQ" of
                    Just ( "tts", section ) ->
                        case TTS.decode event of
                            TTS.Start ->
                                { model | speaking = Just section }
                                    |> Return.val

                            TTS.Stop ->
                                { model | speaking = Nothing }
                                    |> Return.val

                            TTS.Error info ->
                                model
                                    |> Return.val
                                    |> Return.batchEvent (Console.warn info)

                    _ ->
                        model.javascript
                            |> Script.update main (Script_.Handle event)
                            |> Return.mapValCmd (\v -> { model | javascript = v }) Script


markRunning : Return (Model a) (Msg sub) sub -> Return (Model a) (Msg sub) sub
markRunning return =
    return
        |> Return.mapVal
            (\model ->
                { model
                    | javascript =
                        List.foldl
                            (\e js ->
                                case Event.id_ e of
                                    Just id ->
                                        if id < 0 then
                                            js

                                        else
                                            Script.setRunning id True js

                                    _ ->
                                        js
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


ttsReplay : Model SubSection -> Maybe Event
ttsReplay model =
    model
        |> current_comment
        |> Maybe.map (Tuple.first >> TTS.readFrom)
