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

{-| Stepping through the animations of a section, which runs the scripts of
the new step and reads its comments out loud, and the playback of effects.
-}

import Browser.Dom as Dom
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Effect.Model exposing (Model, current_comment)
import Lia.Markdown.Effect.Script.Types as Script_ exposing (Scripts)
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Section exposing (SubSection)
import Return exposing (Return)
import Service.Console
import Service.Event as Event exposing (Event)
import Service.Slide
import Service.TTS
import Task


{-| -}
type Msg sub
    = Init Bool
    | Next
    | Previous
    | Send (List Event)
    | Rendered Bool Dom.Viewport
    | Handle Event
    | Script (Script_.Msg sub)


{-| How scripts update and handle events of their sub-sections.
-}
type alias Main sub =
    { update : Scripts SubSection -> sub -> SubSection -> Return SubSection sub sub
    , handle : Scripts SubSection -> JE.Value -> SubSection -> Return SubSection sub sub
    , globals : Maybe Definition
    }


{-| Update the scripts of a sub-section, which has no sound.
-}
updateSub : Main sub -> Script_.Msg sub -> Model SubSection -> Return (Model SubSection) (Msg sub) sub
updateSub main msg =
    update main True (Script msg)


{-| `sound` defines whether comments are read out loud. Scripts that get
executed are marked as running.
-}
update : Main sub -> Bool -> Msg sub -> Model SubSection -> Return (Model SubSection) (Msg sub) sub
update main sound msg model =
    markRunning <|
        case msg of
            Init run_all_javascript ->
                -- wait until the section is rendered, before running its scripts
                model
                    |> Return.val
                    |> Return.cmd (Task.perform (Rendered run_all_javascript) Dom.getViewport)

            Next ->
                if has_next model then
                    execute main sound False { model | visible = model.visible + 1 }

                else
                    Return.val model

            Previous ->
                if has_previous model then
                    execute main sound False { model | visible = model.visible - 1 }

                else
                    Return.val model

            Send events ->
                model
                    |> Return.val
                    |> Return.batchEvents
                        ((case current_comment model of
                            Just id ->
                                if sound then
                                    [ Service.TTS.readFrom id ]

                                else
                                    []

                            Nothing ->
                                [ Service.TTS.cancel ]
                         )
                            ++ Service.Slide.scrollIntoView "focusedToc" 500
                            :: Service.Slide.scrollIntoView "focused" 750
                            :: Service.Slide.scrollIntoView "lia-notes-active" 500
                            :: events
                        )

            Rendered run_all_javascript _ ->
                execute main sound run_all_javascript model

            Script childMsg ->
                script main childMsg model

            Handle event ->
                case Event.destructure event of
                    ( Nothing, _, _ ) ->
                        case Service.TTS.decode event of
                            Service.TTS.Start ->
                                Return.val { model | speaking = Just -1 }

                            Service.TTS.Stop ->
                                Return.val { model | speaking = Nothing }

                            Service.TTS.Error info ->
                                model
                                    |> Return.val
                                    |> Return.batchEvent (Service.Console.warn info)

                            _ ->
                                Return.val model

                    ( Just "playback", id, ( "start", _ ) ) ->
                        Return.val { model | speaking = Just id, paused = Nothing }

                    ( Just "playback", _, ( "stop", _ ) ) ->
                        Return.val { model | speaking = Nothing, paused = Nothing }

                    ( Just "playback", id, ( "paused", _ ) ) ->
                        Return.val { model | paused = Just id }

                    ( Just "playback", _, ( "error", _ ) ) ->
                        { model | speaking = Nothing, paused = Nothing }
                            |> Return.val
                            |> Return.batchEvent (Service.Console.warn "effects: local playback error")

                    _ ->
                        script main (Script_.Handle event) model


script : Main sub -> Script_.Msg sub -> Model SubSection -> Return (Model SubSection) (Msg sub) sub
script main msg model =
    model.javascript
        |> Script.update main msg
        |> Return.mapValCmd (\v -> { model | javascript = v }) Script


{-| Mark all scripts as running, for which an `exec` event is sent (events of
LiaScript results are tracked through `"sub"` and belong to their scripts).
-}
markRunning : Return (Model a) (Msg sub) sub -> Return (Model a) (Msg sub) sub
markRunning return =
    Return.mapVal
        (\model ->
            { model
                | javascript =
                    List.foldl
                        (\e js ->
                            case ( Event.poi e, e.message.cmd ) of
                                ( Just ( "script", id ), "exec" ) ->
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
        return


{-| Run the scripts of the current animation step (or all of them), scroll to
the new step and read its comments.
-}
execute : Main sub -> Bool -> Bool -> Model SubSection -> Return (Model SubSection) (Msg sub) sub
execute main sound run_all model =
    (if run_all then
        Script.getAll model.javascript

     else
        Script.getVisible model.visible model.javascript
    )
        |> List.map (Script.execute 0)
        |> List.reverse
        |> Send
        |> (\msg -> update main sound msg model)


{-| -}
has_next : Model a -> Bool
has_next model =
    model.visible < model.effects


{-| -}
has_previous : Model a -> Bool
has_previous model =
    model.visible > 0


{-| Start the animations of a section, `True` runs all of its scripts.
-}
init : Bool -> Msg sub
init =
    Init


{-| -}
next : Msg sub
next =
    Next


{-| -}
previous : Msg sub
previous =
    Previous


{-| -}
handle : Event -> Msg sub
handle =
    Handle
