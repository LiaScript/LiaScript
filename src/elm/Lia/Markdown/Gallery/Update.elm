module Lia.Markdown.Gallery.Update exposing
    ( Msg(..)
    , handle
    , update
    )

import Array
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Gallery.Types exposing (Vector)
import Return exposing (Return)
import Service.Event exposing (Event)


type Msg sub
    = Show Int Int
    | Close Int
    | Handle Event
    | Script (Script.Msg sub)


{-| Pass events from parent update function to the Task update function.
-}
handle : Event -> Msg sub
handle =
    Handle


update : Msg sub -> Vector -> Return Vector msg sub
update msg vector =
    case msg of
        Show id id2 ->
            vector
                |> show id id2

        --|> Return.sync (Event.initWithId "show" id (JE.int id2))
        Close id ->
            vector
                |> close id

        --|> Return.sync (Event.initWithId "close" id JE.null)
        Script sub ->
            vector
                |> Return.val
                |> Return.script sub

        Handle _ ->
            Return.val vector


show : Int -> Int -> Vector -> Return Vector msg sub
show id1 id2 =
    Array.set id1 id2
        >> Return.val


close : Int -> Vector -> Return Vector msg sub
close id =
    Array.set id -1
        >> Return.val
