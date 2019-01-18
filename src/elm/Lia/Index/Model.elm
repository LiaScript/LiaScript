module Lia.Index.Model exposing (Model, init)

import Array exposing (Array)
import ElmTextSearch
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Types exposing (Section, Sections)


type alias Model =
    { search : String
    , index : ElmTextSearch.Index Doc
    }


type alias Doc =
    { cid : Int
    , title : String
    , author : String
    , body : String
    }


init : Sections -> Model
init sections =
    Model "" (createIndex sections)


createIndex : Sections -> ElmTextSearch.Index Doc
createIndex sections =
    Array.foldl
        add2Index
        (ElmTextSearch.new
            { ref = .cid >> String.fromInt
            , fields =
                [ ( .title, 5.0 )
                , ( .body, 1.0 )
                ]
            , listFields = []
            }
        )
        sections


add2Index : Section -> ElmTextSearch.Index Doc -> ElmTextSearch.Index Doc
add2Index section index =
    case
        ElmTextSearch.add
            { cid = section.idx
            , title = stringify section.title
            , author = ""
            , body = section.code
            }
            index
    of
        Ok new_index ->
            new_index

        _ ->
            index



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
