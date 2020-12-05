module Lia.Markdown.Footnote.Parser exposing (block, inline)

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
        )
import Lia.Markdown.Footnote.Model as Model
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.Parser.Context exposing (Context, indentation_append)
import Lia.Parser.Helper exposing (stringTill)


inline : Parser Context (Parameters -> Inline)
inline =
    string "[^"
        |> keep (stringTill (string "]"))
        |> map Tuple.pair
        |> andMap (maybe (string "(" |> keep (stringTill (string ")"))))
        |> andThen store


block : Parser Context (List Markdown) -> Parser Context ()
block p =
    string "[^"
        |> keep (stringTill (string "]:"))
        |> map Tuple.pair
        |> ignore (indentation_append "[ ]{3,}")
        |> andMap p
        |> andThen add_footnote


store : ( String, Maybe String ) -> Parser Context (Parameters -> Inline)
store ( key, val ) =
    case val of
        Just v ->
            add_footnote ( key, [ Paragraph [] [ Chars v [] ] ] )
                |> keep (succeed (FootnoteMark key))

        _ ->
            succeed (FootnoteMark key)


add_footnote : ( String, List Markdown ) -> Parser Context ()
add_footnote ( key, val ) =
    modifyState (\s -> { s | footnotes = Model.insert key val s.footnotes })
