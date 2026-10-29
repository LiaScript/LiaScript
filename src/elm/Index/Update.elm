module Index.Update exposing
    ( Msg(..)
    , decodeGet
    , handle
    , inCache
    , layoutMenuID
    , renameID
    , renameInputID
    , update
    )

import Browser.Navigation as Nav
import Dict
import Index.Model exposing (Action(..), Column, Course, Drag(..), Layout(..), Modal, Model, Release, cardID, normalize, urlInputID)
import Index.Version as Version
import Index.View.Popup as Popup
import Json.Decode as JD
import Json.Encode as JE
import Lia.Definition.Json.Decode as Definition
import Lia.Markdown.Inline.Json.Decode as Inline
import Lia.Parser.PatReplace exposing (link)
import Lia.Settings.Types exposing (Settings)
import Lia.Settings.Update as Settings
import Lia.Utils exposing (scheduleFocus)
import Library.Masonry as Masonry
import List.Extra
import Service.Console
import Service.Database
import Service.Event exposing (Event)
import Service.Resource
import Service.Share
import Set


type Msg
    = IndexList (List Course)
    | IndexError String
    | Input String
    | Delete Bool String
    | Reset Bool String (Maybe String)
    | Restore String (Maybe String)
    | Share { title : String, text : String, url : String, image : Maybe String }
    | Handle Event
    | Activate String (Maybe String)
    | LoadCourse String
    | SaveOffline String
    | UpdateSettings Settings.Msg
    | Modal (Maybe Modal)
    | MasonryMsg Masonry.Msg
    | PopupClose
    | PopupAbort String
    | SetLayout Layout
    | LayoutMenu Bool
    | LayoutMenuEscape
    | ColumnInput String
    | ColumnAdd
    | ColumnDelete Int
    | ColumnMove Int Int
    | RenameStart Int
    | RenameInput String
    | RenameStop Bool
    | DragStart Drag
    | DragEnd
    | DragOver Int (Maybe String)
    | ToggleDetails String
    | DropOn Int (Maybe String)
    | MoveTo String Int
    | None


decodeGet : JD.Value -> Result JD.Error ( String, Maybe Course )
decodeGet event =
    case
        ( JD.decodeValue (JD.field "id" JD.string) event
        , JD.decodeValue decCourse event
        )
    of
        ( Ok uri, Ok course ) ->
            Ok ( uri, Just course )

        ( Ok uri, Err _ ) ->
            Ok ( uri, Nothing )

        ( Err info, _ ) ->
            Err info


handle : Event -> Msg
handle =
    Handle


