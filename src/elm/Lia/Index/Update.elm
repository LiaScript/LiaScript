module Lia.Index.Update exposing (Msg(..), update)

import Array
import Lia.Index.Model exposing (Model)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Section exposing (Section, Sections)


type Msg
    = ScanIndex String


update : Msg -> Sections -> ( Model, Sections )
update msg sections =
    case msg of
        ScanIndex pattern ->
            ( pattern
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
        | visible =
            section.title
                |> stringify
                |> (++) section.code
                |> String.toLower
                |> search_
                    (pattern
                        |> String.toLower
                        |> String.split " "
                        |> List.filter ((/=) "")
                    )
    }


search_ : List String -> String -> Bool
search_ pattern text =
    case pattern of
        [] ->
            True

        p :: ps ->
            if not <| String.contains p text then
                False

            else
                search_ ps text


make_visible : Section -> Section
make_visible section =
    { section | visible = True }
