module Lia.Model exposing
    ( Model
    , init
    , load_src
    , settings2model
    )

import Array
import Json.Decode as JD
import Json.Encode as JE
import Lia.Definition.Types as Definition exposing (Definition, Resource(..))
import Lia.Index.Model as Index
import Lia.Settings.Model as Settings
import Lia.Types exposing (Sections)
import Port.Event exposing (Event)
import Translations


type alias Model =
    { url : String
    , readme : String
    , origin : String
    , title : String
    , settings : Settings.Model
    , error : Maybe String
    , sections : Sections
    , section_active : Int
    , definition : Definition
    , index_model : Index.Model
    , resource : List Resource
    , to_do : List Event
    , translation : Translations.Lang
    , ready : Bool
    , search_index : String -> String
    }


settings2model : Model -> Result JD.Error Settings.Model -> Model
settings2model model settings =
    case settings of
        Ok new_settings ->
            { model | settings = new_settings }

        Err _ ->
            model


init : Settings.Mode -> String -> String -> String -> Maybe Int -> Model
init mode url readme origin slide_number =
    { url = url
    , readme = readme
    , origin = origin
    , title = "Lia"
    , settings = Settings.init mode
    , error = Nothing
    , sections = Array.empty
    , section_active =
        case slide_number of
            Nothing ->
                0

            Just idx ->
                if (idx - 1) > 0 then
                    idx - 1

                else
                    0
    , definition = Definition.default url
    , index_model = Index.init
    , resource = []
    , to_do = []
    , translation = Translations.En
    , ready = False
    , search_index = identity
    }


load_src : List Resource -> List Resource -> ( List Resource, List Event )
load_src old new =
    let
        member x =
            not (List.member x old)

        to_load =
            List.filter member new
    in
    ( List.append old to_load
    , List.map
        (\res ->
            Event "resource" 0 <|
                JE.list JE.string <|
                    case res of
                        Script url ->
                            [ "script", url ]

                        Link url ->
                            [ "link", url ]
        )
        to_load
    )