update : Msg -> Settings -> Model -> ( Settings, ( Model, Cmd Msg, List Event ) )
update msg settings model =
    updateSettings msg settings <|
        case msg of
            IndexList list ->
                let
                    ( masonry, cmd ) =
                        Masonry.init (Just "card") list
                in
                ( { model
                    | courses = list
                    , initialized = True
                    , masonry = masonry
                  }
                , Cmd.map MasonryMsg cmd
                , []
                )

            IndexError _ ->
                ( model, Cmd.none, [] )

            Delete False courseID ->
                ( openPopup Popup_Delete courseID model
                , Lia.Utils.focus None Popup.cancelID
                , []
                )

            Delete True courseID ->
                let
                    courses =
                        model.courses
                            |> List.filter (.id >> (/=) courseID)

                    ( masonry, cmd ) =
                        Masonry.init (Just "card") courses

                    -- the focus moves to the next card, the previous one or
                    -- the url input, if there is no card left
                    target =
                        case List.Extra.splitWhen (.id >> (==) courseID) model.courses of
                            Just ( before, _ :: after ) ->
                                (case after of
                                    next :: _ ->
                                        Just next

                                    [] ->
                                        List.Extra.last before
                                )
                                    |> Maybe.map (.id >> cardID)
                                    |> Maybe.withDefault urlInputID

                            _ ->
                                urlInputID
                in
                ( { model
                    | courses = courses
                    , masonry = masonry
                  }
                , Cmd.batch [ Cmd.map MasonryMsg cmd, Lia.Utils.focus None target ]
                , [ Service.Database.index_delete courseID ]
                )

            PopupClose ->
                ( closePopups model
                , Cmd.none
                , []
                )

            PopupAbort trigger ->
                ( closePopups model
                , Lia.Utils.focus None trigger
                , []
                )

            Reset False courseID _ ->
                ( openPopup Popup_Reset courseID model
                , Lia.Utils.focus None Popup.cancelID
                , []
                )

            Reset True courseID version ->
                ( closePopups model
                , Lia.Utils.focus None (Popup.triggerID "reset" courseID)
                , [ Service.Database.index_reset
                        { url = courseID
                        , version =
                            case version of
                                Just ver ->
                                    ver

                                Nothing ->
                                    model.courses
                                        |> List.Extra.find (.id >> (==) courseID)
                                        |> Maybe.map
                                            (\c ->
                                                c.versions
                                                    |> Dict.keys
                                                    |> List.filterMap String.toInt
                                                    |> List.maximum
                                                    |> Maybe.withDefault -1
                                                    |> String.fromInt
                                            )
                                        |> Maybe.withDefault "-1"
                        }
                  ]
                )

            Handle event ->
                case Service.Event.message event of
                    ( "index_list", param ) ->
                        model
                            |> update (decode param) settings
                            |> Tuple.second

                    ( "index_board_get", param ) ->
                        ( case JD.decodeValue decBoard param of
                            Ok ( layout, (_ :: _) as columns ) ->
                                { model | layout = layout, columns = columns }

                            _ ->
                                model
                        , Cmd.none
                        , []
                        )

                    ( "loading_error", param ) ->
                        ( { model
                            | error =
                                Just <|
                                    case JD.decodeValue JD.string param of
                                        Ok error ->
                                            error

                                        Err info ->
                                            JD.errorToString info
                          }
                        , Cmd.none
                        , []
                        )

                    ( unknown, _ ) ->
                        ( model
                        , Cmd.none
                        , [ Service.Console.warn <| "Index: unknown cmd => " ++ unknown ]
                        )

            Input url ->
                ( { model | input = url }, Cmd.none, [] )

            Restore course version ->
                ( model
                , Cmd.none
                , [ Service.Database.index_restore
                        { version = Maybe.withDefault "0.0.0" version
                        , url = course
                        }
                  ]
                )

            Activate course version ->
                ( { model
                    | courses =
                        model.courses
                            |> List.map (activate course version)
                    , masonry =
                        model.masonry
                            |> Masonry.map (activate course version)
                  }
                , Cmd.none
                , []
                )

            Share site ->
                ( model
                , Cmd.none
                , [ Service.Share.link site ]
                )

            LoadCourse url ->
                ( model, Nav.load url, [] )

            -- opens the course like `Base.href`, it gets stored after loading
            SaveOffline courseID ->
                ( model
                , Cmd.none
                , [ Service.Resource.offlineOpen { url = courseID, href = "./?" ++ link courseID } ]
                )

            Modal modal ->
                ( { model
                    | modal = modal
                    , error =
                        case modal of
                            Just _ ->
                                model.error

                            _ ->
                                Nothing
                  }
                , scheduleFocus Nothing None "lia-modal-focus"
                , []
                )

            MasonryMsg masonryMsg ->
                ( { model | masonry = Masonry.update masonryMsg model.masonry }
                , Cmd.none
                , []
                )

            SetLayout layout ->
                let
                    ( new, _, events ) =
                        storeBoard { model | layout = layout, layoutMenu = False }
                in
                ( new, Lia.Utils.focus None layoutMenuID, events )

            -- also sent if the focus leaves the menu, thus no focus change
            LayoutMenu open ->
                ( { model | layoutMenu = open }, Cmd.none, [] )

            LayoutMenuEscape ->
                ( { model | layoutMenu = False }
                , Lia.Utils.focus None layoutMenuID
                , []
                )

            ColumnInput name ->
                ( { model | newColumn = name }, Cmd.none, [] )

            ColumnAdd ->
                case String.trim model.newColumn of
                    "" ->
                        ( model, Cmd.none, [] )

                    name ->
                        storeBoard
                            { model
                                | columns = normalize model ++ [ Column name [] ]
                                , newColumn = ""
                            }

            ColumnDelete i ->
                -- the courses of the deleted column end up in the first one
                storeBoard { model | columns = List.Extra.removeAt i (normalize model) }

            ColumnMove i j ->
                storeBoard { model | columns = List.Extra.swapAt i j (normalize model) }

            RenameStart i ->
                ( { model
                    | rename =
                        model.columns
                            |> List.Extra.getAt i
                            |> Maybe.map (\column -> ( i, column.name ))
                  }
                , Lia.Utils.focus None renameInputID
                , []
                )

            RenameInput name ->
                ( { model | rename = Maybe.map (Tuple.mapSecond (always name)) model.rename }
                , Cmd.none
                , []
                )

            RenameStop ok ->
                case model.rename of
                    Just ( i, name ) ->
                        let
                            ( new, cmd, events ) =
                                if ok && String.trim name /= "" then
                                    storeBoard
                                        { model
                                            | rename = Nothing
                                            , columns =
                                                List.Extra.updateAt i
                                                    (\column -> { column | name = String.trim name })
                                                    model.columns
                                        }

                                else
                                    ( { model | rename = Nothing }, Cmd.none, [] )
                        in
                        ( new, Cmd.batch [ cmd, Lia.Utils.focus None (renameID i) ], events )

                    Nothing ->
                        ( model, Cmd.none, [] )

            DragStart drag ->
                ( { model | drag = Just drag }, Cmd.none, [] )

            -- dropped outside of the board
            DragEnd ->
                ( { model | drag = Nothing, over = Nothing }, Cmd.none, [] )

            DragOver i before ->
                ( if model.over == Just ( i, before ) then
                    model

                  else
                    { model | over = Just ( i, before ) }
                , Cmd.none
                , []
                )

            ToggleDetails courseID ->
                ( { model
                    | details =
                        if Set.member courseID model.details then
                            Set.remove courseID model.details

                        else
                            Set.insert courseID model.details
                  }
                , Cmd.none
                , []
                )

            DropOn i before ->
                case model.drag of
                    Just (DragCourse courseID) ->
                        if before == Just courseID then
                            ( { model | drag = Nothing, over = Nothing }, Cmd.none, [] )

                        else
                            storeBoard
                                { model
                                    | drag = Nothing
                                    , over = Nothing
                                    , columns = moveCourse courseID i before (normalize model)
                                }

                    Just (DragColumn from) ->
                        if from == i then
                            ( { model | drag = Nothing, over = Nothing }, Cmd.none, [] )

                        else
                            storeBoard
                                { model
                                    | drag = Nothing
                                    , over = Nothing
                                    , columns = moveAt from i (normalize model)
                                }

                    Nothing ->
                        ( model, Cmd.none, [] )

            MoveTo courseID i ->
                storeBoard { model | columns = moveCourse courseID i Nothing (normalize model) }

            _ ->
                ( model, Cmd.none, [] )


