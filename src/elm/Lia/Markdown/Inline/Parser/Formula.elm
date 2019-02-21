module Lia.Markdown.Inline.Parser.Formula exposing (formula)

import Combine exposing (Parser, ignore, keep, map, or, regex, string)
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..))
import Lia.Parser.Helper exposing (stringTill)


formula : Parser s (Annotation -> Inline)
formula =
    or formula_block formula_inline


formula_inline : Parser s (Annotation -> Inline)
formula_inline =
    string "$"
        |> keep (regex "[^\\n$]+")
        |> ignore (string "$")
        |> map (Formula "false")


formula_block : Parser s (Annotation -> Inline)
formula_block =
    string "$$"
        |> keep (stringTill (string "$$"))
        |> map (Formula "true")
