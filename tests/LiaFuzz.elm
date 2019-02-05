module LiaFuzz exposing (fuzzRegex)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer)
import Random.Regex exposing (..)
import Shrink


fuzzRegex : String -> Fuzzer String
fuzzRegex str =
    case Random.Regex.generate ASCII 30 str of
        Ok re ->
            Fuzz.custom re Shrink.noShrink

        Err info ->
            Fuzz.invalid ("not a valid regular expression (" ++ str ++ ") => " ++ info)
