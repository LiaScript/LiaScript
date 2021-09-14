module Lia.Markdown.Table.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Survey.Update exposing (Msg(..))
import Lia.Markdown.Table.Types exposing (Class(..), State, Vector)
import Port.Eval exposing (event)
import Port.Event as Event exposing (Event)
import Return exposing (Return)


type Msg sub
    = Sort Int Int
    | Toggle Int
    | Handle Event
    | NoOp


{-| Pass events from parent update function to the Task update function.
-}
handle : Event -> Msg sub
handle =
    Handle


update : Msg sub -> Vector -> Return Vector msg sub
update msg vector =
    case msg of
        Sort id col ->
            sort id vector col
                |> Return.sync (Event "sort" id (JE.int col))

        Toggle id ->
            toggle id vector
                |> Return.sync (Event "toggle" id JE.null)

        Handle event ->
            case ( event.topic, Event.decode event.message ) of
                ( "sync", Ok e ) ->
                    case e.topic of
                        "toggle" ->
                            toggle e.section vector

                        "sort" ->
                            e.message
                                |> JD.decodeValue JD.int
                                |> Result.map (sort e.section vector)
                                |> Result.withDefault (Return.val vector)

                        _ ->
                            Return.val vector

                _ ->
                    Return.val vector

        NoOp ->
            Return.val vector


updateSort : Int -> State -> State
updateSort column state =
    if state.column /= column then
        { state | column = column, dir = True }

    else if state.dir then
        { state | dir = False }

    else
        { state | column = -1 }


toggle : Int -> Vector -> Return Vector msg sub
toggle id vector =
    vector
        |> Array.get id
        |> Maybe.map (\state -> Array.set id { state | diagram = not state.diagram } vector)
        |> Maybe.withDefault vector
        |> Return.val


sort : Int -> Vector -> Int -> Return Vector msg sub
sort id vector col =
    vector
        |> Array.get id
        |> Maybe.map (\state -> Array.set id (updateSort col state) vector)
        |> Maybe.withDefault vector
        |> Return.val
