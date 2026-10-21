module Index.Model exposing
    ( Action(..)
    , Column
    , Course
    , Drag(..)
    , Layout(..)
    , Modal(..)
    , Model
    , Release
    , boardColumns
    , cardID
    , init
    , normalize
    , reset_modal
    , urlInputID
    )

import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Library.Masonry as Masonry exposing (Masonry)
import List.Extra


type Modal
    = Files
    | Directory


type alias Model =
    { input : String
    , courses : List Course
    , initialized : Bool
    , modal : Maybe Modal
    , error : Maybe String
    , masonry : Masonry Course
    , layout : Layout
    , columns : List Column
    , drag : Maybe Drag
    , newColumn : String
    , rename : Maybe ( Int, String )
    , layoutMenu : Bool
    }


{-| What is currently dragged on the kanban board, a course or a column.
-}
type Drag
    = DragCourse String
    | DragColumn Int


type Layout
    = Grid
    | Kanban


{-| A user defined kanban column, it only stores the ids of its courses.
-}
type alias Column =
    { name : String
    , ids : List String
    }


init : Model
init =
    { input = ""
    , courses = []
    , initialized = False
    , modal = Nothing
    , error = Nothing
    , masonry = Masonry.empty
    , layout = Grid
    , columns = [ Column "Courses" [] ]
    , drag = Nothing
    , newColumn = ""
    , rename = Nothing
    , layoutMenu = False
    }


{-| The columns with their courses. Ids of deleted courses are dropped and
courses that are not part of any column get appended to the first one, thus
new courses or those of a deleted column end up there.
-}
boardColumns : Model -> List ( Column, List Course )
boardColumns model =
    let
        assigned =
            List.concatMap .ids model.columns

        find id =
            List.Extra.find (.id >> (==) id) model.courses

        orphans =
            List.filter (\course -> not (List.member course.id assigned)) model.courses
    in
    List.indexedMap
        (\i column ->
            ( column
            , List.filterMap find column.ids
                ++ (if i == 0 then
                        orphans

                    else
                        []
                   )
            )
        )
        model.columns


{-| The columns with the ids as they are displayed.
-}
normalize : Model -> List Column
normalize =
    boardColumns >> List.map (\( column, courses ) -> { column | ids = List.map .id courses })


reset_modal : Model -> Model
reset_modal model =
    { model | modal = Nothing, error = Nothing }


type Action
    = Popup_Delete
    | Popup_Reset


type alias Course =
    { id : String
    , versions : Dict String Release
    , active : Maybe String
    , last_visit : String
    , popup : Maybe Action
    }


type alias Release =
    { title : Inlines
    , definition : Definition
    }


{-| Id of the card of a course, it gets the focus when the card before it got
deleted.
-}
cardID : String -> String
cardID =
    (++) "lia-card-"


{-| Id of the input for a course url, it gets the focus when the last card got
deleted.
-}
urlInputID : String
urlInputID =
    "lia-course-url"
