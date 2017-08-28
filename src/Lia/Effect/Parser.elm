module Lia.Effect.Parser exposing (eblock, ecomment, einline)

--import Lia.Effect.Types exposing (Comment)

import Combine exposing (..)
import Combine.Num exposing (int)
import Lia.Inline.Types exposing (Inline(..))
import Lia.PState exposing (PState)
import Lia.Types exposing (Block(..))


newlines : Parser s ()
newlines =
    skip (regex "[ \\n\\t]+")


eblock : Parser PState Block -> Parser PState Block
eblock blocks =
    let
        number =
            regex "( *){{" *> effect_number <* regex "}}( *)[\\n]"

        multi_block =
            regex "( *){{[\\n]+" *> manyTill (blocks <* regex "[ \\n\\t]*") (regex "( *)}}")

        single_block =
            List.singleton <$> (regex "[ \\n\\t]*" *> blocks)
    in
    EBlock <$> number <*> (multi_block <|> single_block)



-- <|> single_block)


einline : Parser PState Inline -> Parser PState Inline
einline inlines =
    let
        number =
            string "{{" *> effect_number <* string "}}"

        multi_inline =
            string "{{" *> manyTill inlines (string "}}")
    in
    EInline <$> number <*> multi_inline


effect_number : Parser PState Int
effect_number =
    let
        state n =
            modifyState
                (\s ->
                    { s
                        | effects =
                            if n > s.effects then
                                n
                            else
                                s.effects
                    }
                )
                *> succeed n
    in
    int >>= state


ecomment : Parser PState (List Inline) -> Parser PState Block
ecomment paragraph =
    let
        number =
            regex "( *)--{{" *> effect_number <* regex "}}--( *)[\\n]+"
    in
    EComment <$> number <*> paragraph
