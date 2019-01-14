module Lia.Index.Model exposing (Model, init)

import Array exposing (Array)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Types exposing (Section, Sections)


type alias Model =
    { search : String
    }


init : Model
init =
    Model ""



{-
   filter : Model -> Sections -> Model
   filter model sections =
       case ( model.search, model.index ) of
           -- no search at all
           "" ->
               sections

           -- search but nor results
           ( _, [] ) ->
               []

           -- search with results
           ( _, index ) ->
               let
                   fn ( idx, _ ) =
                       List.member idx index
               in
               List.filter fn indexed_sections
-}
