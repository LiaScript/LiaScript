module Index.View.Board exposing (layoutMenu, view)

{-| The kanban view of the index, user defined columns with the courses sorted
into them. Courses and columns can be dragged with the mouse or by touch,
courses can also be moved via a select, which works with a keyboard and screen
readers.
-}

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Events as Event
import Index.Model exposing (Column, Course, Drag(..), Layout(..), Model, boardColumns)
import Index.Update exposing (Msg(..), layoutMenuID, renameID, renameInputID)
import Index.View.Card exposing (card)
import Json.Decode as JD
import Lia.Utils exposing (btn, btnIcon)
import Library.Group as Group
import List.Extra
import Set


{-| The available layouts, a new one only needs an entry here.
-}
layouts : List { layout : Layout, name : String, icon : String }
layouts =
    [ { layout = Grid, name = "List", icon = "icon-cards" }
    , { layout = Kanban, name = "Kanban", icon = "icon-kanban" }
    ]


{-| Dropdown in the header to switch the layout, like the mode menu of a course.
-}
layoutMenu : Bool -> Layout -> Html Msg
layoutMenu open current =
    let
        grouping =
            [ Group.id "layout", Group.blur (always (LayoutMenu False)) ]

        active =
            layouts
                |> List.filter (.layout >> (==) current)
                |> List.head
                |> Maybe.withDefault { layout = Grid, name = "List", icon = "icon-cards" }
    in
    Html.div
        [ Attr.class "lia-layout-menu"
        , A11y_Key.onKeyDown [ A11y_Key.escape LayoutMenuEscape ]
        ]
        [ btnIcon
            { title = "Layout: " ++ active.name
            , tabbable = True
            , msg = Just (LayoutMenu (not open))
            , icon = active.icon
            }
            (Attr.id layoutMenuID
                :: Attr.class "lia-btn--transparent"
                :: A11y_Aria.expanded open
                :: A11y_Aria.controls [ "lia-layout-menu-list" ]
                :: grouping
            )
        , layouts
            |> List.map
                (\entry ->
                    btn
                        { title = "Show the courses as " ++ String.toLower entry.name
                        , tabbable = open
                        , msg = Just (SetLayout entry.layout)
                        }
                        (Attr.class "lia-btn--transparent"
                            :: A11y_Aria.pressed (Just (entry.layout == current))
                            :: grouping
                        )
                        [ Lia.Utils.icon ("lia-btn__icon " ++ entry.icon) []
                        , Html.span [ Attr.class "lia-btn__text" ] [ Html.text entry.name ]
                        ]
                )
            |> Html.div
                [ Attr.class "lia-layout-menu__list"
                , Attr.id "lia-layout-menu-list"
                , Attr.classList [ ( "active", open ) ]
                ]
        ]


view : Bool -> Model -> Html Msg
view hasShareAPI model =
    let
        columns =
            boardColumns model

        names =
            List.map (Tuple.first >> .name) columns
    in
    columns
        |> List.indexedMap (viewColumn hasShareAPI model names (List.length columns))
        |> (\list -> list ++ [ addColumn model.newColumn ])
        |> Html.div [ Attr.class "lia-board" ]


viewColumn : Bool -> Model -> List String -> Int -> Int -> ( Column, List Course ) -> Html Msg
viewColumn hasShareAPI model names count i ( column, courses ) =
    let
        renaming =
            Maybe.map Tuple.first model.rename == Just i

        index id =
            List.Extra.findIndex (.id >> (==) id) courses

        -- where the dragged element would land, see `Update.moveCourse`,
        -- downwards or to the right behind the target, otherwise before it
        behind from to =
            if from < to then
                "lia-board--after"

            else
                "lia-board--before"

        columnMark =
            case ( model.drag, model.over ) of
                ( Just (DragColumn from), Just ( j, _ ) ) ->
                    if j == i && from /= i then
                        behind from i

                    else
                        ""

                ( Just (DragCourse _), Just ( j, Nothing ) ) ->
                    if j == i then
                        "lia-board--over"

                    else
                        ""

                _ ->
                    ""

        courseMark id =
            case ( model.drag, model.over ) of
                ( Just (DragCourse dragged), Just ( j, Just target ) ) ->
                    if j == i && target == id && dragged /= id then
                        Maybe.map2 behind (index dragged) (index id)
                            |> Maybe.withDefault "lia-board--before"

                    else
                        ""

                _ ->
                    ""
    in
    Html.section
        [ Attr.class "lia-board__column"
        , Attr.class columnMark
        , Attr.classList [ ( "lia-board--dragging", model.drag == Just (DragColumn i) ) ]
        , A11y_Aria.label column.name
        , onDragOver
        , onDragEnter (DragOver i Nothing)
        , onDrop (DropOn i Nothing)
        ]
        [ Html.div
            (Attr.class "lia-board__header"
                :: (if renaming then
                        -- otherwise the text in the input cannot be selected
                        []

                    else
                        draggable (DragColumn i)
                   )
            )
            [ case model.rename of
                Just ( j, name ) ->
                    if i == j then
                        Html.input
                            [ Attr.class "lia-input"
                            , Attr.id renameInputID
                            , Attr.value name
                            , A11y_Aria.label "Column name"
                            , Event.onInput RenameInput
                            , Event.onBlur (RenameStop True)
                            , A11y_Key.onKeyDown
                                [ A11y_Key.enter (RenameStop True)
                                , A11y_Key.escape (RenameStop False)
                                ]
                            ]
                            []

                    else
                        title column.name courses

                Nothing ->
                    title column.name courses
            , btnIcon
                { title = "Rename column " ++ column.name
                , tabbable = True
                , msg = Just (RenameStart i)
                , icon = "icon-pencil"
                }
                [ Attr.class "lia-btn--transparent", Attr.id (renameID i) ]
            , btnIcon
                { title = "Move column " ++ column.name ++ " to the left"
                , tabbable = i > 0
                , msg =
                    if i > 0 then
                        Just (ColumnMove i (i - 1))

                    else
                        Nothing
                , icon = "icon-arrow-left"
                }
                [ Attr.class "lia-btn--transparent" ]
            , btnIcon
                { title = "Move column " ++ column.name ++ " to the right"
                , tabbable = i < count - 1
                , msg =
                    if i < count - 1 then
                        Just (ColumnMove i (i + 1))

                    else
                        Nothing
                , icon = "icon-arrow-right"
                }
                [ Attr.class "lia-btn--transparent" ]
            , if count > 1 then
                btnIcon
                    { title = "Delete column " ++ column.name ++ ", its courses move to the first column"
                    , tabbable = True
                    , msg = Just (ColumnDelete i)
                    , icon = "icon-trash"
                    }
                    [ Attr.class "lia-btn--transparent text-red-dark" ]

              else
                Html.text ""
            ]
        , if List.isEmpty courses then
            Html.div [ Attr.class "lia-board__empty" ] [ Html.text "Drop courses here" ]

          else
            courses
                |> List.map (\course -> viewCourse hasShareAPI model names i (courseMark course.id) course)
                |> Html.div [ Attr.class "lia-board__courses" ]
        ]


