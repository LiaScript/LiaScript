module Lia.Model exposing
    ( Model
    , init
    , load_src
    )

import Array
import Json.Encode as JE
import Lia.Definition.Types as Definition exposing (Definition, Resource(..))
import Lia.Index.Model as Index
import Lia.Section exposing (Sections)
import Lia.Settings.Json
import Lia.Settings.Model as Settings
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
    , search_index : String -> String
    }


init : Int -> JE.Value -> String -> String -> String -> Maybe Int -> Model
init width settings url readme origin slide_number =
    let
        default =
            Settings.init width Settings.Presentation
    in
    { url = url
    , readme = readme
    , origin = origin
    , title = "Lia"
    , settings =
        settings
            |> Lia.Settings.Json.toModel default
            |> Result.withDefault default
            |> (\set ->
                    { set
                        | table_of_contents =
                            if width > 620 then
                                set.table_of_contents

                            else
                                False
                    }
               )
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
