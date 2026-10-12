module Lia.Json.Encode exposing
    ( encode
    , encodeFull
    )

import Array
import I18n.Translations exposing (getCodeFromLn)
import Json.Encode as JE
import Lia.Definition.Json.Encode as Definition
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Markdown.Json.Encode as Body
import Lia.Model exposing (Model, getTitle)
import Lia.Section exposing (Section)


{-| Encode a pre-parsed course, sections only with their title and code, as
it is stored in the database and read by `Lia.Json.Decode.decode`.
-}
encode : Model -> JE.Value
encode =
    encodeWith (always [])


{-| Like `encode`, but every section also contains its parsed `body`. This is
used for exporting courses (Worker).
-}
encodeFull : Model -> JE.Value
encodeFull =
    encodeWith (\sec -> [ ( "body", Body.encode sec.body ) ])


encodeWith : (Section -> List ( String, JE.Value )) -> Model -> JE.Value
encodeWith extra model =
    JE.object
        [ ( "title"
          , model.sections
                |> Array.get 0
                |> Maybe.map .title
                |> Maybe.withDefault [ Chars model.title [] ]
                |> Inline.encode
          )
        , ( "str_title", JE.string (getTitle model.sections) )
        , ( "definition", Definition.encode model.definition )
        , ( "comment", JE.string (stringify model.definition.comment) )
        , ( "readme", JE.string model.readme )
        , ( "url", JE.string model.url )
        , ( "origin", JE.string model.origin )
        , ( "sections"
          , JE.array
                (\sec ->
                    [ ( "title", Inline.encode sec.title )
                    , ( "code", JE.string sec.code )
                    , ( "indentation", JE.int sec.indentation )
                    ]
                        ++ extra sec
                        |> JE.object
                )
                model.sections
          )
        , ( "section_active", JE.int model.section_active )
        , ( "version"
          , model.definition.version
                |> String.split "."
                |> List.head
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 0
                |> JE.int
          )
        , ( "translation", JE.string (getCodeFromLn model.translation) )
        ]
