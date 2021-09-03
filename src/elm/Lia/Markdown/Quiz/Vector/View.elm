module Lia.Markdown.Quiz.Vector.View exposing (view)

import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Quiz.Vector.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Vector.Update exposing (Msg(..))


view : Config sub -> Bool -> String -> Quiz -> State -> ( List (Attribute msg), List (Html (Msg sub)) )
view config open class quiz state =
    case ( quiz.solution, state ) of
        ( SingleChoice _, SingleChoice list ) ->
            ( [ A11y_Role.radioGroup ], table (radio config open class) quiz.options list )

        ( MultipleChoice _, MultipleChoice list ) ->
            ( [ A11y_Role.list ], table (check config open class) quiz.options list )

        _ ->
            ( [], [] )


table : (Bool -> ( Int, Inlines ) -> Html (Msg sub)) -> List Inlines -> List Bool -> List (Html (Msg sub))
table fn inlines bools =
    inlines
        |> List.indexedMap Tuple.pair
        |> List.map2 fn bools


check : Config sub -> Bool -> String -> Bool -> ( Int, Inlines ) -> Html (Msg sub)
check config open colorClass checked ( id, line ) =
    Html.label [ Attr.class "lia-label", A11y_Role.listItem ]
        [ Html.input
            [ Attr.class "lia-checkbox"
            , Attr.class colorClass
            , Attr.type_ "checkbox"
            , Attr.checked checked
            , A11y_Role.checkBox
            , if open then
                onClick (Toggle id)

              else
                Attr.disabled True
            ]
            []
        , line
            |> viewer config
            |> Html.span []
            |> Html.map Script
        ]


radio : Config sub -> Bool -> String -> Bool -> ( Int, Inlines ) -> Html (Msg sub)
radio config open colorClass checked ( id, line ) =
    Html.label [ Attr.class "lia-label", A11y_Role.listItem ]
        [ Html.input
            [ Attr.class "lia-radio"
            , Attr.class colorClass
            , Attr.type_ "radio"
            , Attr.checked checked
            , A11y_Role.radio
            , if open then
                onClick (Toggle id)

              else
                Attr.disabled True
            ]
            []
        , line
            |> viewer config
            |> Html.span []
            |> Html.map Script
        ]
