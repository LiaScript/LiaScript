module Main exposing (..)

import Benchmark exposing (Benchmark)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Lia
import Readme


suite : Benchmark
suite =
    let
        lia =
            Lia.init_slides Readme.text
    in
    Benchmark.benchmark1 "Lia.parse" Lia.parse lia


main : BenchmarkProgram
main =
    program suite
