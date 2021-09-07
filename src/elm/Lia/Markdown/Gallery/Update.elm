module Lia.Markdown.Gallery.Update exposing
    ( Msg(..)
    , update
    )

import Array
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Gallery.Types exposing (Vector)
import Return exposing (Return)


type Msg sub
    = Show Int Int
    | Close Int
    | Script (Script.Msg sub)


update : Msg sub -> Vector -> Return Vector Never sub
update msg vector =
    case msg of
        Show id id2 ->
            vector
                |> Array.set id id2
                |> Return.value

        Close id ->
            vector
                |> Array.set id -1
                |> Return.value

        Script sub ->
            vector
                |> Return.value
                |> Return.script sub
