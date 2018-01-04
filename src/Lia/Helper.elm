module Lia.Helper exposing (..)

import Array exposing (Array)


type alias ID =
    Int


type alias Vector element =
    Array element


get : ID -> Vector element -> Maybe element
get idx vector =
    Array.get idx vector
