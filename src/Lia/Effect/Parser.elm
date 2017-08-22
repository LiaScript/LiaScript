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
    in
    EBlock <$> number <*> (multi_block <|> single_block) <* effect_number


einline : Parser PState Inline -> Parser PState Inline
einline inlines =
    let
        number =
            string "{{" *> int <* string "}}"

        multi_inline =
            string "{{" *> manyTill inlines (string "}}")
    in
    EInline <$> number <*> multi_inline <* effect_number


effect_number : Parser PState ()
effect_number =
    modifyState (\s -> { s | effects = s.effects + 1 })
