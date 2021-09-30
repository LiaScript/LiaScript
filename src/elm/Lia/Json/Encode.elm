module Lia.Json.Encode exposing
    ( encode
    , encodeFull
    )

import Array
import Json.Encode as JE
import Lia.Definition.Json.Encode as Definition
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Markdown.Json.Encode as Body
import Lia.Model exposing (Model)
import Lia.Section exposing (Section, Sections)
import Translations exposing (Lang(..), getCodeFromLn)


encode : Model -> JE.Value
encode =
    encodeWith encSection


encodeWith : (Section -> JE.Value) -> Model -> JE.Value
encodeWith sectionEncoder model =
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
          , model.sections |> JE.array sectionEncoder
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


encSectionFull : Section -> JE.Value
encSectionFull sec =
    JE.object
        [ ( "title", Inline.encode sec.title )
        , ( "code", JE.string sec.code )
        , ( "indentation", JE.int sec.indentation )
        , ( "body", Body.encode sec.body )
        ]


encodeFull : Model -> JE.Value
encodeFull =
    encodeWith encSectionFull
