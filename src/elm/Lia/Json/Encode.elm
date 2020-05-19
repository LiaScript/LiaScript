module Lia.Json.Encode exposing (encode)

import Array
import Json.Encode as JE
import Lia.Definition.Json.Encode as Definition
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Model exposing (Model)
import Lia.Section exposing (Section, Sections)
import Translations exposing (Lang(..))


encode : Model -> JE.Value
encode model =
    JE.object
        [ ( "title"
          , model.sections
                |> Array.get 0
                |> Maybe.map .title
                |> Maybe.withDefault [ Chars model.title [] ]
                |> Inline.encode
          )
        , ( "str_title"
          , model.sections
                |> get_title
                |> JE.string
          )
        , ( "definition"
          , model.definition |> Definition.encode
          )
        , ( "comment"
          , model.definition.comment
                |> stringify
                |> JE.string
          )
        , ( "readme"
          , model.readme |> JE.string
          )
        , ( "url"
          , model.url |> JE.string
          )
        , ( "origin"
          , model.origin |> JE.string
          )
        , ( "sections"
          , model.sections |> JE.array encSection
          )
        , ( "section_active"
          , model.section_active |> JE.int
          )
        , ( "version"
          , model.definition.version
                |> String.split "."
                |> List.head
                |> Maybe.withDefault "0"
                |> String.toInt
                |> Maybe.withDefault 0
                |> JE.int
          )
        , ( "error"
          , case model.error of
                Just str ->
                    JE.string str

                _ ->
                    JE.null
          )
        , ( "translation"
          , model.translation
                |> getCodeFromLn
                |> JE.string
          )
        ]


get_title : Sections -> String
get_title sections =
    sections
        |> Array.get 0
        |> Maybe.map .title
        |> Maybe.map stringify
        |> Maybe.withDefault "Lia"
        |> String.trim


encSection : Section -> JE.Value
encSection sec =
    JE.object
        [ ( "title", Inline.encode sec.title )
        , ( "code", JE.string sec.code )
        , ( "indentation", JE.int sec.indentation )
        ]


getCodeFromLn : Lang -> String
getCodeFromLn ln =
    case ln of
        Bg ->
            "bg"

        De ->
            "de"

        Fa ->
            "fa"

        Hy ->
            "hy"

        Ua ->
            "ua"

        _ ->
            "en"
