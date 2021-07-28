module Lia.Classroom.Classroom exposing (..)


type alias Classroom =
    { sync : Via
    , name : String
    , course : String
    }


type Status
    = Connecting
    | Connected
    | Closed


type Via
    = Beaker
