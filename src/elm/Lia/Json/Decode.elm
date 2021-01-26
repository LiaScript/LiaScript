module Lia.Json.Decode exposing (decode)

import Array
import Dict
import Json.Decode as JD
import Lia.Definition.Json.Decode as Definition
import Lia.Index.Model as Index
import Lia.Markdown.Inline.Json.Decode as Inline
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Model exposing (Model)
import Lia.Section as Section
import Lia.Settings.Model as Settings
import Translations


{-| Decode the entire structure of a preparsed LiaScript course. The additional
screen `width` is only used to render the course with an opened or closed table
of contents.
-}
decode : JD.Value -> Result JD.Error Model
decode =
    JD.decodeValue toModel


andMap : String -> JD.Decoder a -> JD.Decoder (a -> value) -> JD.Decoder value
andMap key dec =
    JD.map2 (|>) (JD.field key dec)


toModel : JD.Decoder Model
toModel =
    JD.succeed Model
        |> andMap "url" JD.string
        |> andMap "readme" JD.string
        |> andMap "origin" JD.string
        |> andMap "str_title" JD.string
        |> JD.map2 (|>) (JD.succeed (Settings.init Settings.Slides))
        |> JD.map2 (|>) (JD.succeed Nothing)
        |> andMap "sections" (JD.array toSectionBase |> JD.map (Array.indexedMap Section.init))
        |> andMap "section_active" JD.int
        |> JD.map2 (|>) (JD.succeed Nothing)
        |> andMap "definition" Definition.decode
        |> JD.map2 (|>) (JD.succeed Index.init)
        |> JD.map2 (|>) (JD.succeed [])
        |> JD.map2 (|>) (JD.succeed [])
        |> andMap "translation" (JD.string |> JD.map Translations.getLnFromCode)
        |> JD.map2 (|>) (JD.succeed identity)
        |> JD.map2 (|>) (JD.succeed Dict.empty)


toSectionBase : JD.Decoder Section.Base
toSectionBase =
    JD.map4 Section.Base
        (JD.field "indentation" JD.int)
        (JD.succeed 0)
        (JD.field "title" Inline.decode)
        (JD.field "code" JD.string)
