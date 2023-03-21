module Lia.Chat.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Dict
import Lia.Chat.Model exposing (Model)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Update as Markdown
import Lia.Sync.Types as Sync
import Return exposing (Return)
import Service.Event as Event exposing (Event)
import Service.Sync as Sync


type Msg
    = Send
    | Input String
    | UpdateMarkdown String Markdown.Msg
    | Handle Event


handle =
    Handle


update :
    { msg : Msg
    , definition : Definition
    , model : Model
    , sync : { sync | state : Sync.State, data : Sync.Data }
    }
    -> Return Model Msg Markdown.Msg
update { msg, definition, model, sync } =
    case msg of
        UpdateMarkdown id childMsg ->
            case Dict.get id model.messages of
                Just section ->
                    section
                        |> Markdown.update sync definition childMsg
                        |> Return.mapValCmd (\sec -> { model | messages = Dict.insert id sec model.messages }) (UpdateMarkdown id)

                Nothing ->
                    model |> Return.val

        Handle event ->
            case Event.popWithId event of
                Just ( topic, id, e ) ->
                    let
                        id_ =
                            String.fromInt id
                    in
                    case Dict.get id_ model.messages of
                        Just section ->
                            section
                                |> Markdown.handle sync definition topic e
                                |> Return.mapValCmd
                                    (\sec ->
                                        { model
                                            | messages = Dict.insert id_ sec model.messages
                                        }
                                    )
                                    (UpdateMarkdown id_)

                        _ ->
                            Return.val model

                _ ->
                    Return.val model

        Input str ->
            { model | input = str }
                |> Return.val

        Send ->
            if String.trim model.input == "" then
                model
                    |> Return.val

            else
                { model | input = "" }
                    |> Return.val
                    |> Return.batchEvent (Sync.chat model.input)
