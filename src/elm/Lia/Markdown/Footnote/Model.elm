module Lia.Markdown.Footnote.Model exposing
    ( Model
    , init
    )

import Dict exposing (Dict)
import Lia.Markdown.Types as Markdown


{-| Footnote bodies of a section by their key, `[^key]` refers to them.
-}
type alias Model =
    Dict String Markdown.Blocks


{-| No footnotes.
-}
init : Model
init =
    Dict.empty
