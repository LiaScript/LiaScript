module Lia.Sync.Container.Global exposing
    ( Container
    , decode
    , decoder
    , encode
    , union
    )

{-| This `Container` type type is meant to be used for global synchronizations,
which can be used during the joining-phase. Thus, the entire state `Local` of
all `Sections` for quizzes, surveys, etc. can be converted to this type and
send to all peers.

As for `Local.Container` this is used as a state-based CRDT, which means that
the entire state is send to all peers.


## Data

@Container


## Convenience

@union


## JSON

@encode, @decode, @decoder

-}

import Array exposing (Array)
import Dict
import Json.Decode as JD
import Json.Encode as JE
import Lia.Sync.Container.Local as Local


{-| This is an `Array` of Local.Containers. It might be the case, that there
are no `Local.Container`s at the moment for certain `Section`s, since their
state is only restored/created when the `Section` was visited by the user.
That is why, they are represented as `Maybe`.
-}
type alias Container sync =
    Array (Maybe (Local.Container sync))


{-| Perform a merge between two global `Container`s (CRDT). At the moment the
first (internal) container is preferred. Thus, if there is a conflict between
the two `Container`s the external ones are ignored. The first boolean value
within the result tuple defines whether the resulting `Container` contains
updates that should be send to all peers.

    union a a =
        ( False, a )
    union a b =
        ( True, a ∪ b )
    union empty b =
        ( False, b )
    union a empty =
        ( True, a )

-}
union : Container sync -> Container sync -> ( Bool, Container sync )
union internal external =
    []
        |> unionHelper (Array.toList internal) (Array.toList external)
        |> List.unzip
        |> Tuple.mapFirst (List.all identity)
        |> Tuple.mapSecond Array.fromList


unionHelper :
    List (Maybe (Local.Container sync))
    -> List (Maybe (Local.Container sync))
    -> List ( Bool, Maybe (Local.Container sync) )
    -> List ( Bool, Maybe (Local.Container sync) )
unionHelper internal external combination =
    case ( internal, external ) of
        ( [], [] ) ->
            List.reverse combination

        ( i :: is, [] ) ->
            unionHelper
                is
                []
                (( i /= Nothing, i ) :: combination)

        ( [], e :: es ) ->
            unionHelper
                []
                es
                (( False, e ) :: combination)

        ( (Just i) :: is, (Just e) :: es ) ->
            unionHelper
                is
                es
                (Tuple.mapSecond Just (Local.union i e) :: combination)

        ( (Just i) :: is, Nothing :: es ) ->
            unionHelper
                is
                es
                (( True, Just i ) :: combination)

        ( Nothing :: is, (Just e) :: es ) ->
            unionHelper
                is
                es
                (( False, Just e ) :: combination)

        ( Nothing :: is, Nothing :: es ) ->
            unionHelper
                is
                es
                (( False, Nothing ) :: combination)


{-| Convert a global `Container` into a JSON value. Since it is assumed, that
these are are rather sparse vectors, that is why not the entire `Container`
is translated into an JSON, but only a `dict` of values, where the `key`
represents the position within the `Array`.

    encode fn container =
        {"1": ..., "33": ..., "5": ...}

An additional encoder has to be passed, which defines how the custom `sync`
values have to be encoded.

-}
encode : (sync -> JE.Value) -> Container sync -> JE.Value
encode fn =
    Array.toIndexedList
        >> List.filterMap (filter fn)
        >> JE.object


{-| Decode a JSON value into an "global" `Container`, which is an `Array` of
`Local.Container`. Since the `encode` function performs a sparse encoding,
which only transmits valid states as a `Dict`. The resulting `Container`
might be shorter than the internally used state-vector. However, the `union`
function takes care of this.

    decode fn {"1": ..., "4": ...} ==
        Array.fromList [Nothing, Just ..., Nothing, Nothing, Just ...]

-}
decode : JD.Decoder sync -> JE.Value -> Result JD.Error (Container sync)
decode fn =
    JD.decodeValue (decoder fn)


{-| Decoder for custom `Container`s, thats why an additional decoder for
the custom `sync` type has to be passed.
-}
decoder : JD.Decoder sync -> JD.Decoder (Container sync)
decoder fn =
    JD.dict (Local.decoder fn)
        |> JD.map
            (Dict.toList
                >> List.map (Tuple.mapFirst String.toInt)
                >> toContainer
            )


{-| **private:** Transform a `List` of (`Int` identifiers, `Local.Containers`)
into an global `Container`. The maximum index of the input-list is used to
generate an initial `Container`, which is then filled with the elements from
the input list.
-}
toContainer : List ( Maybe Int, Local.Container sync ) -> Container sync
toContainer tuples =
    fill tuples
        (Array.repeat
            (tuples
                |> List.filterMap Tuple.first
                |> List.maximum
                |> Maybe.withDefault 0
            )
            Nothing
        )


{-| **private:** Fill in the transmitted values at the predefined position within
the `Array`, the rest remains `Nothing`.
-}
fill : List ( Maybe Int, Local.Container sync ) -> Container sync -> Container sync
fill tuples container =
    case tuples of
        [] ->
            container

        ( Just i, sync ) :: ts ->
            fill ts (Array.set i (Just sync) container)

        ( Nothing, _ ) :: ts ->
            fill ts container


{-| **private:** Internally applied filter, that checks if a `Local.Container`
is defined and not empty. If this is the case, a tuple with a `String`
representation of the index is returned with a JSON representation of the
`Local.Container`.
-}
filter : (sync -> JE.Value) -> ( Int, Maybe (Local.Container sync) ) -> Maybe ( String, JE.Value )
filter fn ( i, local ) =
    case local of
        Just container ->
            if Local.isEmpty container then
                Nothing

            else
                Just ( String.fromInt i, Local.encode fn container )

        _ ->
            Nothing
