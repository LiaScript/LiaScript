module Lia.Effect.Parser exposing (..)

import Combine exposing (..)
import Combine.Num exposing (int)
import Lia.Inline.Type exposing (Inline(..))
import Lia.PState exposing (PState)
import Lia.Type exposing (Block(..))


eblock : Parser PState Block -> Parser PState Block
eblock blocks =
    let
        number =
            regex "( *){{" *> effect_number <* regex "}}( *)[\\n]"

        multi_block =
            regex "( *){{" *> manyTill blocks (regex "}}[\\n]?")

        single_block =
            List.singleton <$> blocks
    in
    EBlock <$> number <*> (multi_block <|> single_block)


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
