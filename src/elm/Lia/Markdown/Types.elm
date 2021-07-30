module Lia.Markdown.Types exposing
    ( Block(..)
    , Blocks
    )

import Lia.Markdown.Chart.Types exposing (Chart)
import Lia.Markdown.Code.Types exposing (Code)
import Lia.Markdown.Effect.Types exposing (Effect)
import Lia.Markdown.Gallery.Types exposing (Gallery)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.HTML.Types exposing (Node)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Types exposing (Quiz)
import Lia.Markdown.Survey.Types exposing (Survey)
import Lia.Markdown.Table.Types exposing (Table)
import Lia.Markdown.Task.Types exposing (Task)
import SvgBob


type Block
    = HLine Parameters
    | Quote Parameters Blocks
    | Paragraph Parameters Inlines
    | BulletList Parameters (List Blocks)
    | OrderedList Parameters (List ( String, Blocks ))
    | Table Parameters Table
    | Quiz Parameters Quiz (Maybe ( Blocks, Int ))
    | Effect Parameters (Effect Block)
    | Comment ( Int, Int )
    | Survey Parameters Survey
    | Chart Parameters Chart
    | Code Code
    | Task Parameters Task
    | ASCII Parameters ( Maybe Inlines, SvgBob.Configuration Blocks )
    | HTML Parameters (Node Block)
    | Header Parameters ( Int, Inlines )
    | Gallery Parameters Gallery
    | Citation Parameters Inlines
    | Problem Inlines


type alias Blocks =
    List Block
