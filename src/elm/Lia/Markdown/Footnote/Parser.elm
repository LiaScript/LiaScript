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
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Footnote.Model as Model
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines)
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context exposing (Context)
import Lia.Parser.Helper exposing (stringTill)
import Lia.Parser.Indentation as Indent


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


block : Parser Context Markdown.Blocks -> Parser Context ()
block p =
    string "[^"
        |> keep (stringTill (string "]:"))
        |> map Tuple.pair
        |> ignore (Indent.push "[ ]{2,}")
        |> andMap p
        |> andThen add_footnote


store : ( String, Maybe Inlines ) -> Parser Context (Parameters -> Inline)
store ( key, val ) =
    case val of
        Just v ->
            add_footnote
                ( key
                , [ Markdown.Paragraph [] v ]
                )
                |> keep (succeed (FootnoteMark key))

        _ ->
            succeed (FootnoteMark key)


add_footnote : ( String, Markdown.Blocks ) -> Parser Context ()
add_footnote ( key, val ) =
    modifyState (\s -> { s | footnotes = Model.insert key val s.footnotes })
