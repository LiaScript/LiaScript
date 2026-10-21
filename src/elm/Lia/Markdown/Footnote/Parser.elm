module Lia.Markdown.Footnote.Parser exposing
    ( block
    , inline
    )

import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , ignore
        , keep
        , map
        , maybe
        , modifyState
        , onsuccess
        , string
        , succeed
        , withState
        )
import Dict
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines)
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (stringTill)
import Lia.Parser.Indentation as Indent


{-| A footnote mark `[^key]`, or `[^key](text)` which also defines the footnote
inline, the text is parsed with the given inline parser.
-}
inline : (Context -> String -> Inlines) -> Parser Context (Parameters -> Inline)
inline parser =
    string "[^"
        |> keep (stringTill (string "]"))
        |> map Tuple.pair
        |> andMap
            (maybe
                (string "("
                    |> keep (stringTill (string ")"))
                    |> map (\str state -> parser state str)
                    |> andMap (withState succeed)
                )
            )
        |> andThen store


{-| A footnote definition `[^key]: ...`, its body consists of all following
blocks indented by at least two spaces. It is only stored in the state, no
block is returned.
-}
block : Parser Context Markdown.Blocks -> Parser Context ()
block p =
    string "[^"
        |> keep (stringTill (string "]:"))
        |> map Tuple.pair
        |> ignore (Indent.push "[ ]{2,}")
        |> andMap p
        |> andThen add


store : ( String, Maybe Inlines ) -> Parser Context (Parameters -> Inline)
store ( key, text ) =
    case text of
        Just inlines ->
            add ( key, [ Markdown.Paragraph [] inlines ] )
                |> onsuccess (FootnoteMark key)

        Nothing ->
            succeed (FootnoteMark key)


add : ( String, Markdown.Blocks ) -> Parser Context ()
add ( key, body ) =
    modifyState (\s -> { s | footnotes = Dict.insert key body s.footnotes })
