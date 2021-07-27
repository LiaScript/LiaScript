module Lia.Markdown.Gallery.Update exposing
    ( Msg(..)
    , update
    )

import Array
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Gallery.Types exposing (Vector)


type Msg sub
    = Show Int Int
    | Close Int
    | Script (Script.Msg sub)


update : Msg sub -> Vector -> ( Vector, Maybe (Script.Msg sub) )
update msg vector =
    case msg of
        Show id id2 ->
            ( Array.set id id2 vector, Nothing )

        Close id ->
            ( Array.set id -1 vector, Nothing )

        Script sub ->
            ( vector, Just sub )
