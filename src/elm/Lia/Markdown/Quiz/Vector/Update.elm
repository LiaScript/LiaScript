module Lia.Markdown.Quiz.Vector.Update exposing
    ( Msg(..)
    , toString
    , toggle
    , update
    )

import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))
import List.Extra
import Return exposing (Return)


type Msg sub
    = Toggle Int
    | Script (Script.Msg sub)


update : Msg sub -> State -> Return State msg sub
update msg state =
    case msg of
        Toggle id ->
            state
                |> toggle id
                |> Return.val

        Script sub ->
            state
                |> Return.val
                |> Return.script sub


toggle : Int -> State -> State
toggle id state =
    case state of
        SingleChoice list ->
            list
                |> toggleSingle id
                |> SingleChoice

        MultipleChoice list ->
            list
                |> toggleMultiple id
                |> MultipleChoice


toggleSingle : Int -> List Bool -> List Bool
toggleSingle id =
    List.indexedMap
        (\i value ->
            if i == id then
                not value

            else
                False
        )


toggleMultiple : Int -> List Bool -> List Bool
toggleMultiple id =
    List.indexedMap
        (\i value ->
            if i == id then
                not value

            else
                value
        )


toString : State -> String
toString state =
    case state of
        SingleChoice list ->
            list
                |> List.Extra.findIndex identity
                |> Maybe.withDefault -1
                |> String.fromInt

        MultipleChoice values ->
            values
                |> List.map
                    (\s ->
                        if s then
                            1

                        else
                            0
                    )
                |> JE.list JE.int
                |> JE.encode 0
