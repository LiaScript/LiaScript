module Lia.Index.Update exposing (Msg(..), update)

import Array
import Lia.Index.Model exposing (Model)
import Lia.Types exposing (Section, Sections)


type Msg
    = ScanIndex String


update : Msg -> Model -> Sections -> ( Model, Sections )
update msg model sections =
    case msg of
        ScanIndex pattern ->
            ( { model | search = pattern }
            , scan sections pattern
            )


scan : Sections -> String -> Sections
scan sections pattern =
    let
        check =
            if pattern == "" then
                make_visible

            else
                pattern
                    |> String.toLower
                    |> search
    in
    Array.map check sections


search : String -> Section -> Section
search pattern section =
    { section
        | visible = String.contains pattern section.code
    }


make_visible : Section -> Section
make_visible section =
    { section | visible = True }
