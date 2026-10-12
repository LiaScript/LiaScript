module Lia.Index.Update exposing
    ( Msg(..)
    , update
    )

{-| Searching the sections of a course, the search pattern is a list of words,
separated by spaces. A section is visible, if its code or title contain all of
them (ignoring the case).
-}

import Array
import Lia.Index.Model exposing (Model)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Section exposing (Sections)
import Lia.Utils exposing (focus)


{-| -}
type Msg
    = ScanIndex String
    | DeleteSearch
    | NoOp


{-| Store the pattern and mark the matching sections as `visible`. Deleting
the search moves the focus back into the search field.
-}
update : Msg -> Model -> Sections -> ( Model, Sections, Cmd Msg )
update msg model sections =
    case msg of
        ScanIndex pattern ->
            ( pattern, scan pattern sections, Cmd.none )

        DeleteSearch ->
            ( "", scan "" sections, focus NoOp "lia-input-search" )

        NoOp ->
            ( model, sections, Cmd.none )


scan : String -> Sections -> Sections
scan pattern =
    case
        pattern
            |> String.toLower
            |> String.split " "
            |> List.filter ((/=) "")
    of
        [] ->
            Array.map (\section -> { section | visible = True })

        words ->
            Array.map
                (\section ->
                    let
                        text =
                            String.toLower (section.code ++ stringify section.title)
                    in
                    { section | visible = List.all (\word -> String.contains word text) words }
                )
