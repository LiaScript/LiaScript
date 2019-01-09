module Lia.Index.Model exposing (Model, init)


type alias Model =
    { search : String
    , index : List Int
    }


init : Model
init =
    Model "" []
