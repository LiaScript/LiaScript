module Lia.Markdown.Quiz.Block.View exposing (view)

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Conditional.List as CList
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import I18n.Translations as Translations
import Lia.Markdown.Inline.Stringify as Stringify
import Json.Decode as JD
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (dropHere, dropZoneLabel, viewer)
import Lia.Markdown.Quiz.Block.Types exposing (Quiz, State(..))
import Lia.Markdown.Quiz.Block.Update exposing (Msg(..))
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Utils exposing (combobox, deactivate, dropdownList, icon, onEnter, shuffle)
import List.Extra


{-| Render a text input, a dropdown or a drop zone with its options. Options
can be dragged into the drop zone or clicked (or entered) one after the other.
-}
view :
    String
    -> Config sub
    -> Maybe (List Int)
    -> Solution.State
    -> Quiz Inlines
    -> State
    -> List (Html (Msg sub))
view base config randomize solution quiz state =
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
                |> select base config randomize solution open quiz.options
            ]

        Drop highlight active value ->
            let
                solved =
                    not (Solution.isOpen solution)

                id =
                    value
                        |> List.head
                        |> Maybe.withDefault -1

                unlessSolved msg =
                    if solved then
                        None

                    else
                        msg

                -- a filled drop zone can be cleared by click or key
                removable =
                    not solved && not (List.isEmpty value)

                draggable i =
                    [ Attr.draggable <|
                        if solved then
                            "false"

                        else
                            "true"
                    , Html.Events.on "dragend" (JD.succeed (unlessSolved (DropData i)))
                    , Html.Events.on "dragstart" (JD.succeed (unlessSolved DropStart))
                    ]
            in
            [ Html.div
                [ Attr.style "width" "100%"
                , Attr.style "padding" "0.5rem"
                , Attr.style "margin" "0.25rem"
                , Attr.style "position" "relative"
                , Html.Events.onClick
                    (if removable then
                        DropTarget

                     else
                        None
                    )
                , A11y_Role.button
                , dropZoneLabel config.lang "" (Maybe.map Stringify.stringify (List.Extra.getAt id quiz.options))
                , A11y_Key.onKeyDown
                    (if removable then
                        [ A11y_Key.enter DropTarget
                        , A11y_Key.space DropTarget
                        ]

                     else
                        []
                    )

                -- only a filled drop zone does something, Enter clears it
                , Attr.tabindex <|
                    if removable then
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
                                ([ Attr.style "border" "3px dotted #888"
                                 , Attr.style "padding" "1rem"
                                 , Attr.style "cursor" "pointer"
                                 , Attr.style "background-color" "#88888822"
                                 , Attr.style "border-radius" "4px"
                                 , Attr.style "display" "flex"
                                 , Attr.style "justify-content" "center"
                                 ]
                                    ++ draggable id
                                )
                        )
                    |> Maybe.withDefault
                        (dropHere
                            [ A11y_Aria.hidden True
                            , Attr.style "height" "4rem"
                            , Attr.style "display" "flex"
                            , Attr.style "font-size" "4rem" -- fallback
                            , Attr.style "font-size" "min(10vw, 4rem)" -- scales with viewport
                            , Attr.style "line-height" "1"
                            ]
                        )
                , Html.div
                    -- shown while dragging, it covers the content, so that its children do not fire dragenter and dragleave
                    [ Html.Events.on "dragenter" (JD.succeed (unlessSolved (DropEnter True)))
                    , Html.Events.on "dragleave" (JD.succeed (unlessSolved (DropEnter False)))
                    , Attr.style "height" "100%"
                    , Attr.style "width" "100%"
                    , Attr.style "position" "absolute"
                    , Attr.style "top" "0"
                    , Attr.style "left" "0"
                    , Attr.style "z-index" "10"
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
                    (\i option_ ->
                        if i == id then
                            Nothing

                        else
                            viewer config option_
                                |> List.map (Html.map Script)
                                |> Html.span
                                    ([ Attr.style "border" "3px dotted #888"
                                     , Attr.style "margin" "0.25rem"
                                     , Attr.style "padding" "1rem"
                                     , Attr.style "cursor" "pointer"
                                     , Attr.style "background-color" "#88888822"
                                     , Attr.style "border-radius" "4px"
                                     ]
                                        ++ draggable i
                                        ++ [ Html.Events.onClick (unlessSolved (DropSource i))
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
                                    )
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
        , onEnter Submit
        , A11y_Aria.label "quiz answer"
        ]
        []


{-| **private:** A dropdown, `i` is the selected option. It is a select-only
combobox, the keyboard is handled by `typescript/liascript/combobox.ts`, which
clicks the existing elements.
-}
select : String -> Config sub -> Maybe (List Int) -> Solution.State -> Bool -> List Inlines -> Int -> Html (Msg sub)
select base config randomize solution open options i =
    let
        active =
            Solution.isOpen solution

        listID =
            base ++ "-select"
    in
    Html.div
        [ Attr.class "lia-dropdown"
        , Attr.class <| Solution.toClass solution Nothing
        , if active then
            onClick Toggle

          else
            Attr.class "is-disabled"
        ]
        [ Html.span
            (combobox listID open (not active) (A11y_Aria.label (Translations.quizSelection config.lang)))
            [ get_option config i options
            , Html.i
                [ Attr.class <|
                    "icon"
                        ++ (if open then
                                " icon-chevron-up"

                            else
                                " icon-chevron-down"
                           )
                , A11y_Aria.hidden True
                ]
                []
            ]
        , options
            |> List.indexedMap (option config listID i)
            |> shuffle randomize
            |> Html.div
                (dropdownList listID
                    (open && active)
                    [ Attr.class "lia-dropdown__options"
                    , Attr.class <|
                        if open then
                            "is-visible"

                        else
                            "is-hidden"
                    ]
                )
        ]


option : Config sub -> String -> Int -> Int -> Inlines -> Html (Msg sub)
option config listID selected id =
    viewer config
        >> Html.div []
        >> Html.map Script
        >> List.singleton
        >> Html.div
            [ Attr.class "lia-dropdown__option"
            , Attr.id (listID ++ "-" ++ String.fromInt id)
            , id
                |> Choose
                |> onClick
            , A11y_Role.option
            , A11y_Aria.selected (id == selected)
            ]


{-| **private:** The selected option, or a request to select one.
-}
get_option : Config sub -> Int -> List Inlines -> Html (Msg sub)
get_option config id list =
    case List.Extra.getAt id list of
        Just x ->
            x
                |> viewer config
                |> Html.span []
                |> Html.map Script

        Nothing ->
            Html.span [] [ Html.text <| Translations.quizSelection config.lang ]
