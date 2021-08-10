module Index.View.Board exposing
    ( Board
    , Msg
    , addColumn
    , addNote
    , deleteColumn
    , deleteNote
    , init
    , update
    , view
    )

import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as JD
import Json.Encode as JE
import Lia.Utils exposing (focus)
import List.Extra
    exposing
        ( find
        , getAt
        , removeAt
        , swapAt
        , updateAt
        )


type alias Board note =
    { store : Maybe String
    , moving : Maybe Reference
    , newColumn : Maybe String
    , changeColumn : Maybe Int
    , columns : List (Column note)
    }


type alias Update note withParent =
    { board : Board note
    , cmd : Maybe (Cmd (Msg withParent))
    , parentMsg : Maybe withParent
    }


type alias Column note =
    { name : String
    , notes : List note
    }


type Reference
    = NoteID Int Int
    | ColumnID Int


init : Board note
init =
    Board Nothing Nothing Nothing Nothing []


type Msg withParent
    = Move Reference
    | Drop Reference
    | InputColumn String
    | InputColumnStart
    | InputColumnStop
    | ChangeColumn (Maybe Int) (Maybe String)
    | Parent withParent
    | Ignore


updateBoard : Board note -> Update note withParent
updateBoard board =
    Update board Nothing Nothing


updateCmd cmd board =
    { board | cmd = Just cmd }


updateParent parentMsg board =
    { board | parentMsg = Just parentMsg }


update : Msg withParent -> Board note -> Update note withParent
update msg board =
    case msg of
        Parent parentMsg ->
            board
                |> updateBoard
                |> updateParent parentMsg

        InputColumnStart ->
            { board | newColumn = Just "" }
                |> updateBoard
                |> updateCmd (focus Ignore inputID)

        InputColumnStop ->
            updateBoard <|
                case board.newColumn |> Maybe.map String.trim |> Maybe.withDefault "" of
                    "" ->
                        { board | newColumn = Nothing }

                    new ->
                        addColumn new { board | newColumn = Nothing }

        InputColumn name ->
            { board | newColumn = Just name }
                |> updateBoard

        ChangeColumn id Nothing ->
            { board | changeColumn = id }
                |> updateBoard
                |> updateCmd (focus Ignore inputID)

        ChangeColumn (Just id) (Just name) ->
            { board
                | changeColumn = Just id
                , columns = updateAt id (\col -> { col | name = name }) board.columns
            }
                |> updateBoard

        Move ref ->
            { board
                | moving =
                    case board.moving of
                        Nothing ->
                            Just ref

                        _ ->
                            board.moving
            }
                |> updateBoard

        Drop ref ->
            updateBoard <|
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

        _ ->
            updateBoard board


swapNotes : Int -> Int -> Int -> Int -> List (Column note) -> List (Column note)
swapNotes columnA noteA columnB noteB columns =
    case ( getNote columnA noteA columns, getNote columnB noteB columns ) of
        ( Just a, Just b ) ->
            columns
                |> setNote columnA noteA b
                |> setNote columnB noteB a

        _ ->
            columns


deleteNote : Int -> Int -> List (Column note) -> List (Column note)
deleteNote columnID noteID =
    updateAt columnID (\col -> { col | notes = removeAt noteID col.notes })


deleteColumn : Int -> List (Column note) -> List (Column note)
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


getNote : Int -> Int -> List (Column note) -> Maybe note
getNote columnID noteID =
    getAt columnID >> Maybe.andThen (.notes >> getAt noteID)


setNote : Int -> Int -> note -> List (Column note) -> List (Column note)
setNote columnID noteID note =
    updateAt columnID (\col -> { col | notes = col.notes |> updateAt noteID (always note) })


