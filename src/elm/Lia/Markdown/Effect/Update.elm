module Lia.Markdown.Effect.Update exposing
    ( Msg(..)
    , handle
    , has_next
    , has_previous
    , init
    , next
    , previous
    , update
    )

import Browser.Dom as Dom
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Effect.JavaScript as JS
import Lia.Markdown.Effect.Model
    exposing
        ( Model
        , current_comment
        )
import Port.Eval as Eval exposing (Eval)
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

                    "code" ->
                        let
                            javascript =
                                model.javascript
                                    |> JS.update event.section (Eval.decode event.message)

                            node =
                                javascript
                                    |> JS.get identity event.section

                            nodeUpdate =
                                if
                                    node
                                        |> Maybe.map .update
                                        |> Maybe.withDefault False
                                then
                                    node
                                        |> Maybe.map
                                            (.script
                                                >> Tuple.pair event.section
                                                >> List.singleton
                                            )
                                        |> Maybe.withDefault []

                                else
                                    []
                        in
                        case Maybe.andThen .output node of
                            Nothing ->
                                ( { model
                                    | javascript =
                                        JS.set
                                            event.section
                                            (\js -> { js | update = False })
                                            javascript
                                  }
                                , Cmd.none
                                , nodeUpdate
                                    |> JS.replaceInputs javascript
                                    |> List.map (executeEvent 0)
                                )

                            Just output ->
                                ( { model
                                    | javascript =
                                        javascript
                                            |> JS.updateChildren output
                                            |> JS.set event.section (\js -> { js | update = False })
                                  }
                                , Cmd.none
                                , javascript
                                    |> JS.scriptChildren output
                                    |> List.append nodeUpdate
                                    |> JS.replaceInputs javascript
                                    |> List.map (executeEvent 0)
                                )

                    "codeX" ->
                        let
                            javascript =
                                event.message
                                    |> Eval.decode
                                    |> .result
                                    |> JS.setResult event.section model.javascript

                            node =
                                javascript
                                    |> JS.get identity event.section
                        in
                        case Maybe.andThen .output node of
                            Nothing ->
                                ( { model
                                    | javascript =
                                        javascript
                                  }
                                , Cmd.none
                                , []
                                )

                            Just output ->
                                ( { model | javascript = JS.updateChildren output javascript }
                                , Cmd.none
                                , javascript
                                    |> JS.scriptChildren output
                                    |> JS.replaceInputs javascript
                                    |> List.map (executeEvent 0)
                                )

                    _ ->
                        ( model, Cmd.none, [] )


markRunning : ( Model, Cmd Msg, List Event ) -> ( Model, Cmd Msg, List Event )
markRunning ( model, cmd, events ) =
    ( { model
        | javascript =
            List.foldl
                (\e js ->
                    if e.section < 0 then
                        js

                    else
                        JS.setRunning e.section True js
                )
                model.javascript
                events
      }
    , cmd
    , events
    )


executeEvent : Int -> ( Int, String ) -> Event
executeEvent delay ( id, code ) =
    Event "execute" id <|
        JE.object
            [ ( "delay", JE.int delay )
            , ( "code", JE.string code )
            , ( "id", JE.int id )
            ]


execute : Bool -> Bool -> Int -> Model -> ( Model, Cmd Msg, List Event )
execute sound run_all delay model =
    let
        javascript =
            if run_all then
                JS.getAll .script model.javascript

            else
                JS.getVisible model.effects model.javascript
    in
    update sound
        (javascript
            |> List.map (executeEvent delay)
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
