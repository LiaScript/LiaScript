module Lia.Markdown.Quiz.Block.Update exposing
    ( Msg(..)
    , toString
    , update
    )

import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Quiz.Block.Types exposing (State(..))
import Return exposing (Return)


type Msg sub
    = Toggle
    | Choose Int
    | Input String
    | Script (Script.Msg sub)


update : Msg sub -> State -> Return State msg sub
update msg state =
    case ( msg, state ) of
        ( Choose option, Select _ _ ) ->
            Select True [ option ]
                |> Return.val

        ( Toggle, Select open id ) ->
            Select (not open) id
                |> Return.val

        ( Input str, Text _ ) ->
            Text str
                |> Return.val

        ( Script sub, _ ) ->
            state
                |> Return.val
                |> Return.script sub

        _ ->
            state
                |> Return.val


toString : Bool -> State -> String
toString withQuotes state =
    case state of
        Text str ->
            if withQuotes then
                "\"" ++ str ++ "\""

            else
                str

        Select _ [ i ] ->
            String.fromInt i

        _ ->
            ""
