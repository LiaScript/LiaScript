module Lia.Markdown.Quiz.Block.View exposing (view)

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Conditional.List as CList
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import I18n.Translations as Translations
import Json.Decode as JD
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (dropHere, viewer)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Block.Update exposing (Msg(..))
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Utils exposing (blockKeydown, deactivate, icon, shuffle)
import List.Extra


view :
    Config sub
    -> Maybe (List Int)
    -> Solution.State
    -> Quiz Inlines
    -> State
    -> List (Html (Msg sub))
view config randomize solution quiz state =
    case state of
        Text str ->
            [ text solution str
            , case solution of
                ( Solution.Solved, _ ) ->
                    icon "icon-check text-success"
                        [ Attr.style "position" "absolute"
                        , Attr.style "top" "1rem"
                        , Attr.style "right" "1rem"
                        ]

                ( Solution.Open, trials ) ->
                    if trials > 0 then
                        icon "icon-close text-error"
                            [ Attr.style "position" "absolute"
                            , Attr.style "top" "1rem"
                            , Attr.style "right" "1rem"
                            ]

                    else
                        Html.text ""

                _ ->
                    Html.text ""
            ]

        Select open value ->
            [ value
                |> List.head
                |> Maybe.withDefault -1
                |> select config randomize solution open quiz.options
            ]

        Drop highlight active value ->
            let
                solved =
                    case solution of
                        ( Solution.Open, _ ) ->
                            False

                        _ ->
                            True

                id =
                    value
                        |> List.head
                        |> Maybe.withDefault -1
            in
            [ Html.div
                [ Attr.style "width" "100%"
                , Attr.style "padding" "0.5rem"
                , Attr.style "margin" "0.25rem"
                , Attr.style "position" "relative"
                , Html.Events.onClick
                    (if solved || List.isEmpty value then
                        None

                     else
                        DropTarget
                    )
                , A11y_Role.button
                , A11y_Key.onKeyDown
                    (if solved || List.isEmpty value then
                        []

                     else
                        [ A11y_Key.enter DropTarget
                        , A11y_Key.space DropTarget
                        ]
                    )
                , Attr.tabindex <|
                    if List.isEmpty value then
                        0

                    else
                        -1
                , Attr.style "border"
                    (if highlight then
                        "5px dotted #888"

                     else
                        "3px dotted #888"
                    )
                , Attr.style "border-radius" "5px"
                ]
                [ quiz.options
                    |> List.Extra.getAt id
                    |> Maybe.map
                        (viewer config
                            >> List.map (Html.map Script)
                            >> Html.div
                                [ Attr.style "border" "3px dotted #888"
                                , Attr.style "padding" "1rem"
                                , Attr.style "cursor" "pointer"
                                , Attr.style "background-color" "#88888822"
                                , Attr.style "border-radius" "4px"
                                , Attr.style "display" "flex"
                                , Attr.style "justify-content" "center"
                                , Attr.style "display" "flex"
                                , Attr.draggable <|
                                    if solved then
                                        "false"

                                    else
                                        "true"
                                , Html.Events.on "dragend"
                                    (JD.succeed
                                        (if solved then
                                            None

                                         else
                                            DropData id
                                        )
                                    )
                                , Html.Events.on "dragstart"
                                    (JD.succeed
                                        (if solved then
                                            None

                                         else
                                            DropStart
                                        )
                                    )
                                , A11y_Role.button
                                , Attr.tabindex 0
                                ]
                        )
                    |> Maybe.withDefault
                        (dropHere
                            [ Attr.style "height" "4rem"
                            , Attr.style "display" "flex"
                            , Attr.style "font-size" "4rem" -- fallback
                            , Attr.style "font-size" "min(10vw, 4rem)" -- scales with viewport
                            , Attr.style "line-height" "1"
                            ]
                        )
                , Html.div
                    [ Html.Events.on "dragenter"
                        (JD.succeed
                            (if solved then
                                None

                             else
                                DropEnter True
                            )
                        )
                    , Html.Events.on "dragleave"
                        (JD.succeed
                            (if solved then
                                None

                             else
                                DropEnter False
                            )
                        )
                    , Attr.style "height" "100%"
                    , Attr.style "width" "100%"
                    , Attr.style "position" "absolute"
                    , Attr.style "top" "0"
                    , Attr.style "left" "0"
                    , Attr.style "z-index" "10"

                    --, Attr.style "background-color" "rgba(100, 0, 0, 0.1)"
                    , Attr.style "display"
                        (if active then
                            "block"

                         else
                            "none"
                        )
                    ]
                    []
                ]
            , quiz.options
                |> List.indexedMap
                    (\i a ->
                        if i == id then
                            Nothing

                        else
                            viewer config a
                                |> List.map (Html.map Script)
                                |> Html.span
                                    [ Attr.style "border" "3px dotted #888"
                                    , Attr.style "margin" "0.25rem"
                                    , Attr.style "padding" "1rem"
                                    , Attr.style "cursor" "pointer"
                                    , Attr.style "background-color" "#88888822"
                                    , Attr.style "border-radius" "4px"
                                    , Attr.draggable <|
                                        if solved then
                                            "false"

                                        else
                                            "true"
                                    , Html.Events.on "dragend"
                                        (JD.succeed
                                            (if solved then
                                                None

                                             else
                                                DropData i
                                            )
                                        )
                                    , Html.Events.on "dragstart"
                                        (JD.succeed <|
                                            if solved then
                                                None

                                            else
                                                DropStart
                                        )
                                    , Html.Events.onClick
                                        (if solved then
                                            None

                                         else
                                            DropSource i
                                        )
                                    , A11y_Key.onKeyDown
                                        (if solved then
                                            []

                                         else
                                            [ A11y_Key.enter (DropSource i)
                                            , A11y_Key.space (DropSource i)
                                            ]
                                        )
                                    , Attr.style "display" "inline-flex"
                                    , A11y_Role.button
                                    , Attr.tabindex 0
                                    ]
                                |> Just
                    )
                |> List.filterMap identity
                |> shuffle randomize
                |> Html.div
                    [ Attr.style "display" "flex"
                    , Attr.style "flex-wrap" "wrap"
                    , Attr.style "gap" "0.5rem"
                    , Attr.style "align-items" "flex-start"
                    , Attr.style "margin" "1rem 0px"
                    ]
            ]


