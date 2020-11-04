module Lia.Markdown.Effect.Update exposing
    ( Msg(..)
    , handle
    , has_next
    , has_previous
    , init
    , next
    , previous
    , update
    , updateSub
    )

import Browser.Dom as Dom
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Effect.Model
    exposing
        ( Model
        , current_comment
        )
import Lia.Markdown.Effect.Script.Update as Script
import Port.Eval as Eval
import Port.Event exposing (Event)
import Port.TTS as TTS
import Task


type Msg
    = Init Bool
    | Next
    | Previous
    | Send (List Event)
    | Speak Int String String
    | Mute Int
    | Rendered Bool Dom.Viewport
    | Handle Event
    | Script Script.Msg


updateSub : Script.Msg -> Model -> ( Model, Cmd Msg, List Event )
updateSub msg =
    update True (Script msg)


update : Bool -> Msg -> Model -> ( Model, Cmd Msg, List Event )
update sound msg model =
    markRunning <|
        case msg of
            Init run_all_javascript ->
                ( model
                , Task.perform (Rendered run_all_javascript) Dom.getViewport
                , []
                )

            Next ->
                if has_next model then
                    { model | visible = model.visible + 1 }
                        |> execute sound False 0

                else
                    ( model, Cmd.none, [] )

            Previous ->
                if has_previous model then
                    { model | visible = model.visible - 1 }
                        |> execute sound False 0

                else
                    ( model, Cmd.none, [] )

            Speak id voice text ->
                ( { model | speaking = Just id }
                , Cmd.none
                , [ TTS.playback id voice text ]
                )

            Mute id ->
                ( { model | speaking = Nothing }
                , Cmd.none
                , [ TTS.mute id ]
                )

            Send event ->
                let
                    events =
                        ("focused"
                            |> JE.string
                            |> Event "scrollTo" -1
                        )
                            :: event
                in
                ( model
                , Cmd.none
                , case current_comment model of
                    Just ( comment, narrator ) ->
                        TTS.speak sound narrator comment :: events

                    _ ->
                        TTS.cancel :: events
                )

            Rendered run_all_javascript _ ->
                execute sound run_all_javascript 0 model

            Script childMsg ->
                let
                    ( scripts, cmd, events ) =
                        Script.update childMsg model.javascript
                in
                ( { model | javascript = scripts }, Cmd.map Script cmd, events )

            Handle event ->
                case event.topic of
                    "speak" ->
                        case event.message |> JD.decodeValue JD.string of
                            Ok "start" ->
                                ( { model | speaking = Just event.section }, Cmd.none, [] )

                            Ok "stop" ->
                                ( { model | speaking = Nothing }, Cmd.none, [] )

                            _ ->
                                ( model, Cmd.none, [] )

                    _ ->
                        let
                            ( scripts, cmd, events ) =
                                Script.update (Script.Handle event) model.javascript
                        in
                        ( { model | javascript = scripts }, Cmd.map Script cmd, events )


markRunning : ( Model, Cmd Msg, List Event ) -> ( Model, Cmd Msg, List Event )
markRunning ( model, cmd, events ) =
    ( { model
        | javascript =
            List.foldl
                (\e js ->
                    if e.section < 0 then
                        js

                    else
                        Script.setRunning e.section True js
                )
                model.javascript
                events
      }
    , cmd
    , events
    )


execute : Bool -> Bool -> Int -> Model -> ( Model, Cmd Msg, List Event )
execute sound run_all delay model =
    let
        javascript =
            if run_all then
                Script.getAll model.javascript

            else
                Script.getVisible model.visible model.javascript
    in
    update sound
        (javascript
            |> List.map (Script.execute delay)
            |> (::) (Event "persistent" -1 (JE.string "load"))
            |> Send
        )
        model


has_next : Model -> Bool
has_next model =
    model.visible < model.effects


has_previous : Model -> Bool
has_previous model =
    model.visible > 0


init : Bool -> Msg
init run_all_javascript =
    Init run_all_javascript


next : Msg
next =
    Next


previous : Msg
previous =
    Previous


handle : Event -> Msg
handle =
    Handle
