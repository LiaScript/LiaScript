module Lia.Model exposing
    ( Model
    , init
    , load_src
    , settings2model
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Definition.Types as Definition exposing (Definition)
import Lia.Helper exposing (ID)
import Lia.Index.Model as Index
import Lia.Settings.Model as Settings
import Lia.Types exposing (Event2JS, Sections)
import Translations


type alias Model =
    { url : String
    , readme : String
    , origin : String
    , title : String
    , settings : Settings.Model
    , error : Maybe String
    , sections : Sections
    , section_active : ID
    , definition : Definition
    , index_model : Index.Model
    , javascript : List String
    , to_do : List Event2JS
    , translation : Translations.Lang
    , ready : Bool
    }


settings2model : Model -> Result JD.Error Settings.Model -> Model
settings2model model settings =
    case settings of
        Ok new_settings ->
            { model | settings = new_settings }

        Err msg ->
            model


init : Settings.Mode -> String -> String -> String -> Maybe Int -> Model
init mode url readme origin slide_number =
    { url = url
    , readme = readme
    , origin = origin
    , title = "Lia"
    , settings = Settings.init
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
    , javascript = []
    , to_do = []
    , translation = Translations.En
    , ready = False
    }


load_src : String -> List String -> List String -> ( List String, List Event2JS )
load_src tag old new =
    let
        member x =
            not (List.member x old)

        to_load =
            List.filter member new
    in
    ( List.append old to_load
    , List.map (\url -> Event2JS "ressource" 0 <| JE.list JE.string [ tag, url ]) to_load
    )
