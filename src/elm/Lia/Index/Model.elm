module Lia.Index.Model exposing
    ( Model
    , init
    )

{-| The search pattern of the table of contents.
-}


{-| -}
type alias Model =
    String


{-| No search, all sections are visible.
-}
init : Model
init =
    ""
