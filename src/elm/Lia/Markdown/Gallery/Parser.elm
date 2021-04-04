module Lia.Markdown.Gallery.Parser exposing (..)

import Array
import Combine
    exposing
        ( Parser
        , andThen
        , fail
        , ignore
        , keep
        , many1
        , map
        , modifyState
        , regex
        , succeed
        , withState
        )
import Combine.Char exposing (newline)
import Lia.Markdown.Gallery.Types exposing (Gallery)
import Lia.Markdown.Inline.Parser exposing (mediaReference)
import Lia.Parser.Context exposing (Context)


parse : Parser Context Gallery
parse =
    regex "[ \t]*"
        |> keep mediaReference
        |> many1
        |> ignore newline
        |> many1
        |> map List.concat
        |> andThen
            (\list ->
                if List.length list > 1 then
                    modify_State (Gallery list)

                else
                    fail "not a gallery"
            )


modify_State : (Int -> Gallery) -> Parser Context Gallery
modify_State media =
    withState (.gallery_vector >> Array.length >> succeed)
        |> map media
        |> ignore (modifyState add_state)


add_state : Context -> Context
add_state s =
    { s
        | gallery_vector =
            Array.push -1 s.gallery_vector
    }
