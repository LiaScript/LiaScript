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
import Lia.Utils exposing (urlQuery)
import Library.Overlay as Overlay
import Library.SplitPane as SplitPane


{-| Decode a pre-parsed LiaScript course, as stored by `Lia.Json.Encode.encode`.
The `seed`, the split `pane` and the classroom settings (`sync`) are taken over
from the running app, everything else that is not stored gets its default
value. The sections still have to be parsed when they are visited.
-}
decode : Int -> SplitPane.State -> Sync.Settings -> JD.Value -> Result JD.Error Model
decode seed pane sync =
    JD.field "readme" JD.string
        |> JD.andThen (toModel seed pane sync)
        |> JD.decodeValue


toModel : Int -> SplitPane.State -> Sync.Settings -> String -> JD.Decoder Model
toModel seed pane sync readme =
    JD.map7
        (\url origin title sections section_active definition language ->
            { url = url
            , repositoryUrl = repo readme
            , readme = readme
            , origin = origin
            , title = title
            , settings = Settings.init (Just False) False Settings.Slides
            , error = Nothing
            , sections = sections
            , section_active = section_active
            , anchor = Nothing
            , definition = definition
            , index_model = Index.init
            , resource = []
            , to_do = []
            , translation =
                language
                    |> Translations.getLnFromCode
                    |> Maybe.withDefault Translations.En
            , langCode = language
            , langName = Nothing
            , langCodeOriginal = language
            , search_index = identity
            , media = Dict.empty
            , modal = Nothing
            , sync = sync
            , persistent = False
            , seed = seed
            , pane = pane
            , chat = Chat.init
            , overlayVideo = Overlay.init
            }
        )
        (JD.field "url" JD.string)
        (JD.field "origin" JD.string)
        (JD.field "str_title" JD.string)
        (JD.field "sections" (JD.array toSectionBase |> JD.map (Array.indexedMap (Section.init seed))))
        (JD.field "section_active" JD.int)
        (readme
            |> urlQuery
            |> Maybe.map ((++) "?")
            |> Maybe.withDefault ""
            |> Definition.decode
            |> JD.field "definition"
        )
        (JD.field "translation" JD.string)


toSectionBase : JD.Decoder Section.Base
toSectionBase =
    JD.map3 Section.Base
        (JD.field "indentation" JD.int)
        (JD.field "title" Inline.decode)
        (JD.field "code" JD.string)
