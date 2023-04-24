module Lia.Markdown.Quiz.Multi.Update exposing
    ( Msg(..)
    , handle
    , toString
    , update
    )

import Array
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Block.Update as Block
import Lia.Markdown.Quiz.Multi.Types exposing (State)
import Return exposing (Return)


type Msg sub
    = Script (Script.Msg sub)
    | Handle ( String, JE.Value )


handle : ( String, JE.Value ) -> Msg sub
handle =
    Handle


update : Msg sub -> State -> Return State msg sub
update msg state =
    case msg of
        Handle ( cmd, param ) ->
            case ( cmd, decodeId param ) of
                ( "input", Ok id ) ->
                    case ( Array.get id state, decodeValue JD.string param ) of
                        ( Just (Block.Text _), Ok text ) ->
                            state
                                |> Array.set id (Block.Text text)
                                |> Return.val

                        _ ->
                            state
                                |> Return.val

                ( "choose", Ok id ) ->
                    case ( Array.get id state, decodeValue JD.int param ) of
                        ( Just (Block.Select open _), Ok option ) ->
                            state
                                |> Array.set id (Block.Select open [ option ])
                                |> Return.val

                        _ ->
                            state
                                |> Return.val

                ( "toggle", Ok id ) ->
                    case Array.get id state of
                        Just (Block.Select open option) ->
                            state
                                |> Array.set id (Block.Select (not open) option)
                                |> Return.val

                        _ ->
                            state
                                |> Return.val

                _ ->
                    state
                        |> Return.val

        Script sub ->
            state
                |> Return.val
                |> Return.script sub


toString : State -> String
toString state =
    state
        |> Array.toList
        |> List.map (Block.toString True)
        |> List.intersperse ","
        |> String.concat
        |> (\str -> "[" ++ str ++ "]")


decodeValue : JD.Decoder a -> JD.Value -> Result JD.Error a
decodeValue type_ =
    JD.decodeValue (JD.field "value" type_)


decodeId : JD.Value -> Result JD.Error Int
decodeId =
    JD.decodeValue (JD.field "id" JD.int)
