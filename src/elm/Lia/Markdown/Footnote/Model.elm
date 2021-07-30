module Lia.Markdown.Footnote.Model exposing
    ( Model
    , empty
    , getNote
    , init
    , insert
    , toList
    )

import Dict exposing (Dict)
import Lia.Markdown.Types as Markdown


type alias Model =
    Dict String Markdown.Blocks


init : Model
init =
    Dict.empty


insert : String -> Markdown.Blocks -> Model -> Model
insert key val model =
    Dict.insert key val model


toList : Model -> List ( String, Markdown.Blocks )
toList =
    Dict.toList


empty : Model -> Bool
empty =
    Dict.isEmpty


getNote : Model -> String -> Maybe Markdown.Blocks
getNote model key =
    Dict.get key model
