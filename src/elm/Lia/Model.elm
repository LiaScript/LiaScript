module Lia.Model exposing
    ( Model
    , Toogler
    , init
    , json2settings
    , load_src
    , model2settings
    , settings2json
    , settings2model
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Definition.Types as Definition exposing (Definition)
import Lia.Helper exposing (ID)
import Lia.Index.Model as Index
import Lia.Types exposing (Design, Mode(..), Sections)
import Translations


type alias Toogler =
    { toc : Bool
    , settings : Bool
    , informations : Bool
    , translations : Bool
    , share : Bool
    }


type alias Model =
    { url : String
    , readme : String
    , origin : String
    , title : String
    , mode : Mode
    , error : Maybe String
    , sections : Sections
    , section_active : ID
    , definition : Definition
    , design : Design
    , index_model : Index.Model
    , sound : Bool
    , show : Toogler
    , javascript : List String
    , to_do : List ( String, Int, JE.Value )
    , translation : Translations.Lang
    , ready : Bool
    }


type alias Settings =
    { toc : Bool
    , mode : String
    , theme : String
    , light : String
    , ace : String
    , font_size : Int
    , sound : Bool
    }


model2settings : Model -> Settings
model2settings model =
    { toc = model.show.toc
    , mode =
        case model.mode of
            Slides ->
                "Slides"

            Presentation ->
                "Presentation"

            Textbook ->
                "Textbook"
    , theme = model.design.theme
    , light = model.design.light
    , ace = model.design.ace
    , font_size = model.design.font_size
    , sound = model.sound
    }


settings2json : Settings -> JE.Value
settings2json v =
    JE.object
        [ ( "toc", JE.bool v.toc )
        , ( "mode", JE.string v.mode )
        , ( "theme", JE.string v.theme )
        , ( "light", JE.string v.light )
        , ( "ace", JE.string v.ace )
        , ( "font_size", JE.int v.font_size )
        , ( "sound", JE.bool v.sound )
        ]


json2settings : JD.Value -> Result JD.Error Settings
json2settings json =
    JD.decodeValue
        (JD.map7 Settings
            (JD.field "toc" JD.bool)
            (JD.field "mode" JD.string)
            (JD.field "theme" JD.string)
            (JD.field "light" JD.string)
            (JD.field "ace" JD.string)
            (JD.field "font_size" JD.int)
            (JD.field "sound" JD.bool)
        )
        json


settings2model : Model -> Result JD.Error Settings -> Model
settings2model model settings =
    case settings of
        Ok s ->
            { model
                | show = Toogler s.toc False False False False
                , design =
                    { theme = s.theme
                    , light = s.light
                    , font_size = s.font_size
                    , ace = s.ace
                    }
                , mode =
                    case s.mode of
                        "Textbook" ->
                            Textbook

                        "Presentation" ->
                            Presentation

                        _ ->
                            Slides
                , sound = s.sound
                , ready = True
            }

        Err msg ->
            model


init : Mode -> String -> String -> String -> Maybe Int -> Model
init mode url readme origin slide_number =
    { url = url
    , readme = readme
    , origin = origin
    , title = "Lia"
    , mode = mode
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
    , design =
        { theme = "default"
        , light = "light"
        , font_size = 100
        , ace = "dreamweaver"
        }
    , index_model = Index.init
    , sound = True
    , show = Toogler True False False False False
    , javascript = []
    , to_do = []
    , translation = Translations.En
    , ready = False
    }


load_src : String -> List String -> List String -> ( List String, List ( String, Int, JE.Value ) )
load_src tag old new =
    let
        member x =
            not (List.member x old)

        to_load =
            List.filter member new
    in
    ( List.append old to_load
    , List.map (\url -> ( "ressource", 0, JE.list JE.string [ tag, url ] )) to_load
    )