title : String -> List Course -> Html Msg
title name courses =
    Html.span [ Attr.class "lia-board__title" ]
        [ Html.text name
        , Html.span [ Attr.class "lia-board__count" ]
            [ Html.text <| " (" ++ String.fromInt (List.length courses) ++ ")" ]
        ]


viewCourse : Bool -> Model -> List String -> Int -> String -> Course -> Html Msg
viewCourse hasShareAPI model names i mark course =
    Html.div
        (Attr.class "lia-board__course"
            :: Attr.class mark
            :: Attr.classList [ ( "lia-board--dragging", model.drag == Just (DragCourse course.id) ) ]
            :: onDragEnter (DragOver i (Just course.id))
            :: onDrop (DropOn i (Just course.id))
            :: draggable (DragCourse course.id)
        )
        [ card
            { share = hasShareAPI
            , compact = Just (Set.member course.id model.details)
            , extra =
                if List.length names > 1 then
                    [ names
                        |> List.indexedMap
                            (\j name ->
                                Html.option
                                    [ Attr.value (String.fromInt j)
                                    , Attr.selected (i == j)
                                    ]
                                    [ Html.text name ]
                            )
                        |> Html.select
                            [ Attr.class "lia-select lia-card__move"
                            , A11y_Aria.label "Move to column"
                            , Event.on "change" (JD.map (String.toInt >> Maybe.withDefault i >> MoveTo course.id) Event.targetValue)
                            ]
                    ]

                else
                    []
            }
            course
        ]


addColumn : String -> Html Msg
addColumn name =
    Html.div [ Attr.class "lia-board__column lia-board__add" ]
        [ Html.input
            [ Attr.class "lia-input"
            , Attr.value name
            , Attr.placeholder "new column"
            , A11y_Aria.label "Name of the new column"
            , Event.onInput ColumnInput
            , A11y_Key.onKeyDown [ A11y_Key.enter ColumnAdd ]
            ]
            []
        , btn
            { title = "Add column"
            , tabbable = String.trim name /= ""
            , msg =
                if String.trim name == "" then
                    Nothing

                else
                    Just ColumnAdd
            }
            []
            [ Html.text "Add column" ]
        ]


{-| Mouse and touch (via the drag-drop-touch polyfill, press and hold).
-}
draggable : Drag -> List (Attribute Msg)
draggable drag =
    [ Attr.draggable "true"

    -- Firefox only starts dragging if some data is set
    , Attr.attribute "ondragstart" "event.dataTransfer.setData('text/plain', '')"
    , Event.on "dragstart" (JD.succeed (DragStart drag))
    , Event.on "dragend" (JD.succeed DragEnd)
    ]


{-| Marks the drop target, the innermost one wins.
-}
onDragEnter : Msg -> Attribute Msg
onDragEnter msg =
    Event.stopPropagationOn "dragenter" (JD.succeed ( msg, True ))


{-| Allows dropping, without sending a message on every mouse move.
-}
onDragOver : Attribute Msg
onDragOver =
    Attr.attribute "ondragover" "event.preventDefault()"


onDrop : Msg -> Attribute Msg
onDrop msg =
    Event.custom "drop"
        (JD.succeed { message = msg, preventDefault = True, stopPropagation = True })
