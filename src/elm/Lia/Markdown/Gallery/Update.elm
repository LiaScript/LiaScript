module Lia.Markdown.Gallery.Update exposing
    ( Msg(..)
    , update
    )

import Array
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Gallery.Types exposing (Vector)
import Return exposing (Return)


type Msg sub
    = Show Int Int
    | Close Int
    | Script (Script.Msg sub)


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


show : Int -> Int -> Vector -> Return Vector msg sub
show id1 id2 =
    Array.set id1 id2
        >> Return.val


close : Int -> Vector -> Return Vector msg sub
close id =
    Array.set id -1
        >> Return.val
