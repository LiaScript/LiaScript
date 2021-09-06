module Index.View.Board exposing
    ( Board
    , Msg
    , addColumn
    , addNote
    , deleteColumn
    , deleteNote
    , init
    , restore
    , store
    , update
    , view
    )

import Accessibility.Key as A11y_Key
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Table.Matrix exposing (column)
import Lia.Utils exposing (btn, btnIcon, focus, icon)
import List.Extra
    exposing
        ( find
        , getAt
        , removeAt
        , swapAt
        , updateAt
        )
import Translations exposing (Lang(..))


type alias Board note =
    { store : Maybe JE.Value
    , moving : Maybe Reference
    , newColumn : Maybe String
    , changeColumn : Maybe Int
    , activeColumn : Maybe Int
    , backup : String
    , columns : List (Column note)
    }


type alias Return note withParent =
    { board : Board note
    , cmd : Maybe (Cmd (Msg withParent))
    , parentMsg : Maybe withParent
    , store : Maybe JE.Value
    }


type alias Column note =
    { name : String
    , notes : List note
    }


type Reference
    = NoteID Int Int
    | ColumnID Int


init : String -> Board { note | id : String }
init default =
    Board
        Nothing
        Nothing
        Nothing
        Nothing
        Nothing
        ""
        [ Column default [] ]


type Msg withParent
    = Move Reference
    | Drop Reference
    | AddColumnInput String
    | AddColumnStart
    | AddColumnStop
    | ChangeColumnInput String
    | ChangeColumnStart Int
    | ChangeColumnStop Bool
    | Parent withParent
    | Ignore
    | ActivateMenu (Maybe Int)
    | DeleteColumn Int


return :
    Board { note | id : String }
    -> Return { note | id : String } withParent
return board =
    Return board Nothing Nothing Nothing


returnCmd :
    Cmd (Msg withParent)
    -> Return { note | id : String } withParent
    -> Return { note | id : String } withParent
returnCmd cmd return_ =
    { return_ | cmd = Just cmd }


returnMsg :
    parent
    -> Return { note | id : String } parent
    -> Return { note | id : String } parent
returnMsg msg return_ =
    { return_ | parentMsg = Just msg }


returnStore :
    Return { note | id : String } withParent
    -> Return { note | id : String } withParent
returnStore return_ =
    { return_ | store = Just (store return_.board) }


update :
    Msg withParent
    -> Board { note | id : String }
    -> Return { note | id : String } withParent
update msg board =
    case msg of
        Parent parentMsg ->
            board
                |> return
                |> returnMsg parentMsg

        AddColumnStart ->
            { board | newColumn = Just "" }
                |> return
                |> returnCmd (focus Ignore inputID)

        AddColumnStop ->
            returnStore <|
                return <|
                    case board.newColumn |> Maybe.map String.trim |> Maybe.withDefault "" of
                        "" ->
                            { board | newColumn = Nothing }

                        new ->
                            addColumn new { board | newColumn = Nothing }

        AddColumnInput name ->
            return { board | newColumn = Just name }

        ChangeColumnStart id ->
            { board
                | changeColumn = Just id
                , activeColumn = Nothing
                , backup = ""
            }
                |> return
                |> returnCmd (focus Ignore inputID)

        ChangeColumnStop ok ->
            if ok then
                { board
                    | changeColumn = Nothing
                    , backup = ""
                }
                    |> return
                    |> returnStore

            else
                { board
                    | changeColumn = Nothing
                    , backup = ""
                }
                    |> return

        ChangeColumnInput name ->
            return <|
                case board.changeColumn of
                    Just id ->
                        { board
                            | columns =
                                updateAt
                                    id
                                    (\col -> { col | name = name })
                                    board.columns
                        }

                    Nothing ->
                        board

        Move ref ->
            { board
                | moving =
                    case board.moving of
                        Nothing ->
                            Just ref

                        _ ->
                            board.moving
            }
                |> return

        Drop ref ->
            returnStore <|
                return <|
                    { board
                        | moving = Nothing
                        , columns =
                            case ( board.moving, ref ) of
                                ( Just (NoteID sourceId id), ColumnID targetId ) ->
                                    case getNote sourceId id board.columns of
                                        Just note ->
                                            board.columns
                                                |> updateAt targetId (\col -> { col | notes = note :: col.notes })
                                                |> updateAt sourceId (\col -> { col | notes = removeAt id col.notes })

                                        _ ->
                                            board.columns

                                ( Just (ColumnID sourceId), ColumnID targetId ) ->
                                    swapAt sourceId targetId board.columns

                                ( Just (ColumnID sourceId), NoteID targetId _ ) ->
                                    swapAt sourceId targetId board.columns

                                ( Just (NoteID a1 a2), NoteID b1 b2 ) ->
                                    swapNotes a1 a2 b1 b2 board.columns

                                _ ->
                                    board.columns
                    }

        ActivateMenu id ->
            return { board | activeColumn = id }

        DeleteColumn id ->
            { board
                | activeColumn = Nothing
                , columns = deleteColumn id board.columns
            }
                |> return
                |> returnStore

        Ignore ->
            return board


