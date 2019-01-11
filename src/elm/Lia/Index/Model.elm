module Lia.Index.Model exposing (Model, filter, init)


type alias Model =
    { search : String
    , index : List Int
    }


init : Model
init =
    Model "" []


filter : Model -> List ( Int, a ) -> List ( Int, a )
filter model indexed_sections =
    case ( model.search, model.index ) of
        -- no search at all
        ( "", [] ) ->
            indexed_sections

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
