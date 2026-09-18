module Lia.Sync.Container exposing
    ( Container
    , decoder
    , encode
    , get
    , init
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

@init, @get


## JSON

@encode, @decoder

-}

import Array exposing (Array)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE


{-| A local container is an `Array` of `Dict`s, which mirrors the state to be
shared of quizzes, surveys, etc. per `Section`.
-}
type Container sync
    = Container (Array (Dict String sync))


{-| Initialize an entire Container from a section's current state-array, e.g.
for quizzes or surveys.

Parameters:

  - `id`: own peer-ID, the key this container's initial values are stored
    under
  - `map`: translates one array element into its sharable sync state, or
    `Nothing` if it has nothing worth sharing yet (e.g. unanswered)
  - the `Array` itself: the section's current quiz/survey/... state

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


{-| Turn a Container into a JSON. This encoder is a generic encoder and
requires and additional encoder-function `fn` to encode the internal
`sync` type.
-}
encode : (sync -> JE.Value) -> Container sync -> JE.Value
encode fn (Container bag) =
    JE.array (JE.dict identity fn) bag


{-| Decoder for custom `Container`s, thats why an additional decoder for
the custom `sync` type has to be passed.
-}
decoder : JD.Decoder sync -> JD.Decoder (Container sync)
decoder fn =
    JD.array (JD.dict fn) |> JD.map Container
