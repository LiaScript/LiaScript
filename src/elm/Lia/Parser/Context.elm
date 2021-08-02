module Lia.Parser.Context exposing
    ( Context
    , init
    , searchIndex
    )

{-| This module defines everything that is necessary to deal with the state of
the parser. This state is called `Context` and might have an influence on the
parsing. It is passed to all successively applied parser.
-}

import Array
import Combine exposing (Parser, succeed, withState)
import Lia.Definition.Types exposing (Definition)
import Lia.Graph.Model as Graph
import Lia.Markdown.Code.Types as Code
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Footnote.Model as Footnote
import Lia.Markdown.Gallery.Types as Gallery
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Survey.Types as Survey
import Lia.Markdown.Table.Types as Table
import Lia.Markdown.Task.Types as Task
import Lia.Section exposing (SubSection)


{-| The `Context` defines the current state of the parser. It keeps track of the
current indentation as well as on all identified elements that might require state
control:

  - `indentation`: a list of `["  ", "> "]`, elements are pushed on and popped
    off this stack, to check the currently defined indentation.
  - `indentation_skip`: defines if the indentation should be skipped within the
    next step
  - `****_vector`: any kind of state to preserve for the applied sub-modules.
    Normally new states are pushed on this stack/array and their position (id) is
    later used to identify the required element from within the views.
  - `effect_model` & `effect_number` are specific, the `effect_number` is a
    stack of Int that is required to keep the current animation-id, if for
    example `<script>` are used within a effect or to deal with nested effects.
  - `defines`: is a set of macros and other definitions, that are normally
    defined within the head of every LiaScript document
  - `footnotes`
  - `defines_updated`:
  - `search_index`: a function, that translates a string title into a section
    number

> Context is commonly used per section, since sections are pre-parsed at first
> and afterwards only the current section is parsed, in order to speed up
> execution.

-}
type alias Context =
    { indentation : List String
    , indentation_skip : Bool
    , task_vector : Task.Vector
    , code_model : Code.Model
    , quiz_vector : Quiz.Vector
    , survey_vector : Survey.Vector
    , table_vector : Table.Vector
    , gallery_vector : Gallery.Vector
    , effect_model : Effect.Model SubSection
    , effect_number : List Int
    , effect_id : Int
    , defines : Definition
    , footnotes : Footnote.Model
    , defines_updated : Bool
    , search_index : String -> String
    , graph : Graph.Model
    }


{-| Initialize the current `Context` with a searchIndex function and the global
definitions.
-}
init : Graph.Model -> Maybe (String -> String) -> Definition -> Context
init graph search_index global =
    { indentation = []
    , indentation_skip = False
    , task_vector = Array.empty
    , code_model = Code.init
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    , table_vector = Array.empty
    , gallery_vector = Array.empty
    , effect_model = Effect.init
    , effect_number = [ 0 ]
    , effect_id = 0
    , defines = global
    , footnotes = Footnote.init
    , defines_updated = False
    , search_index = Maybe.withDefault identity search_index
    , graph = graph
    }


{-| Put the search\_index from the context into the parser-pipeline.
-}
searchIndex : Parser Context (String -> String)
searchIndex =
    withState (.search_index >> succeed)
