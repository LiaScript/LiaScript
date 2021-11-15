module Lia.Model exposing
    ( Model
    , init
    , loadResource
    )

import Array
import Dict exposing (Dict)
import Json.Encode as JE
import Lia.Definition.Types as Definition exposing (Definition, Resource(..))
import Lia.Index.Model as Index
import Lia.Parser.PatReplace exposing (repo)
import Lia.Section exposing (Sections)
import Lia.Settings.Json
import Lia.Settings.Types as Settings exposing (Settings)
import Lia.Sync.Types as Sync
import Port.Event as Event exposing (Event)
import Translations


{-| The global LiaScript model for one course. It contains:

  - `url`: the entire URL, which contains the current website and course URL as a
    parameter `http://localhost:1234/?http://www.../README.md`

  - `readme`: the entire course URL `http://www.../README.md`

  - `origin`: the course URL without the file extension `http://www.../`, this
    is later added in front of all relative paths

  - `title`: to be shown in the tab, it is basically a stringified version of
    the first title-tag of the course

  - `settings`:

  - `error`: contains parsing error messages

  - `sections`: an array of all pre-parsed sections

  - `section_active`: the currently visible section id

  - `anchor`: is used to store the initial URL fragment, which might be a
    section number or a title string, this is used on the first load to identify
    the section to be shown

  - `definition`: all elements (configurations) that are defined in the main
    header of the document, covering `@author`, `@email`, `@import`, `@script`,
    etc.

  - `index_model`: section search

  - `resource`: a list of all javascript and css files that have to be loaded

  - `to_do`: before a course can be rendered entirely, some tasks have to be
    fulfilled, such as loading external resources, checking in the backend, if
    there is some data on quizzes, that has to be restored, etc. All of this is
    collected as events and send immediately through the elm-port to js.

  - `translation`: the defined language of a course (the default is english),
    this setting is used for translations for buttons, user-messages, etc.

  - `search_index`: an index on titles, that is used if relative links are
    defined, such as `[...](#section-title)`. This string is searched and
    replaced by the local id of the section in the sections array

-}
type alias Model =
    { url : String
    , repositoryUrl : Maybe String
    , readme : String
    , origin : String
    , title : String
    , settings : Settings
    , error : Maybe String
    , sections : Sections
    , section_active : Int
    , anchor : Maybe String
    , definition : Definition
    , index_model : Index.Model
    , resource : List Resource
    , to_do : List Event
    , translation : Translations.Lang
    , langCode : String
    , langCodeOriginal : String
    , search_index : String -> String
    , media : Dict String ( Int, Int )
    , modal : Maybe String
    , sync : Sync.Settings
    }


{-| Initialize the LiaScript Model with basic configurations:

  - `openTOC`: should the table of contents be visible? This is only a fallback,
    if the settings cannot be decoded successfully.
  - `settings`: common LiaScript settings, that cover fontSize, enabled
    Text2Speech output, user defined presentation mode, etc. This data is stored
    in the localStorage and has to be imported via the main port.
  - `url`: the entire URL, which contains the current website and course URL as a
    parameter `http://localhost:1234/?http://www.../README.md`
  - `readme`: the entire course URL `http://www.../README.md`
  - `origin`: the course URL without the file extension `http://www.../`, this
    is later added in front of all relative paths
  - `slide_number`: commonly defined by the URL fragment, used to indicate the
    active section (defaults to 1)

-}
init : Bool -> Bool -> JE.Value -> List String -> String -> String -> String -> Maybe String -> Model
init hasShareApi openTOC settings allowedBackends url readme origin anchor =
    let
        default =
            Settings.init hasShareApi Settings.Presentation
    in
    { url = url
    , repositoryUrl = repo readme
    , readme = readme
    , origin = origin
    , title = "Lia"
    , settings =
        settings
            |> Lia.Settings.Json.toModel default
            |> Result.withDefault default
            |> (\set -> { set | table_of_contents = openTOC })
    , error = Nothing
    , sections = Array.empty
    , section_active = 0
    , anchor = anchor
    , definition = Definition.default url
    , index_model = Index.init
    , resource = []
    , to_do = []
    , translation = Translations.En
    , langCode = "en"
    , langCodeOriginal = "en"
    , search_index = identity
    , media = Dict.empty
    , modal = Nothing
    , sync = Sync.init readme allowedBackends
    }


{-| Prevent loading external resources (JavaScript, CSS) multiple times, by
comparing them to another resource-list. The result is a new list of resources
as well as a list of events to be send through the elm-port.
-}
loadResource : List Resource -> List Resource -> ( List Resource, List Event )
loadResource old new =
    let
        member x =
            not (List.member x old)

        to_load =
            List.filter member new
    in
    ( List.append old to_load
    , List.map
        (\res ->
            Event.init "resource" <|
                JE.list JE.string <|
                    case res of
                        Script url ->
                            [ "script", url ]

                        Link url ->
                            [ "link", url ]
        )
        to_load
    )
