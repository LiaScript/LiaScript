module Lia.Sync.Container exposing
    ( Container
    , decode
    , empty
    , encode
    , insert
    , isEmpty
    , singleton
    , size
    , toList
    , union
    )

import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE


type Container sync
    = Container (Dict String sync)


isEmpty : Container sync -> Bool
isEmpty (Container bag) =
    Dict.isEmpty bag


empty : Container sync
empty =
    Container Dict.empty


size : Container sync -> Int
size (Container data) =
    Dict.size data


union : Container sync -> Container sync -> ( Bool, Container sync )
union (Container a) (Container b) =
    let
        c =
            Dict.union a b
    in
    ( Dict.size a
        == Dict.size b
        && Dict.size b
        == Dict.size c
    , Container c
    )


insert : String -> sync -> Container sync -> ( Bool, Container sync )
insert id data (Container old) =
    let
        new =
            Dict.insert id data old
    in
    ( Dict.size new == Dict.size old, Container new )


singleton : String -> sync -> Container sync
singleton id data =
    [ ( id, data ) ]
        |> Dict.fromList
        |> Container


toList : Container sync -> List sync
toList (Container data) =
    Dict.values data


encode : (sync -> JE.Value) -> Container sync -> JE.Value
encode fn (Container bag) =
    JE.dict identity fn bag


decode : JD.Decoder sync -> JD.Value -> Result JD.Error (Container sync)
decode fn =
    JD.decodeValue (JD.dict fn) >> Result.map Container
