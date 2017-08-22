module Lia.Index.Update exposing (Msg(..), update)

import Lia.Index.Model exposing (Model)


type Msg
    = ScanIndex String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ScanIndex pattern ->
            let
                results =
                    if pattern == "" then
                        Nothing
                    else
                        Just (scan model.index pattern)
            in
            ( { model | search = pattern, results = results }, Cmd.none )


scan : List String -> String -> List Int
scan index pattern =
    index
        |> List.indexedMap (,)
        |> List.filter (\( _, str ) -> String.contains (String.toLower pattern) str)
        |> List.map (\( i, _ ) -> i)
