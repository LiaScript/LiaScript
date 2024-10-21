module Lia.Json.Decode exposing (decode)

import Array
import Dict
import I18n.Translations as Translations
import Json.Decode as JD
import Lia.Chat.Model as Chat
import Lia.Definition.Json.Decode as Definition
import Lia.Index.Model as Index
import Lia.Markdown.Inline.Json.Decode as Inline
import Lia.Model exposing (Model)
import Lia.Parser.PatReplace exposing (repo)
import Lia.Section as Section
import Lia.Settings.Types as Settings
import Lia.Sync.Types as Sync
import Library.Overlay as Overlay
import Library.SplitPane as SplitPane


{-| Decode the entire structure of a pre-parsed LiaScript course. The additional
screen `width` is only used to render the course with an opened or closed table
of contents.
-}
decode : Int -> SplitPane.State -> Sync.Settings -> JD.Value -> Result JD.Error Model
decode seed pane sync =
    toModel seed pane sync
        |> JD.decodeValue


andMap : String -> JD.Decoder a -> JD.Decoder (a -> value) -> JD.Decoder value
andMap key dec =
    JD.map2 (|>) (JD.field key dec)


toModel : Int -> SplitPane.State -> Sync.Settings -> JD.Decoder Model
toModel seed pane sync =
    JD.succeed Model
        |> andMap "url" JD.string
        |> andMap "readme" (JD.string |> JD.map repo)
        |> andMap "readme" JD.string
        |> andMap "origin" JD.string
        |> andMap "str_title" JD.string
        |> JD.map2 (|>) (JD.succeed (Settings.init False Settings.Slides))
        |> JD.map2 (|>) (JD.succeed Nothing)
        |> andMap "sections" (JD.array toSectionBase |> JD.map (Array.indexedMap (Section.init seed)))
        |> andMap "section_active" JD.int
        |> JD.map2 (|>) (JD.succeed Nothing)
        |> andMap "definition" Definition.decode
        |> JD.map2 (|>) (JD.succeed Index.init)
        |> JD.map2 (|>) (JD.succeed [])
        |> JD.map2 (|>) (JD.succeed [])
        |> andMap "translation"
            (JD.string
                |> JD.map (Translations.getLnFromCode >> Maybe.withDefault Translations.En)
            )
        |> andMap "translation" JD.string
        |> andMap "translation" JD.string
        |> JD.map2 (|>) (JD.succeed identity)
        |> JD.map2 (|>) (JD.succeed Dict.empty)
        |> JD.map2 (|>) (JD.succeed Dict.empty)
        |> JD.map2 (|>) (JD.succeed Nothing)
        |> JD.map2 (|>) (JD.succeed sync)
        |> JD.map2 (|>) (JD.succeed False)
        |> JD.map2 (|>) (JD.succeed seed)
        |> JD.map2 (|>) (JD.succeed pane)
        |> JD.map2 (|>) (JD.succeed Chat.init)
        |> JD.map2 (|>) (JD.succeed Overlay.init)


toSectionBase : JD.Decoder Section.Base
toSectionBase =
    JD.map4 Section.Base
        (JD.field "indentation" JD.int)
        (JD.succeed 0)
        (JD.field "title" Inline.decode)
        (JD.field "code" JD.string)