{-| Id of the button of the layout menu in the header.
-}
layoutMenuID : String
layoutMenuID =
    "lia-layout-menu"


{-| Id of the input for renaming a kanban column.
-}
renameInputID : String
renameInputID =
    "lia-column-rename"


{-| Id of the rename button of a kanban column, it gets the focus back after
renaming.
-}
renameID : Int -> String
renameID =
    String.fromInt >> (++) "lia-column-rename-"


{-| Remove the course from all columns and insert it into column `i`, either
at the place of the course `before` or at the end. Within the same column a
course that moves down goes behind the target, otherwise the last place could
never be reached by dropping onto a course.
-}
moveCourse : String -> Int -> Maybe String -> List Column -> List Column
moveCourse courseID i before columns =
    case List.Extra.getAt i columns of
        Just column ->
            let
                ids =
                    List.filter ((/=) courseID) column.ids

                -- the original index of the target is the insert position
                -- within the list without the course, like in `moveAt`
                target =
                    before
                        |> Maybe.andThen (\b -> List.Extra.elemIndex b column.ids)
                        |> Maybe.withDefault (List.length ids)
            in
            columns
                |> List.map (\col -> { col | ids = List.filter ((/=) courseID) col.ids })
                |> List.Extra.setAt i { column | ids = List.take target ids ++ courseID :: List.drop target ids }

        Nothing ->
            columns


