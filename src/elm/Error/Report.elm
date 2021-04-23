module Error.Report exposing
    ( add
    , generate
    )

import Array
import Error.Message as Report
import Lia.Markdown.Inline.Types exposing (Inline(..))
import Lia.Section as Section exposing (Base, Sections)
import Model exposing (State(..))


{-| This either adds an error message to the general error state or changes the current state to an error.
-}
add : State -> String -> State
add state message =
    case state of
        Error messages ->
            [ message ]
                |> List.append messages
                |> Error

        _ ->
            Error [ message ]


{-| Pass in a List of Strings an generate a detailed report, thus a slide for every error message
-}
generate : State -> Sections
generate messages =
    toReport <|
        case messages of
            Error [] ->
                [ slide ups 1 Report.unknown ]

            Error [ report ] ->
                [ slide ups 1 report ]

            Error reports ->
                reports
                    |> List.indexedMap (\i report -> slide ("Error " ++ String.fromInt (i + 1)) 3 report)
                    |> (::) (slide ups 1 Report.multiple)

            _ ->
                [ slide ups 1 Report.unknown ]


ups : String
ups =
    "🙈 Ups, something went wrong"


toReport : List Base -> Sections
toReport errors =
    List.append errors
        [ slide "What is LiaScript?" 2 Report.whatIsLiaScript
        , slide "Get Help?" 2 Report.getHelp
        ]
        |> List.indexedMap Section.init
        |> Array.fromList


slide : String -> Int -> String -> Base
slide title indentation body =
    { indentation = indentation
    , title = [ Chars title [] ]
    , code =
        (if body == "" then
            Report.unknown

         else
            body
        )
            ++ "\n"
    , editor_line = 0
    }