swapNotes : Int -> Int -> Int -> Int -> List (Column { note | id : String }) -> List (Column { note | id : String })
swapNotes columnA noteA columnB noteB columns =
    case ( getNote columnA noteA columns, getNote columnB noteB columns ) of
        ( Just a, Just b ) ->
            columns
                |> setNote columnA noteA b
                |> setNote columnB noteB a

        _ ->
            columns


deleteNote :
    String
    -> Board { note | id : String }
    -> Board { note | id : String }
deleteNote id board =
    { board
        | columns =
            board.columns
                |> List.map
                    (\col ->
                        { col | notes = List.filter (.id >> (/=) id) col.notes }
                    )
    }



--updateAt columnID (\col -> { col | notes = removeAt noteID col.notes })


deleteColumn :
    Int
    -> List (Column { note | id : String })
    -> List (Column { note | id : String })
deleteColumn i columns =
    case columns of
        [] ->
            []

        [ col ] ->
            [ col ]

        _ ->
            columns
                |> updateAt
                    (if i == 0 then
                        i + 1

                     else
                        i - 1
                    )
                    (\col ->
                        { col
                            | notes =
                                columns
                                    |> getAt i
                                    |> Maybe.map .notes
                                    |> Maybe.withDefault []
                                    |> List.append col.notes
                        }
                    )
                |> removeAt i


getNote :
    Int
    -> Int
    -> List (Column { note | id : String })
    -> Maybe { note | id : String }
getNote columnID noteID =
    getAt columnID >> Maybe.andThen (.notes >> getAt noteID)


setNote :
    Int
    -> Int
    -> { note | id : String }
    -> List (Column { note | id : String })
    -> List (Column { note | id : String })
setNote columnID noteID note =
    updateAt columnID (\col -> { col | notes = col.notes |> updateAt noteID (always note) })


view :
    ({ note | id : String } -> Html withParent)
    -> List (Attribute (Msg withParent))
    -> Board { note | id : String }
    -> Html (Msg withParent)
view fn attributes board =
    board.columns
        |> List.indexedMap (viewColumn fn attributes board.activeColumn board.changeColumn)
        |> viewAddColumn attributes board.newColumn
        |> Html.div
            [ Attr.style "display" "flex"
            , Attr.style "align-items" "flex-start"
            , Attr.style "overflow" "auto"
            ]


inputID : String
inputID =
    "lia-index-column-input"


