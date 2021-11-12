module Lia.Section exposing
    ( Base
    , Section
    , Sections
    , SubSection(..)
    , init
    , synchronize
    )

import Array exposing (Array)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Types as Code
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Footnote.Model as Footnote
import Lia.Markdown.Gallery.Types as Gallery
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Survey.Types as Survey
import Lia.Markdown.Table.Types as Table
import Lia.Markdown.Task.Types as Task
import Lia.Markdown.Types as Markdown
import Lia.Sync.Container as Container exposing (Container)


{-| This is the main record to contain all section related information.

  - `code`: the entire Markdown code for this section
  - `title`: already processed `# Title`
  - `indentation`: number of hashTags `### Title`
  - `visible`: mark section to be visible by the text-search
  - `id`: **back reference** the position of this section in the section array
  - `body`: the parsed LiaScript-Markdown elements
  - `parsed`: has the `code` already been parsed to `body`
  - `error`: if there has a parsing error occurred
  - `definition`:

**subModules:** All self-contained LiaScript elements, that provide some kind
of interactivity. Vectors are arrays, which are used for identification. Every
element has a counterpart in body (Markdown-Types), that is used for displaying,
but it refers to state-changes via an id, which points to an element in these
arrays.

  - `code_vector`
  - `task_vector`
  - `quiz_vector`
  - `survey_vector`
  - `table_vector`
  - `effect_model`: these are a bit more complicated and cover stuff like ...
    1.  animations
    2.  text2speech output
    3.  execution of scripts

**Footnotes:** Since footnotes have their own port for activation, there are
currently two elements required:

  - `footnotes`: footnote model with all content
  - `footnote2show`: id of the footnote, that should be displayed

-}
type alias Section =
    { code : String
    , title : Inlines
    , indentation : Int
    , visible : Bool
    , id : Int
    , body : Markdown.Blocks
    , parsed : Bool
    , error : Maybe String
    , code_model : Code.Model
    , task_vector : Task.Vector
    , quiz_vector : Quiz.Vector
    , survey_vector : Survey.Vector
    , table_vector : Table.Vector
    , gallery_vector : Gallery.Vector
    , effect_model : Effect.Model SubSection
    , definition : Maybe Definition
    , footnotes : Footnote.Model
    , footnote2show : Maybe String
    , sync : Maybe { quiz : Maybe (Container Quiz.Sync) }
    }


{-| A special type of section that is only applied in combination with LiaScript
`<script>...</script>` elements, that are defined in module
`Lia.Markdown.Effect.Script`. The result of such a script can also be some
LiaScript code, such as tables, codes, quizzes, etc. that offer some kind of
interaction. These elements are parsed at runtime and their content is not
stored permanently. To minimize the requirements, there are actually two types:

1.  `SubSection`: is nearly as complex as a section and can contain multiple
    LiaScript elements
2.  `SubSubSection`: is only used for LiaScript text elements that might contain
    at least some effects

-}
type SubSection
    = SubSection
        { id : Int
        , body : Markdown.Blocks
        , error : Maybe String
        , code_model : Code.Model
        , task_vector : Task.Vector
        , quiz_vector : Quiz.Vector
        , survey_vector : Survey.Vector
        , table_vector : Table.Vector
        , gallery_vector : Gallery.Vector
        , effect_model : Effect.Model SubSection
        , footnotes : Footnote.Model
        , footnote2show : Maybe String
        }
    | SubSubSection
        { id : Int
        , body : Inlines
        , error : Maybe String
        , effect_model : Effect.Model SubSection
        }


{-| An array of sections
-}
type alias Sections =
    Array Section


{-| Base type for initializing sections. This is the result of the preprocessing
(pre-parsing) that only identifies, titles, their indentation, and the remaining
code. The code gets only parsed, if the user visits this section.
-}
type alias Base =
    { indentation : Int
    , title : Inlines
    , code : String
    }


{-| Initialize a section with a back-reference to its position within an array
as well as the preprocessed section data (indentation, title, body-code).
-}
init : Int -> Base -> Section
init id base =
    { code = base.code
    , title = base.title
    , indentation = base.indentation
    , visible = True
    , id = id
    , parsed = False
    , body = []
    , error = Nothing
    , code_model = Code.init
    , task_vector = Array.empty
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    , table_vector = Array.empty
    , gallery_vector = Array.empty
    , effect_model = Effect.init
    , definition = Nothing
    , footnotes = Footnote.init
    , footnote2show = Nothing
    , sync = Nothing
    }


synchronize : String -> Section -> Section
synchronize id section =
    if Array.isEmpty section.quiz_vector then
        section

    else
        { section
            | sync =
                Just
                    { quiz =
                        section.quiz_vector
                            |> Container.init id Quiz.sync
                            |> Just
                    }
        }
