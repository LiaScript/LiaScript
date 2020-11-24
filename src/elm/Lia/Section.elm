module Lia.Section exposing
    ( Base
    , Section
    , Sections
    , SubSection(..)
    , init
    )

import Array exposing (Array)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Types as Code
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Footnote.Model as Footnote
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Survey.Types as Survey
import Lia.Markdown.Table.Types as Table
import Lia.Markdown.Types exposing (Markdown)


type alias Section =
    { code : String
    , title : Inlines
    , visited : Bool
    , indentation : Int
    , visible : Bool
    , idx : Int
    , body : List Markdown
    , parsed : Bool
    , error : Maybe String
    , code_vector : Code.Vector
    , quiz_vector : Quiz.Vector
    , survey_vector : Survey.Vector
    , table_vector : Table.Vector
    , effect_model : Effect.Model SubSection
    , definition : Maybe Definition
    , footnotes : Footnote.Model
    , footnote2show : Maybe String
    }


type SubSection
    = SubSection
        { visible : Bool
        , body : List Markdown
        , error : Maybe String
        , code_vector : Code.Vector
        , quiz_vector : Quiz.Vector
        , survey_vector : Survey.Vector
        , table_vector : Table.Vector
        , effect_model : Effect.Model SubSection
        , footnotes : Footnote.Model
        , footnote2show : Maybe String
        }
    | SubSubSection
        { visible : Bool
        , body : Inlines
        , error : Maybe String
        , effect_model : Effect.Model SubSection
        }


type alias Sections =
    Array Section


type alias Base =
    { identation : Int
    , title : Inlines
    , code : String
    }


init : Int -> Base -> Section
init idx base =
    { code = base.code
    , title = base.title
    , visited = True
    , indentation = base.identation
    , visible = True
    , idx = idx
    , parsed = False
    , body = []
    , error = Nothing
    , code_vector = Array.empty
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    , table_vector = Array.empty
    , effect_model = Effect.init
    , definition = Nothing
    , footnotes = Footnote.init
    , footnote2show = Nothing
    }
