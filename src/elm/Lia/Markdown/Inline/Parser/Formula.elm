module Lia.Markdown.Inline.Parser.Formula exposing (formula)

import Combine exposing (Parser, andMap, ignore, keep, map, or, regex, string)
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..))
import Lia.Parser.Helper exposing (stringTill)
<<<<<<< HEAD
<<<<<<< HEAD
import Lia.Parser.State exposing (State)
=======
import Lia.Parser.State exposing (State, getLine)
>>>>>>> added formulas to sync
=======
import Lia.Parser.State exposing (State)
>>>>>>> simplified jumping via a Goto type in inlines


formula : Parser State (Annotation -> Inline)
formula =
    or formula_block formula_inline


formula_inline : Parser State (Annotation -> Inline)
formula_inline =
    string "$"
        |> keep (regex "[^\\n$]+")
        |> ignore (string "$")
        |> map (Formula "false")


formula_block : Parser State (Annotation -> Inline)
formula_block =
    string "$$"
        |> keep (stringTill (string "$$"))
        |> map (Formula "true")
