module Lia.Markdown.Task.Types exposing
    ( Task
    , Vector
    )

{-| As in most LiaScript modules, the representation is separated from the
state. The boolean state is held within the `Vector` per section, and the place
elements for visualization are stored within the `Task` record.
-}

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)


{-| Stores the boolen state for all Task lists per section. Every entry
represents the states for an entire Task list:

    [ [ True, False, True, True ]
    , [ False, False ]
    ]

-}
type alias Vector =
    Array (Array Bool)


{-| This type is used by the LiaScript renderer:

  - `task`: one List element referes to on boolean value within the state Vector
  - `id`: reference to the state within the `Vector`
  - `javascript`: contains some optional code that is executed on every input
    (onCheck)

-}
type alias Task =
    { task : List Inlines
    , id : Int
    , javascript : Maybe String
    }
