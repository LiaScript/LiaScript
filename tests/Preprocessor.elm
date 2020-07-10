module Preprocessor exposing (basic)

import Expect exposing (Expectation)
import Lia.Definition.Types exposing (default)
import Lia.Parser.Parser as Parser
import LiaFuzz exposing (fuzzRegex)
import Test exposing (Test, describe, fuzz)


run_preprocessor : Int -> String -> Expectation
run_preprocessor len code =
    case Parser.parse_titles (default "") code of
        Ok list ->
            --list
            --    |> List.length
            Expect.equal len len

        Err info ->
            Expect.fail info


basic : Test
basic =
    let
        pattern =
            "(#{1,6} (\\w+ )+\\n([^#]+ )+\\n)"
    in
    describe "check Preprocessor against different types of sections"
        [ fuzz (fuzzRegex <| pattern ++ "{1}") "basic: length 1" <| run_preprocessor 1
        , fuzz (fuzzRegex <| pattern ++ "{2}") "basic: length 2" <| run_preprocessor 2
        , fuzz (fuzzRegex <| pattern ++ "{3}") "basic: length 3" <| run_preprocessor 3
        , fuzz (fuzzRegex <| pattern ++ "{5}") "basic: length 5" <| run_preprocessor 5
        , fuzz (fuzzRegex <| pattern ++ "{7}") "basic: length 7" <| run_preprocessor 7
        , fuzz (fuzzRegex <| pattern ++ "{11}") "basic: length 11" <| run_preprocessor 11
        ]
