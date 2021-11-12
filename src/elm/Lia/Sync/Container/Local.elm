module Lia.Sync.Container.Local exposing
    ( Container
    , decode
    , encode
    , init
    , isEmpty
    , size
    , union
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE


type Container sync
    = Container (Array (Dict String sync))


isEmpty : Container sync -> Bool
isEmpty (Container bag) =
    bag
        |> Array.toList
        |> List.all Dict.isEmpty


init : String -> (x -> Maybe sync) -> Array x -> Container sync
init id fn =
    Array.map
        (\x ->
            Dict.empty
                |> (case fn x of
                        Just sync ->
                            Dict.insert id sync

                        Nothing ->
                            identity
                   )
        )
        >> Container


size : Container sync -> Int
size (Container data) =
    Array.length data


union : Container sync -> Container sync -> ( Bool, Container sync )
union (Container a) (Container b) =
    List.map2 unionHelper (Array.toList a) (Array.toList b)
        |> List.unzip
        |> Tuple.mapFirst (List.all identity)
        |> Tuple.mapSecond (Array.fromList >> Container)


unionHelper : Dict String sync -> Dict String sync -> ( Bool, Dict String sync )
unionHelper a b =
    let
        c =
            Dict.union a b
    in
    ( Dict.size a
        == Dict.size b
        && Dict.size b
        == Dict.size c
    , c
    )


encode : (sync -> JE.Value) -> Container sync -> JE.Value
encode fn (Container bag) =
    JE.array (JE.dict identity fn) bag


decode : JD.Decoder sync -> JD.Value -> Result JD.Error (Container sync)
decode fn =
    JD.decodeValue (JD.array (JD.dict fn)) >> Result.map Container
