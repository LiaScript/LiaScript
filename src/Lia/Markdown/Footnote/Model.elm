module Lia.Markdown.Footnote.Model exposing (..)

import Dict exposing (Dict)
import Lia.Markdown.Types exposing (MarkdownS)


type alias Model =
    { notes : Dict String MarkdownS
    , to_show : Maybe String
    }


init : Model
init =
    Model Dict.empty Nothing


insert : String -> MarkdownS -> Model -> Model
insert key val model =
    { model | notes = Dict.insert key val model.notes }


toList : Model -> List ( String, MarkdownS )
toList =
    .notes >> Dict.toList


empty : Model -> Bool
empty =
    .notes >> Dict.isEmpty


getNote : String -> Model -> Maybe MarkdownS
getNote key model =
    Dict.get key model.notes
