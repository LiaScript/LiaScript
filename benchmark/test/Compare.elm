module Main exposing (input, main, suite)

import Benchmark exposing (Benchmark)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Combine exposing (..)
import Combine.Char exposing (..)
import Time


input =
    """          asdfasdf            asdadsfa

# tester hh123


"""


suite : Benchmark
suite =
    let
        spaces =
            regex "[ \t]*"

        p1 =
            parse (regex "[\t ]*\\w+[\t ]*" |> map String.trim)

        p2 =
            parse (regex "[ \t]*\\w+[ \t]*" |> map String.trim)
    in
    Benchmark.compare "character parse"
        (Benchmark.benchmark1 "char" p1 input)
        --(Benchmark.benchmark1 "many1" p2 input)
        (Benchmark.benchmark1 "string" p2 input)
        |> Benchmark.withRuntime (60 * Time.second)


main : BenchmarkProgram
main =
    program suite
