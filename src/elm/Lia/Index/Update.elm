module Lia.Index.Update exposing (Msg(..), update)

import Lia.Index.Model exposing (Model)


type Msg
    = ScanIndex String


update : Msg -> Model -> List ( Int, String ) -> Model
update msg model sections =
    case msg of
        ScanIndex pattern ->
            { model
                | search = pattern
                , index =
                    if pattern == "" then
                        []

                    else
                        scan sections pattern
            }


scan : List ( Int, String ) -> String -> List Int
scan index pattern =
    let
        check =
            pattern
                |> String.toLower
                |> checker
    in
    List.filterMap check index


checker : String -> ( Int, String ) -> Maybe Int
checker pattern ( idx, string ) =
    if String.contains pattern string then
        Just idx

    else
        Nothing
