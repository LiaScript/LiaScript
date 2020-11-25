module Lia.Markdown.Quiz.Block.Update exposing (Msg(..), toString, update)

import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Quiz.Block.Types exposing (State(..))


type Msg sub
    = Toggle
    | Choose Int
    | Input String
    | Script (Script.Msg sub)


update : Msg sub -> State -> ( State, Maybe (Script.Msg sub) )
update msg state =
    case ( msg, state ) of
        ( Choose option, Select _ _ ) ->
            ( Select False [ option ], Nothing )

        ( Toggle, Select open id ) ->
            ( Select (not open) id, Nothing )

        ( Input str, Text _ ) ->
            ( Text str, Nothing )

        ( Script sub, _ ) ->
            ( state, Just sub )

        _ ->
            ( state, Nothing )


toString : State -> String
toString state =
    case state of
        Text str ->
            str

        Select _ [ i ] ->
            String.fromInt i

        _ ->
            ""