view : (note -> Html withParent) -> List (Attribute (Msg withParent)) -> Board note -> Html (Msg withParent)
view fn attributes board =
    board.columns
        |> List.indexedMap (viewColumn fn attributes board.changeColumn)
        |> viewAddColumn attributes board.newColumn
        |> Html.div
            [ Attr.style "display" "flex"
            , Attr.style "align-items" "flex-start"
            , Attr.style "overflow-x" "auto"
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
                        :: Event.onClick InputColumnStart
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
                            , Event.onInput InputColumn
                            , Event.onBlur InputColumnStop
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


plus =
    Html.span
        [ Attr.style "padding" "0px 1rem 0px 1rem"
        , Attr.style "background" "#888"
        , Attr.style "border-radius" "1rem"
        , Attr.style "float" "left"
        ]
        [ Html.text "+ "
        ]


viewColumn : (note -> Html withParent) -> List (Attribute (Msg withParent)) -> Maybe Int -> Int -> Column note -> Html (Msg withParent)
viewColumn fn attributes changingID id column =
    draggable (ColumnID id)
        (Attr.style "flex" "1" :: attributes)
        [ Html.h3
            [ Attr.style "width" "inherit"
            , Attr.style "margin-bottom" "0px"
            ]
            [ Html.span
                [ Attr.style "padding" "0px 1rem 0px 1rem"
                , Attr.style "background" "#888"
                , Attr.style "border-radius" "2rem"
                , Attr.style "float" "left"
                ]
                [ column.notes
                    |> List.length
                    |> String.fromInt
                    |> Html.text
                ]
            , if changingID /= Just id then
                Html.span
                    [ Attr.style "text-align" "center"
                    , Attr.style "display" "block"
                    , Event.onDoubleClick (ChangeColumn (Just id) Nothing)
                    ]
                    [ Html.text column.name ]

              else
                Html.input
                    [ Attr.value column.name
                    , Attr.style "float" "right"
                    , Attr.style "display" "block"
                    , Attr.style "width" "calc(100% - 5rem)"
                    , Attr.style "color" "#000"
                    , Attr.style "height" "4.2rem"
                    , Attr.id inputID
                    , Attr.autofocus True
                    , Event.onInput (Just >> ChangeColumn (Just id))
                    , Event.onBlur (ChangeColumn Nothing Nothing)
                    ]
                    []
            ]
        , column.notes
            |> List.indexedMap (viewNote fn id)
            |> Html.div [ Attr.style "overflow-y" "auto", Attr.style "float" "left" ]
        ]


viewNote : (note -> Html withParent) -> Int -> Int -> note -> Html (Msg withParent)
viewNote fn columnID noteID note =
    draggable (NoteID columnID noteID)
        [ Attr.style "padding-top" "1rem" ]
        [ fn note
            |> Html.map Parent
        ]


draggable : Reference -> List (Attribute (Msg withParent)) -> (List (Html (Msg withParent)) -> Html (Msg withParent))
draggable ref attributes =
    [ Attr.attribute "draggable" "true"
    , Attr.attribute "ondragover" "return false"
    , onDrop <| Drop ref
    , onDragStart <| Move ref
    , Attr.attribute "ondragstart" "event.dataTransfer.setData('text/plain', '')"
    ]
        |> List.append attributes
        |> Html.div


addNote : Int -> note -> Board note -> Board note
addNote id note board =
    { board | columns = updateAt id (\col -> { col | notes = note :: col.notes }) board.columns }


addColumn : String -> Board notes -> Board notes
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


store : List (Column { note | id : String }) -> JE.Value
store =
    List.map
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



--restore : List { note | id : String } -> JE.Value -> Board { note | id : String }


restore data =
    JD.decodeValue (JD.list decoder)
        >> Result.map
            (List.map
                (\col ->
                    { col
                        | notes = List.filterMap (\id -> find ((==) id) data) col.notes
                    }
                )
            )
        >> Result.withDefault []
        >> Board Nothing Nothing Nothing Nothing


decoder : JD.Decoder (Column String)
decoder =
    JD.map2 Column
        (JD.field "name" JD.string)
        (JD.field "id" (JD.list JD.string))
