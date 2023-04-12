module Lia.Markdown.Quiz.Multi.View exposing (view)

--import Lia.Markdown.Quiz.Matrix.Update exposing (Msg(..))

import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
import Array
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Multi.Types exposing (Quiz, State)


view : Config sub -> Bool -> Quiz Inlines -> State -> Html msg
view config open quiz state =
    Html.div [ Attr.class "lia-table-responsive has-thead-sticky has-last-col-sticky" ]
        [ Html.text "Quiz"
        ]
