module Lia.Markdown.Quiz.SingleChoice.Update exposing (Msg(..), toString, update)

import Lia.Markdown.Quiz.SingleChoice.Types exposing (State)


type Msg
    = Toggle Int


update : Msg -> State -> State
update msg state =
    case msg of
        Toggle id ->
            id


toString : State -> String
toString state =
    String.fromInt state
