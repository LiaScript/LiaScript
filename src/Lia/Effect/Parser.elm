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
            regex "( *){{" *> int <* regex "}}( *)[\\n]"

        multi_block =
            regex "( *){{" *> manyTill blocks (regex "}}[\\n]?")

        single_block =
            List.singleton <$> blocks

        increment_counter c =
            { c | effects = c.effects + 1 }
    in
    EBlock <$> number <*> (multi_block <|> single_block) <* modifyState increment_counter


einline : Parser PState Inline -> Parser PState Inline
einline inlines =
    let
        number =
            string "{{" *> int <* string "}}"

        multi_inline =
            string "{{" *> manyTill inlines (string "}}")

        increment_counter c =
            { c | effects = c.effects + 1 }
    in
    EInline <$> number <*> multi_inline <* modifyState increment_counter
