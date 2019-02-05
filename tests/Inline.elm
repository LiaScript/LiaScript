module Inline exposing (bold)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import LiaFuzz exposing (fuzzRegex)
import Test exposing (..)


bold : Test
bold =
    describe "generate different kinds of numbers"
        [ fuzz (fuzzRegex "a{3}") "test" <| \str -> Expect.equal str "aaa"
        ]
