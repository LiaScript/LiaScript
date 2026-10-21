module Lia.Markdown.Survey.Types exposing
    ( Analysis(..)
    , Element
    , Options
    , State(..)
    , Survey
    , Type(..)
    , Vector
    , analysisType
    , initOptions
    , toString
    )

{-| Surveys are quizzes without a solution, the answers of all users can be
shared and summarized within a classroom.

The `Bool` in `Vector`, `Matrix`, `Vector_State` and `Matrix_State` is `True`
for checkboxes (`[[id]]`, multiple choice) and `False` for radio buttons
(`[(id)]`, single choice).

-}

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.Inline.Types exposing (Inlines)


{-| The states of all surveys within a section, indexed by `Survey.id`.
-}
type alias Vector =
    Array Element


{-| The user's state of a single survey. `errorMsg` is `Just ""` for the
default message (incomplete answer) or the message of a failed script.
-}
type alias Element =
    { submitted : Bool
    , state : State
    , errorMsg : Maybe String
    , scriptID : Maybe Int
    , opt : Options
    }


{-| Settings defined by the attributes of a survey (`data-randomize`,
`data-score`, `data-updates-allowed`, `data-incompleteness-allowed`).
-}
type alias Options =
    { randomize : Maybe (List Int)
    , score : Maybe Float
    , updates_allowed : Bool
    , incompleteness_allowed : Bool
    }


{-| No randomization, no score, no updates and only complete answers.
-}
initOptions : Options
initOptions =
    { randomize = Nothing
    , score = Nothing
    , updates_allowed = False
    , incompleteness_allowed = False
    }


{-| The user's input for every survey `Type`:

  - `Select_State open value`: whether the dropdown is open and the selected
    option (`-1` if none)
  - `DragAndDrop_State highlight active value`: whether the target is
    highlighted, whether something is dragged and the dropped option (`-1` if
    none)
  - `Matrix_State`: one dictionary of variables per row

-}
type State
    = Text_State String
    | Select_State Bool Int
    | DragAndDrop_State Bool Bool Int
    | Vector_State Bool (Dict String Bool)
    | Matrix_State Bool (Array (Dict String Bool))


{-| The answer as it is passed to a script, which can check it:

    toString (Text_State "abc") == "abc"

    toString (Select_State False 2) == "2"

    toString (Vector_State True (Dict.fromList [ ( "a", True ), ( "b", False ) ]))
        == "{\"a\": 1, \"b\": 0}"

    -- a matrix is a list of such dictionaries, separated by ",\n"
    toString (Matrix_State True (Array.fromList [ Dict.fromList [ ( "a", True ) ] ]))
        == "[{\"a\": 1}]"

-}
toString : State -> String
toString state =
    case state of
        Text_State str ->
            str

        Select_State _ i ->
            String.fromInt i

        DragAndDrop_State _ _ i ->
            String.fromInt i

        Vector_State _ dict ->
            dictToString dict

        Matrix_State _ array ->
            "["
                ++ (array
                        |> Array.toList
                        |> List.map dictToString
                        |> String.join ",\n"
                   )
                ++ "]"


dictToString : Dict String Bool -> String
dictToString dict =
    "{"
        ++ (dict
                |> Dict.toList
                |> List.map
                    (\( key, value ) ->
                        "\""
                            ++ key
                            ++ "\": "
                            ++ (if value then
                                    "1"

                                else
                                    "0"
                               )
                    )
                |> String.join ", "
           )
        ++ "}"


{-| A survey of a certain type, the `id` is its position within the `Vector`.
-}
type alias Survey body =
    { survey : Type body
    , id : Int
    }


{-| The parsed survey types:

  - `Text lines`: a text input or, for more than one line, a textarea
  - `Select options`: a dropdown
  - `DragAndDrop options`: a target to drop one of the options
  - `Vector checkbox options analysis`: one checkbox or radio button per
    option, each identified by its id and with a Markdown body
  - `Matrix checkbox header ids rows`: one row of checkboxes or radio buttons
    per row-statement, with one column per id

-}
type Type body
    = Text Int
    | Select (List Inlines)
    | DragAndDrop (List Inlines)
    | Vector Bool (List ( String, List body )) Analysis
    | Matrix Bool (List Inlines) (List String) (List Inlines)


{-| How the answers of a `Vector` survey are summarized: as bars per option or,
if all ids start with a number, as a distribution.
-}
type Analysis
    = Categorical
    | Quantitative


{-| `Quantitative`, if every id starts with an integer followed by a space or
the end of the id:

    analysisType [ "1 bad", "2", "3 good" ] == Quantitative

    analysisType [ "1 bad", "good" ] == Categorical

-}
analysisType : List String -> Analysis
analysisType ids =
    if List.all isNumber ids then
        Quantitative

    else
        Categorical


isNumber : String -> Bool
isNumber =
    String.split " "
        >> List.head
        >> Maybe.andThen String.toInt
        >> (/=) Nothing