{-| Move the element at `from` to the place of the element at `to`.
-}
moveAt : Int -> Int -> List a -> List a
moveAt from to list =
    case List.Extra.getAt from list of
        Just x ->
            let
                rest =
                    List.Extra.removeAt from list
            in
            List.take to rest ++ x :: List.drop to rest

        Nothing ->
            list


storeBoard : Model -> ( Model, Cmd Msg, List Event )
storeBoard model =
    ( model
    , Cmd.none
    , [ JE.object
            [ ( "layout"
              , JE.string <|
                    if model.layout == Kanban then
                        "kanban"

                    else
                        "grid"
              )
            , ( "columns"
              , JE.list
                    (\column ->
                        JE.object
                            [ ( "name", JE.string column.name )
                            , ( "id", JE.list JE.string column.ids )
                            ]
                    )
                    model.columns
              )
            ]
            |> Service.Database.index_board_store
      ]
    )


decBoard : JD.Decoder ( Layout, List Column )
decBoard =
    JD.map2 Tuple.pair
        (JD.field "layout" JD.string
            |> JD.map
                (\layout ->
                    if layout == "kanban" then
                        Kanban

                    else
                        Grid
                )
        )
        (JD.field "columns"
            (JD.list
                (JD.map2 Column
                    (JD.field "name" JD.string)
                    (JD.field "id" (JD.list JD.string))
                )
            )
        )


closePopups : Model -> Model
closePopups model =
    let
        close course =
            { course | popup = Nothing }
    in
    { model
        | courses = List.map close model.courses
        , masonry = Masonry.map close model.masonry
    }


{-| The popups are stored in the courses and in the masonry, the kanban board
renders the courses.
-}
openPopup : Action -> String -> Model -> Model
openPopup action courseID model =
    { model
        | courses = List.map (mapPopup action courseID) model.courses
        , masonry = Masonry.map (mapPopup action courseID) model.masonry
    }


mapPopup : Action -> String -> Course -> Course
mapPopup action courseID course =
    { course
        | popup =
            if course.id == courseID then
                Just action

            else
                Nothing
    }


updateSettings : Msg -> Settings -> ( Model, Cmd Msg, List Event ) -> ( Settings, ( Model, Cmd Msg, List Event ) )
updateSettings msg settings ( model, cmd, events ) =
    case msg of
        UpdateSettings subMsg ->
            let
                return =
                    Settings.update Nothing subMsg settings
            in
            ( return.value
            , ( model
              , Cmd.batch [ cmd, Cmd.map UpdateSettings return.command ]
              , List.append events return.events
              )
            )

        _ ->
            ( settings, ( model, cmd, events ) )


activate : String -> Maybe String -> Course -> Course
activate course version c =
    if c.id == course then
        { c
            | active =
                case version of
                    Just ver ->
                        c.versions
                            |> Dict.filter (\_ v -> v.definition.version == ver)
                            |> Dict.keys
                            |> List.head

                    _ ->
                        Nothing
        }

    else
        c


decode : JD.Value -> Msg
decode json =
    case JD.decodeValue decList json of
        Ok rslt ->
            rslt

        Err _ ->
            IndexError "decode"


decList : JD.Decoder Msg
decList =
    JD.list decCourse
        |> JD.map IndexList


decCourse : JD.Decoder Course
decCourse =
    JD.map5 Course
        (JD.field "id" JD.string)
        (JD.field "data" (JD.dict decRelease))
        (JD.succeed Nothing)
        (JD.field "updated_str" JD.string)
        (JD.succeed Nothing)


decRelease : JD.Decoder Release
decRelease =
    JD.map2 Release
        (JD.field "title" Inline.decode)
        (Definition.decode "")


{-| Check if the current passed version string is also available as accessible
from the local cache. Major versions of `0` are not stored permanently.
-}
inCache : String -> Course -> Bool
inCache version course =
    (Version.getMajor version /= 0)
        && (course.versions
                |> Dict.values
                |> List.map (.definition >> .version)
                |> Version.max
                |> Maybe.map Version.toInt
                |> Maybe.withDefault -1
                |> (==) (Version.toInt version)
           )
