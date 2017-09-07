module Main exposing (..)

import Benchmark exposing (Benchmark)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Combine exposing (..)
import Lia.Inline.Parser exposing (..)
import Readme
import Time


input =
    """

# tester hh123


"""


title_tag : Parser s Int
title_tag =
    String.length <$> (newlines *> regex "#+" <* whitespace)


title_str1 : Parser s String
title_str1 =
    String.trim <$> regex ".+[\\n]+"


title_str2 : Parser s String
title_str2 =
    String.trim <$> regex ".+" <* many1 newline


pp1 : Parser s String
pp1 =
    let
        p1 =
            String.length <$> (newlines *> regex "#+" <* whitespace)

        p2 =
            String.trim <$> regex ".+[\\n]+"
    in
    p1 *> p2


suite : Benchmark
suite =
    let
        p1 =
            parse (title_tag *> title_str1)

        p2 =
            parse (title_tag *> title_str2)

        p11 =
            parse pp1
    in
    Benchmark.compare "regex"
        (Benchmark.benchmark1 "regex" p1 input)
        --(Benchmark.benchmark1 "many1" p2 input)
        (Benchmark.benchmark1 "regex let" p11 input)
        |> Benchmark.withRuntime (200 * Time.second)


main : BenchmarkProgram
main =
    program suite
