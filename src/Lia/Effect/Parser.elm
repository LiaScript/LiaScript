module Lia.Effect.Parser exposing (comment, inline, markdown)

import Combine exposing (..)
import Combine.Num exposing (int)
import Dict
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines)
import Lia.Markdown.Types exposing (Markdown(..))
import Lia.PState exposing (PState)


markdown : Parser PState Markdown -> Parser PState ( Int, List Markdown )
markdown blocks =
    (\i list -> ( i, list ))
        <$> (regex "[\\t ]*{{" *> effect_number <* regex "}}[\\t ]*\\n")
        <*> (multi blocks <|> single blocks)


single : Parser PState Markdown -> Parser PState (List Markdown)
single blocks =
    List.singleton <$> (regex "[ \\n\\t]*" *> blocks)


multi : Parser PState Markdown -> Parser PState (List Markdown)
multi blocks =
    regex "[\\t ]*[=]{3,}[\\n]+" *> manyTill (blocks <* regex "[ \\n\\t]*") (regex "[\\t ]*[=]{3,}")


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


comment : Parser PState Inlines -> Parser PState ( Int, Inlines )
comment paragraph =
    let
        number =
            regex "[\\t ]*--{{" *> effect_number <* regex "}}--[\\t ]*[\\n]+"
    in
    ((\n p -> ( n, p )) <$> number <*> paragraph) >>= add_comment


add_comment : ( Int, Inlines ) -> Parser PState ( Int, Inlines )
add_comment ( idx, par ) =
    modifyState
        (\s ->
            { s | comments = Dict.insert idx (stringify par) s.comments }
        )
        *> succeed ( idx, par )
