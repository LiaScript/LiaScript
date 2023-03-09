module Lia.Chat.Update exposing
    ( Msg(..)
    , update
    )

import Lia.Chat.Model exposing (Model)
import Lia.Section as Section


type Msg
    = Send
    | Input String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Input str ->
            { model | input = str }

        Send ->
            { model
                | input = ""
                , messages =
                    model.input
                        |> Section.Base 1 []
                        |> List.append model.messages
            }