viewAddColumn : List (Attribute (Msg withParent)) -> Maybe String -> List (Html (Msg withParent)) -> List (Html (Msg withParent))
viewAddColumn attributes newColumn columns =
    List.append columns
        [ case newColumn of
            Nothing ->
                Html.button
                    (Attr.style "flex" "1"
                        :: Attr.style "width" "100%"
                        :: Event.onClick AddColumnStart
                        :: attributes
                    )
                    [ Html.h3
                        [ Attr.style "width" "inherit"
                        , Attr.style "margin-bottom" "0px"
                        ]
                        [ plus
                        , Html.span
                            []
                            [ Html.text "Add New Column" ]
                        ]
                    ]

            Just name ->
                Html.div
                    (Attr.style "flex" "1" :: attributes)
                    [ Html.h3 []
                        [ plus
                        , Html.input
                            [ Attr.value name
                            , Event.onInput AddColumnInput
                            , Event.onBlur AddColumnStop
                            , Attr.style "float" "right"
                            , Attr.style "display" "block"
                            , Attr.style "width" "calc(100% - 5rem)"
                            , Attr.style "color" "#000"
                            , Attr.style "height" "4.2rem"
                            , Attr.id inputID
                            , Attr.autofocus True
                            ]
                            []
                        ]
                    ]
        ]


plus : Html msg
plus =
    Html.span
        [ Attr.style "padding" "0rem 1rem"
        , Attr.style "background" "#888"
        , Attr.style "border-radius" "2rem"
        , Attr.style "float" "left"
        , Attr.style "height" "3rem"
        , Attr.style "background-color" "rgb(var(--color-highlight))"
        , Attr.style "color" "rgb(var(--lia-white))"
        ]
        [ Html.text "+"
        ]


viewColumn :
    ({ note | id : String } -> Html withParent)
    -> List (Attribute (Msg withParent))
    -> Maybe Int
    -> Maybe Int
    -> Int
    -> Column { note | id : String }
    -> Html (Msg withParent)
viewColumn fn attributes activatedID changingID id column =
    draggable (ColumnID id)
        (Attr.style "flex" "1" :: attributes)
        [ Html.div
            [ Attr.style "width" "inherit"
            , Attr.style "margin-bottom" "0px"
            , Attr.style "display" "flex"
            , Attr.style "justify-content" "space-between"
            ]
            [ Html.span
                [ Attr.style "padding" "0.5rem 1rem"
                , Attr.style "background" "#888"
                , Attr.style "border-radius" "2rem"
                , Attr.style "height" "3rem"
                , Attr.style "background-color" "rgb(var(--color-highlight))"
                , Attr.style "color" "rgb(var(--lia-white))"
                ]
                [ column.notes
                    |> List.length
                    |> String.fromInt
                    |> Html.text
                ]
            , if changingID /= Just id then
                Html.h3
                    [ Event.onDoubleClick (ChangeColumnStart id)
                    , Attr.style "margin-bottom" "0px"
                    ]
                    [ Html.text column.name ]

              else
                Html.input
                    [ Attr.value column.name
                    , Attr.style "display" "block"
                    , Attr.style "width" "calc(100% - 5rem)"
                    , Attr.style "color" "#000"
                    , Attr.style "height" "4.2rem"
                    , Attr.id inputID
                    , Attr.autofocus True
                    , Event.onInput ChangeColumnInput
                    , Event.onBlur <| ChangeColumnStop True
                    , A11y_Key.onKeyDown
                        [ A11y_Key.enter <| ChangeColumnStop True
                        , A11y_Key.escape <| ChangeColumnStop False
                        ]
                    ]
                    []
            , columnMenu id activatedID
            ]
        , column.notes
            |> List.indexedMap (viewNote fn id)
            |> Html.div
                [ Attr.style "overflow-y" "auto"
                , Attr.style "max-height" "calc(100vh - 34rem)"
                ]
        ]


