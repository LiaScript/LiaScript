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
import List.Extra
    exposing
        ( getAt
        , removeAt
        , swapAt
        , updateAt
        )


type alias Board note =
    { columns : List (Column note)
    , moving : Maybe Reference
    , newColumn : Maybe String
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
    Board [] Nothing Nothing


type Msg withParent
    = Move Reference
    | Drop Reference
    | InputColumn String
    | InputColumnStart
    | InputColumnStop
    | Parent withParent


update : Msg withParent -> Board note -> ( Board note, Maybe withParent )
update msg board =
    case msg of
        Parent parentMsg ->
            ( board, Just parentMsg )

        InputColumnStart ->
            ( { board | newColumn = Just "" }
            , Nothing
            )

        InputColumnStop ->
            ( case board.newColumn |> Maybe.map String.trim |> Maybe.withDefault "" of
                "" ->
                    { board | newColumn = Nothing }

                new ->
                    addColumn new { board | newColumn = Nothing }
            , Nothing
            )

        InputColumn name ->
            ( { board | newColumn = Just name }
            , Nothing
            )

        Move ref ->
            ( { board
                | moving =
                    case board.moving of
                        Nothing ->
                            Just ref

                        _ ->
                            board.moving
              }
            , Nothing
            )

        Drop ref ->
            ( { board
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
            , Nothing
            )


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
        |> List.indexedMap (viewColumn fn attributes)
        |> viewAddColumn attributes board.newColumn
        |> Html.div
            [ Attr.style "display" "flex"
            , Attr.style "align-items" "flex-start"
            ]


viewAddColumn : List (Attribute (Msg withParent)) -> Maybe String -> List (Html (Msg withParent)) -> List (Html (Msg withParent))
viewAddColumn attributes newColumn columns =
    List.append columns
        [ case newColumn of
            Nothing ->
                Html.button
                    (Attr.style "flex" "1"
                        :: Event.onClick InputColumnStart
                        :: attributes
                    )
                    [ Html.h2 [] [ Html.text "+ Add column" ]
                    ]

            Just name ->
                Html.div
                    (Attr.style "flex" "1" :: attributes)
                    [ Html.h2 []
                        [ Html.input
                            [ Attr.value name
                            , Event.onInput InputColumn
                            , Event.onBlur InputColumnStop
                            ]
                            []
                        ]
                    ]
        ]


viewColumn : (note -> Html withParent) -> List (Attribute (Msg withParent)) -> Int -> Column note -> Html (Msg withParent)
viewColumn fn attributes id column =
    draggable (ColumnID id)
        (Attr.style "flex" "1" :: attributes)
        [ Html.h2 [] [ Html.text column.name ]
        , column.notes
            |> List.indexedMap (viewNote fn id)
            |> Html.div []
        ]


viewNote : (note -> Html withParent) -> Int -> Int -> note -> Html (Msg withParent)
viewNote fn columnID noteID note =
    draggable (NoteID columnID noteID)
        []
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
