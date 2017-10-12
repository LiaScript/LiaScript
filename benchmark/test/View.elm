module Main exposing (..)

import Benchmark exposing (Benchmark)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Lia
import Readme


suite : Benchmark
suite =
    let
        lia =
            Lia.init_slides
    in
    Benchmark.benchmark2 "Lia.parse" Lia.parse Readme.text lia


main : BenchmarkProgram
main =
    program suite
