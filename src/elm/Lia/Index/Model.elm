module Lia.Index.Model exposing
    ( Model
    , init
    )

{-| The table of contents: the search pattern, the ids of the sections whose
subsections are collapsed and the entry with the focus as `(current section,
entry)`, it is only valid as long as the current section does not change.
`defaults` is set, once the sections below the two upper levels got collapsed
(see `Lia.Index.Update.reveal`).
-}

import Set exposing (Set)


{-| -}
type alias Model =
    { search : String
    , collapsed : Set Int
    , focus : Maybe ( Int, Int )
    , defaults : Bool
    }


{-| No search, all sections are visible and expanded.
-}
init : Model
init =
    { search = "", collapsed = Set.empty, focus = Nothing, defaults = False }
