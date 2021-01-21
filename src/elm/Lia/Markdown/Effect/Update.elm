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
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Section exposing (SubSection)
import Port.Event exposing (Event)
import Port.TTS as TTS
import Task


type Msg sub
    = Init Bool
    | Next
    | Previous
    | Send (List Event)
    | Speak Int String String
    | Mute Int
    | Rendered Bool Dom.Viewport
    | Handle Event
    | Script (Script.Msg sub)


updateSub :
    { update : Scripts SubSection -> sub -> SubSection -> ( SubSection, Cmd sub, List ( String, JE.Value ) )
    , handle : Scripts SubSection -> JE.Value -> SubSection -> ( SubSection, Cmd sub, List ( String, JE.Value ) )
    }
    -> Script.Msg sub
    -> Model SubSection
    -> ( Model SubSection, Cmd (Msg sub), List Event )
updateSub main msg =
    update main True (Script msg)


update :
    { update : Scripts SubSection -> sub -> SubSection -> ( SubSection, Cmd sub, List ( String, JE.Value ) )
    , handle : Scripts SubSection -> JE.Value -> SubSection -> ( SubSection, Cmd sub, List ( String, JE.Value ) )
    }
    -> Bool
    -> Msg sub
    -> Model SubSection
    -> ( Model SubSection, Cmd (Msg sub), List Event )
update main sound msg model =
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
                        |> execute main sound False 0

                else
                    ( model, Cmd.none, [] )

            Previous ->
                if has_previous model then
                    { model | visible = model.visible - 1 }
                        |> execute main sound False 0

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
                execute main sound run_all_javascript 0 model

            Script childMsg ->
                let
                    ( scripts, cmd, events ) =
                        Script.update main childMsg model.javascript
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
                                Script.update main (Script.Handle event) model.javascript
                        in
                        ( { model | javascript = scripts }, Cmd.map Script cmd, events )


markRunning : ( Model a, Cmd (Msg sub), List Event ) -> ( Model a, Cmd (Msg sub), List Event )
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


execute :
    { update : Scripts SubSection -> sub -> SubSection -> ( SubSection, Cmd sub, List ( String, JE.Value ) )
    , handle : Scripts SubSection -> JE.Value -> SubSection -> ( SubSection, Cmd sub, List ( String, JE.Value ) )
    }
    -> Bool
    -> Bool
    -> Int
    -> Model SubSection
    -> ( Model SubSection, Cmd (Msg sub), List Event )
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
            |> (::) (Event "persistent" -1 (JE.string "load"))
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