columnMenu : Int -> Maybe Int -> Html (Msg withParent)
columnMenu columnID activeColumnID =
    Html.span [ Attr.class "nav__item lia-support-menu__item" ]
        [ btnIcon
            { title = "settings"
            , msg =
                Just <|
                    ActivateMenu <|
                        if Just columnID == activeColumnID then
                            Nothing

                        else
                            Just columnID
            , tabbable = True
            , icon = "icon-more"
            }
            [ Attr.class "lia-btn--transparent" ]
        , Html.div
            [ Attr.class "lia-support-menu__submenu"
            , Attr.class <|
                if Just columnID == activeColumnID then
                    "active"

                else
                    ""
            ]
            [ btn
                { title = "rename"
                , msg = Just (ChangeColumnStart columnID)
                , tabbable = True
                }
                [ Attr.class "lia-btn--transparent", Attr.style "width" "100%" ]
                [ icon "lia-btn__icon icon-trash" []
                , Html.span
                    [ Attr.class "lia-btn__text" ]
                    [ Html.text "rename" ]
                ]
            , btn
                { title = "delete"
                , msg = Just (DeleteColumn columnID)
                , tabbable = True
                }
                [ Attr.class "lia-btn--transparent", Attr.style "width" "100%" ]
                [ icon "lia-btn__icon icon-trash" []
                , Html.span
                    [ Attr.class "lia-btn__text" ]
                    [ Html.text "delete" ]
                ]
            ]
        ]


viewNote :
    ({ note | id : String } -> Html withParent)
    -> Int
    -> Int
    -> { note | id : String }
    -> Html (Msg withParent)
viewNote fn columnID noteID note =
    draggable (NoteID columnID noteID)
        [ Attr.style "padding-bottom" "1rem" ]
        [ fn note
            |> Html.map Parent
        ]


draggable :
    Reference
    -> List (Attribute (Msg withParent))
    -> (List (Html (Msg withParent)) -> Html (Msg withParent))
draggable ref attributes =
    [ Attr.attribute "draggable" "true"
    , Attr.attribute "ondragover" "return false"
    , onDrop <| Drop ref
    , onDragStart <| Move ref
    , Attr.attribute "ondragstart" "event.dataTransfer.setData('text/plain', '')"
    ]
        |> List.append attributes
        |> Html.div


addNote :
    Int
    -> { note | id : String }
    -> Board { note | id : String }
    -> Board { note | id : String }
addNote id note board =
    { board | columns = updateAt id (\col -> { col | notes = note :: col.notes }) board.columns }


addColumn :
    String
    -> Board { note | id : String }
    -> Board { note | id : String }
addColumn name board =
    { board | columns = List.append board.columns [ Column name [] ] }


onDragStart : msg -> Attribute msg
onDragStart message =
    Event.on "dragstart" (JD.succeed message)


onDrop : msg -> Attribute msg
onDrop message =
    Event.custom "drop"
        (JD.succeed
            { message = message
            , preventDefault = True
            , stopPropagation = True
            }
        )


store : Board { note | id : String } -> JE.Value
store =
    .columns
        >> List.map
            (\column ->
                [ ( "name", JE.string column.name )
                , ( "id"
                  , column.notes
                        |> List.map .id
                        |> JE.list JE.string
                  )
                ]
            )
        >> JE.list JE.object


restore : List { note | id : String } -> JE.Value -> Maybe (Board { note | id : String })
restore data json =
    case JD.decodeValue (JD.list decoder) json of
        Ok list ->
            let
                columns =
                    List.map (merge data) list

                runaways =
                    catchRunaways columns data
            in
            columns
                |> updateAt 0 (\col -> { col | notes = List.append col.notes runaways })
                |> Board Nothing Nothing Nothing Nothing Nothing ""
                |> Just

        Err _ ->
            Nothing


catchRunaways :
    List (Column { note | id : String })
    -> List { note | id : String }
    -> List { note | id : String }
catchRunaways columns =
    let
        ids =
            columns
                |> List.map (.notes >> List.map .id)
                |> List.concat
    in
    List.filter (\elem -> not <| List.member elem.id ids)


merge : List { note | id : String } -> Column String -> Column { note | id : String }
merge data column =
    { name = column.name
    , notes = List.filterMap (match data) column.notes
    }


match : List { note | id : String } -> String -> Maybe { note | id : String }
match data id =
    find (\elem -> elem.id == id) data


decoder : JD.Decoder (Column String)
decoder =
    JD.map2 Column
        (JD.field "name" JD.string)
        (JD.field "id" (JD.list JD.string))
