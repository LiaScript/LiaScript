module Lia.Effect.Parser exposing (comment, inline, markdown)

import Combine exposing (..)
import Combine.Num exposing (int)
import Lia.Inline.Types exposing (Annotation, Inline(..), Inlines)
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.PState exposing (PState)


markdown : Parser PState Markdown -> Parser PState Markdown
markdown blocks =
    Effect
        <$> (regex "[\\t ]*{{" *> effect_number)
        <*> (regex "[\\t ]*" *> name)
        <*> (time <* regex "}}[\\t ]*\\n")
        <*> (multi blocks <|> single blocks)


single : Parser PState Markdown -> Parser PState (List Markdown)
single blocks =
    List.singleton <$> (regex "[ \\n\\t]*" *> blocks)


multi : Parser PState Markdown -> Parser PState (List Markdown)
multi blocks =
    regex "[\\t ]*[=]{3,}[\\n]+" *> manyTill (blocks <* regex "[ \\n\\t]*") (regex "[\\t ]*[=]{3,}")


name : Parser PState (Maybe String)
name =
    maybe (regex "[\\w ]+")


time : Parser PState String
time =
    optional "" (string "|" *> regex "[\\w;:, -]+")


css : Parser PState ( String, String )
css =
    (\a b -> ( String.trim a, String.trim b )) <$> regex "[\\w -]+" <*> (string ":" *> regex "[\\w ]+")


inline : Parser PState Inline -> Parser PState (Annotation -> Inline)
inline inlines =
    EInline
        <$> (string "{{" *> effect_number <* string "}}")
        <*> (string "{{" *> manyTill inlines (string "}}"))


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
            regex "[\\t ]*--{{" *> effect_number <* regex "}}--[\\t ]*[\\n]+"
    in
    Comment <$> number <*> paragraph
