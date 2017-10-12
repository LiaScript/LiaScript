module Main exposing (..)

import Benchmark exposing (Benchmark)
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Dict
import Lia exposing (parse)
import Readme


--import Time


suite : Benchmark
suite =
    --    let
    --        lia =
    --            Lia.init_slides
    --    in
    --Benchmark.benchmark2 "Lia.parse" Lia.parse Readme.text Lia.init_slides |> Benchmark.withRuntime (200 * Time.second)
    Benchmark.benchmark2 "Dict.get" Dict.get "a" (Dict.singleton "a" 1)


main : BenchmarkProgram
main =
    program suite
