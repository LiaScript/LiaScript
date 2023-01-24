module Lia.Section exposing
    ( Base
    , Section
    , Sections
    , SubSection(..)
    , init
    , sync
    , syncCode
    , syncDecoder
    , syncEncode
    , syncInit
    , syncQuiz
    , syncSurvey
    , syncUpdate
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Sync as Code_
import Lia.Markdown.Code.Types as Code
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Footnote.Model as Footnote
import Lia.Markdown.Gallery.Types as Gallery
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Sync as Quiz_
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Survey.Sync as Survey_
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
    , sync : Sync
    , persistent : Maybe Bool
    , seed : Int
    }


type alias Sync =
    { quiz : Container Quiz_.Sync
    , survey : Container Survey_.Sync
    , code : Array Code_.Sync
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
init : Int -> Int -> Base -> Section
init seed id base =
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
    , sync =
        { quiz = Container.empty
        , survey = Container.empty
        , code = Array.empty
        }
    , persistent = Nothing
    , seed = seed + (10 * id)
    }


syncInit : String -> Section -> Sync
syncInit id section =
    { quiz = Container.init id Quiz_.sync section.quiz_vector
    , survey = Container.init id Survey_.sync section.survey_vector

    -- Code is one global text with updates, not single files to be updated separately
    , code = Array.map Code_.sync section.code_model.evaluate
    }


syncEncode : Sync -> JE.Value
syncEncode s =
    JE.object
        [ ( "q", Container.encode Quiz_.encoder s.quiz )
        , ( "s", Container.encode Survey_.encoder s.survey )
        , ( "c", JE.array Code_.encoder s.code )
        ]


syncDecoder : JD.Decoder Sync
syncDecoder =
    JD.map3 Sync
        (JD.field "q" (Container.decoder Quiz_.decoder))
        (JD.field "s" (Container.decoder Survey_.decoder))
        (JD.field "c" (JD.array Code_.decoder))


sync : String -> Section -> JE.Value
sync id =
    syncInit id >> syncEncode


syncUpdate : Section -> Sync -> Section
syncUpdate section update =
    { section
        | sync =
            if Array.isEmpty section.sync.code then
                update

            else
                { update
                    | code =
                        List.map2 (\new old -> { new | log = old.log })
                            (Array.toList update.code)
                            (Array.toList section.sync.code)
                            |> Array.fromList
                }
    }


syncQuiz : Container Quiz_.Sync -> Section -> Section
syncQuiz state section =
    let
        localSync =
            section.sync
    in
    { section | sync = { localSync | quiz = state } }


syncSurvey : Container Survey_.Sync -> Section -> Section
syncSurvey state section =
    let
        localSync =
            section.sync
    in
    { section | sync = { localSync | survey = state } }


syncCode : Array Code_.Sync -> Section -> Section
syncCode state section =
    let
        localSync =
            section.sync
    in
    { section | sync = { localSync | code = state } }
