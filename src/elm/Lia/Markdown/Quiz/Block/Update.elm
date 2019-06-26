module Lia.Markdown.Quiz.Block.Update exposing (Msg(..), toString, update)

import Lia.Markdown.Quiz.Block.Types exposing (State(..))


type Msg
    = Toggle
    | Choose Int
    | Input String


update : Msg -> State -> State
update msg state =
    case ( msg, state ) of
        ( Choose option, Select open _ ) ->
            Select False option

        ( Toggle, Select open id ) ->
            Select (not open) id

        ( Input str, Text _ ) ->
            Text str

        _ ->
            state


toString : State -> String
toString state =
    case state of
        Text str ->
            str

        Select _ i ->
            String.fromInt i
