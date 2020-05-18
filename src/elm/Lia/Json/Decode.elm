module Lia.Json.Decode exposing (decode)

import Array
import Json.Decode as JD
import Lia.Definition.Json.Decode as Definition
import Lia.Index.Model as Index
import Lia.Markdown.Inline.Json.Decode as Inline
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Model exposing (Model)
import Lia.Section as Section
import Lia.Settings.Model as Settings
import Translations


decode : Int -> JD.Value -> Result JD.Error Model
decode width =
    JD.decodeValue (toModel width)


andMap : String -> JD.Decoder a -> JD.Decoder (a -> value) -> JD.Decoder value
andMap key dec =
    JD.map2 (|>) (JD.field key dec)


toModel : Int -> JD.Decoder Model
toModel width =
    JD.succeed Model
        |> andMap "url" JD.string
        |> andMap "readme" JD.string
        |> andMap "origin" JD.string
        |> andMap "str_title" JD.string
        |> JD.map2 (|>) (JD.succeed (Settings.init width Settings.Slides))
        |> JD.map2 (|>) (JD.succeed Nothing)
        |> andMap "sections" (JD.array toSectionBase |> JD.map (Array.indexedMap Section.init))
        |> andMap "section_active" JD.int
        |> andMap "definition" Definition.decode
        |> JD.map2 (|>) (JD.succeed Index.init)
        |> JD.map2 (|>) (JD.succeed [])
        |> JD.map2 (|>) (JD.succeed [])
        |> andMap "translation" (JD.string |> JD.map Translations.getLnFromCode)
        |> JD.map2 (|>) (JD.succeed identity)



--|> JD.map2 (|>) (JD.succeed True)


toSectionBase : JD.Decoder Section.Base
toSectionBase =
    JD.map3 Section.Base
        (JD.field "indentation" JD.int)
        (JD.field "title" Inline.decode)
        (JD.field "code" JD.string)
