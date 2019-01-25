module Lia.Markdown.Footnote.Parser exposing (block, inline)

import Combine exposing (..)
import Lia.Markdown.Footnote.Model as Model
import Lia.Markdown.Inline.Types exposing (..)
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.Parser.Helper exposing (..)
import Lia.Parser.State exposing (State, identation_append)


inline : Parser State (Annotation -> Inline)
inline =
    string "[^"
        |> keep (stringTill (string "]"))
        |> map Tuple.pair
        |> andMap (maybe (string "(" |> keep (stringTill (string ")"))))
        |> andThen store


block : Parser State (List Markdown) -> Parser State ()
block p =
    string "[^"
        |> keep (stringTill (string "]:"))
        |> map Tuple.pair
        |> ignore (identation_append "   ")
        |> andMap p
        |> andThen add_footnote


store : ( String, Maybe String ) -> Parser State (Annotation -> Inline)
store ( key, val ) =
    case val of
        Just v ->
            add_footnote ( key, [ Paragraph Nothing [ Chars v Nothing ] ] )
                |> keep (succeed (FootnoteMark key))

        _ ->
            succeed (FootnoteMark key)


add_footnote : ( String, List Markdown ) -> Parser State ()
add_footnote ( key, val ) =
    modifyState (\s -> { s | footnotes = Model.insert key val s.footnotes })
