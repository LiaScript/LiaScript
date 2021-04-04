module Lia.Markdown.Types exposing (Markdown(..), MarkdownS)

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


type Markdown
    = HLine Parameters
    | Quote Parameters ( MarkdownS, Maybe ( Parameters, Inlines ) )
    | Paragraph Parameters Inlines
    | BulletList Parameters (List MarkdownS)
    | OrderedList Parameters (List ( String, MarkdownS ))
    | Table Parameters Table
    | Quiz Parameters Quiz (Maybe ( MarkdownS, Int ))
    | Effect Parameters (Effect Markdown)
    | Comment ( Int, Int )
    | Survey Parameters Survey
    | Chart Parameters Chart
    | Code Code
    | Task Parameters Task
    | ASCII Parameters (SvgBob.Configuration (List Markdown))
    | HTML Parameters (Node Markdown)
    | Header Parameters ( Inlines, Int )
    | Gallery Parameters Gallery


type alias MarkdownS =
    List Markdown
