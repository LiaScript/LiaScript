module Lia.Sync.Container.Local exposing
    ( Container
    , decode
    , decoder
    , empty
    , encode
    , get
    , init
    , isEmpty
    , union
    , union_
    )

{-| This is a basic container module for dealing with synchronized data. At
this moment it is a weak type of a CRDT, since it uses `Dict`s as a
replacement for `Set`s. Thus, keys are used to store the ids of remote peers.
If there is a conflict for some reason within the associated value, this is
at the moment ignored, entries will get merged and state simply ignored.

This local version of a `Container` is thought to be used for storing
replicated states locally or in other words per section.

**Why per `Section` and not as part of the sharable element itself?**

The reason for this is, that in order to perform synchronization, where
by different users different slides have been visited, the state has to
be stored outside of the elements, which at the point in time of the
synchronization might not exist for all peers.


## Data

@Container


## Convenience functions

@init ,@isEmpty, @empty, @get, @union, @union\_


## JSON

@encode, @decode, @decoder

-}

import Array exposing (Array)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import Set exposing (Set)


{-| A local container is an `Array` of `Dict`s, which mirrors the state to be
shared of quizzes, surveys, etc. per `Section`.
-}
type Container sync
    = Container (Array (Dict String sync))


{-| Used to initialize an entire Vector-state such as for Quizzes. The `id` to
be passed is the peer itself. The

Parameters:

  - `id`: Own peer-ID
  - `map`: A functions that translates the current state into a sharable state,
    not everything
  - `array`: The additional array defines the original state used within the
    quiz, survey, etc.

-}
init : String -> (x -> Maybe sync) -> Array x -> Container sync
init id map =
    Array.map
        (\x ->
            case map x of
                Just sync ->
                    Dict.fromList [ ( id, sync ) ]

                Nothing ->
                    Dict.empty
        )
        >> Container


get : Int -> Container sync -> Maybe (Dict String sync)
get i (Container bag) =
    Array.get i bag


{-| Determine if the given container is empty:

    isEmpty empty == True

-}
isEmpty : Container sync -> Bool
isEmpty (Container bag) =
    bag
        |> Array.toList
        |> List.all Dict.isEmpty


{-| Return an empty Container:

    isEmpty empty == True

-}
empty : Container sync
empty =
    Container Array.empty


{-| Merges two containers by preferring the first one if a collision occurs.
**Thus, the first container should always be the own one!** The first boolean
value means, that there was a difference, such that the new state should also
be send to the other peers.

    union a a =
        ( False, a )
    union a b =
        ( True, a ∪ b )
    union empty b =
        ( True, b )
    union a empty =
        ( True, b )

-}
union : Container sync -> Container sync -> ( Bool, Container sync )
union (Container internal) (Container external) =
    unionHelper True (Array.toList internal) (Array.toList external) []
        |> List.unzip
        |> unify


{-| To be used for **global** merges, preferring the first one if a collision
occurs. **Thus, the first container should always be the own one!** The first
boolean value means, that there was a difference, such that the new state
should also be send to the other peers.

In contrast to `union` this merge returns `True` if the internal and external
containers are not equal

-}
union_ : Container sync -> Container sync -> ( Bool, Container sync )
union_ (Container internal) (Container external) =
    unionHelper False (Array.toList internal) (Array.toList external) []
        |> List.unzip
        |> unify


unify : ( List Bool, List (Dict String sync) ) -> ( Bool, Container sync )
unify ( bool, list ) =
    ( if List.isEmpty list then
        False

      else
        List.any identity bool
    , list
        |> Array.fromList
        |> Container
    )


unionHelper : Bool -> List (Dict String sync) -> List (Dict String sync) -> List ( Bool, Dict String sync ) -> List ( Bool, Dict String sync )
unionHelper local internal external combined =
    case ( internal, external ) of
        ( [], [] ) ->
            List.reverse combined

        ( [], e :: es ) ->
            unionHelper local [] es (( True, e ) :: combined)

        ( i :: is, [] ) ->
            unionHelper local is [] (( True, i ) :: combined)

        ( i :: is, e :: es ) ->
            unionHelper local
                is
                es
                (( case ( Dict.size i, Dict.size e ) of
                    ( 0, 0 ) ->
                        False

                    _ ->
                        if local then
                            Dict.size (Dict.diff e i) /= 0

                        else
                            Dict.size (Dict.diff e i) /= Dict.size (Dict.diff i e)
                 , Dict.union i e
                 )
                    :: combined
                )


{-| Turn a Container into a JSON. This encoder is a generic encoder and
requires and additional encoder-function `fn` to encode the internal
`sync` type.
-}
encode : (sync -> JE.Value) -> Container sync -> JE.Value
encode fn (Container bag) =
    JE.array (JE.dict identity fn) bag


{-| Decode a JSON into a `Container`. An additional decoder for the custom
`sync` type has to be passed.
-}
decode : JD.Decoder sync -> JD.Value -> Result JD.Error (Container sync)
decode fn =
    JD.decodeValue (decoder fn)


{-| Decoder for custom `Container`s, thats why an additional decoder for
the custom `sync` type has to be passed.
-}
decoder : JD.Decoder sync -> JD.Decoder (Container sync)
decoder fn =
    JD.array (JD.dict fn) |> JD.map Container