text : Solution.State -> String -> Html (Msg sub)
text solution state =
    Html.input
        [ Attr.type_ "input"
        , Attr.class "lia-input lia-quiz__input"
        , Attr.class <|
            if Solution.isOpen solution then
                ""

            else
                "lia-input--disabled"
        , Attr.class (Solution.toClass solution Nothing)
        , Attr.value state
        , Attr.disabled (not <| Solution.isOpen solution)
        , onInput Input
        , blockKeydown (Input state)
        , A11y_Aria.label "quiz answer"
        ]
        []


select : Config sub -> Maybe (List Int) -> Solution.State -> Bool -> List Inlines -> Int -> Html (Msg sub)
select config randomize solution open options i =
    let
        active =
            Solution.isOpen solution
    in
    Html.div
        [ Attr.class "lia-dropdown"
        , Attr.class <| Solution.toClass solution Nothing
        , if active then
            onClick Toggle

          else
            Attr.disabled True
        ]
        [ Html.span
            [ Attr.class "lia-dropdown__selected"
            , A11y_Aria.hidden False
            , A11y_Role.button
            , A11y_Aria.expanded open
            , A11y_Aria.hasListBoxPopUp
            , A11y_Key.onKeyDown <|
                if active then
                    [ A11y_Key.enter Toggle, A11y_Key.space Toggle ]

                else
                    []
            , Attr.tabindex <|
                if active then
                    0

                else
                    -1
            ]
            [ get_option config i options
            , Html.i
                [ Attr.class <|
                    "icon"
                        ++ (if open then
                                " icon-chevron-up"

                            else
                                " icon-chevron-down"
                           )
                ]
                []
            ]
        , options
            |> List.indexedMap (option config (open && active))
            |> shuffle randomize
            |> Html.div
                (deactivate (not (open || active))
                    [ Attr.class "lia-dropdown__options"
                    , A11y_Aria.hidden (not (open && active))
                    , A11y_Role.listBox
                    , Attr.class <|
                        if open then
                            "is-visible"

                        else
                            "is-hidden"
                    ]
                )
        ]


option : Config sub -> Bool -> Int -> Inlines -> Html (Msg sub)
option config active id =
    viewer config
        >> Html.div []
        >> Html.map Script
        >> List.singleton
        >> Html.div
            [ Attr.class "lia-dropdown__option"
            , id
                |> Choose
                |> onClick
            , [ A11y_Key.enter (Choose id)
              , A11y_Key.space (Choose id)
              ]
                |> CList.addIf active (A11y_Key.escape Toggle)
                |> A11y_Key.onKeyDown
            , A11y_Role.listItem
            , Attr.tabindex <|
                if active then
                    0

                else
                    -1
            ]


get_option : Config sub -> Int -> List Inlines -> Html (Msg sub)
get_option config id list =
    case ( id, list ) of
        ( 0, x :: _ ) ->
            x
                |> viewer config
                |> Html.span []
                |> Html.map Script

        ( i, _ :: xs ) ->
            get_option config (i - 1) xs

        ( _, [] ) ->
            Html.span [] [ Html.text <| Translations.quizSelection config.lang ]
