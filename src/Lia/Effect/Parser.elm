module Lia.Effect.Parser exposing (comment, inline, markdown)

import Combine exposing (..)
import Combine.Num exposing (int)
import Lia.Inline.Types exposing (Inline(..), Inlines)
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.PState exposing (PState)


markdown : Parser PState Markdown -> Parser PState Markdown
markdown blocks =
    Effect
        <$> (regex "( *){{" *> effect_number)
        <*> (regex "( *)" *> name <* regex "}}( *)[\\n]")
        <*> (multi blocks <|> single blocks)


single : Parser PState Markdown -> Parser PState (List Markdown)
single blocks =
    List.singleton <$> (regex "[ \\n\\t]*" *> blocks)


multi : Parser PState Markdown -> Parser PState (List Markdown)
multi blocks =
    regex "( *){{[\\n]+" *> manyTill (blocks <* regex "[ \\n\\t]*") (regex "( *)}}")


name : Parser PState (Maybe String)
name =
    maybe (regex "[a-zA-Z0-9 ]+")


inline : Parser PState Inline -> Parser PState Inline
inline inlines =
    let
        multi_inline =
            string "{{" *> manyTill inlines (string "}}")
    in
    EInline
        <$> (string "{{" *> effect_number)
        <*> (regex "( *)" *> name <* string "}}")
        <*> multi_inline


effect_number : Parser PState Int
effect_number =
    let
        state n =
            modifyState
                (\s ->
                    if n > s.num_effects then
                        { s | num_effects = n }
                    else
                        s
                )
                *> succeed n
    in
    int >>= state


comment : Parser PState Inlines -> Parser PState Markdown
comment paragraph =
    let
        number =
            regex "( *)--{{" *> effect_number <* regex "}}--( *)[\\n]+"
    in
    Comment <$> number <*> paragraph
