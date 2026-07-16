module Preprocessor exposing (basic)

import Expect exposing (Expectation)
import Lia.Definition.Types exposing (Definition, default)
import Lia.Parser.Parser as Parser
import LiaFuzz exposing (fuzzRegex)
import Test exposing (Test, describe, fuzz)


{-| `parse_titles` only splits off a single leading section (title + body) and
returns the remaining, unparsed code, so counting sections in a document means
repeatedly re-running it on what's left until nothing (parseable) remains.
-}
countSections : Definition -> String -> Int -> Result String Int
countSections defines code n =
    if String.trim code == "" then
        Ok n

    else
        case Parser.parse_titles defines code of
            Ok ( _, rest ) ->
                countSections defines rest (n + 1)

            Err info ->
                if n == 0 then
                    Err info

                else
                    Ok n


run : Int -> String -> Expectation
run len code =
    case countSections (default "" "") code 0 of
        Ok n ->
            Expect.equal len n

        Err info ->
            Expect.fail info


basic : Test
basic =
    let
        pattern =
            "(#{1,6} (\\w+ )+\\n([^#]+ )+\\n)"
    in
    describe "check Preprocessor against different types of sections"
        [ fuzz (fuzzRegex <| pattern ++ "{1}") "basic: length 1" <| run 1
        , fuzz (fuzzRegex <| pattern ++ "{2}") "basic: length 2" <| run 2
        , fuzz (fuzzRegex <| pattern ++ "{3}") "basic: length 3" <| run 3
        , fuzz (fuzzRegex <| pattern ++ "{5}") "basic: length 5" <| run 5
        , fuzz (fuzzRegex <| pattern ++ "{7}") "basic: length 7" <| run 7
        , fuzz (fuzzRegex <| pattern ++ "{11}") "basic: length 11" <| run 11
        ]
