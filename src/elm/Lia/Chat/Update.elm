module Lia.Chat.Update exposing
    ( Msg(..)
    , update
    )

import Array
import Lia.Chat.Model exposing (Model)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Update as Markdown
import Lia.Parser.Parser exposing (parse_section)
import Lia.Section as Section
import Lia.Sync.Types as Sync
import Return exposing (Return)


type Msg
    = Send
    | Input String
    | UpdateMarkdown Int Markdown.Msg


update :
    { msg : Msg
    , searchIndex : String -> String
    , definition : Definition
    , model : Model
    , sync : { sync | state : Sync.State, cursors : List Sync.Cursor }
    }
    -> Return Model Msg Markdown.Msg
update { msg, searchIndex, definition, model, sync } =
    case msg of
        UpdateMarkdown id childMsg ->
            case Array.get id model.messages of
                Just section ->
                    section
                        |> Markdown.update sync definition childMsg
                        |> Return.mapValCmd (\sec -> { model | messages = Array.set id sec model.messages }) (UpdateMarkdown id)

                Nothing ->
                    model |> Return.val

        Input str ->
            { model | input = str }
                |> Return.val

        Send ->
            Return.val <|
                if String.trim model.input == "" then
                    model

                else
                    { model
                        | input = ""
                        , messages =
                            case
                                model.input
                                    ++ "\n\n"
                                    |> Section.Base 5 []
                                    |> Section.init 0 (Array.length model.messages)
                                    |> parse_section searchIndex definition
                            of
                                Ok new ->
                                    Array.push new model.messages

                                Err _ ->
                                    model.messages
                    }
