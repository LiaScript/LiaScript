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
                [ slide "Ups, something went wrong" 1 Report.unknown ]

            Error [ "" ] ->
                [ slide "Ups, something went wrong" 1 Report.unknown ]

            Error [ report ] ->
                [ slide "Ups, something went wrong" 1 report ]

            Error reports ->
                reports
                    |> List.indexedMap (\i report -> slide ("Error " ++ String.fromInt (i + 1)) 2 report)
                    |> (::) (slide "Ups, something went wrong" 1 "There are a couple of errors, listed in the next sections ...")

            _ ->
                [ slide "Ups, something went wrong" 1 Report.unknown ]


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
    , code = body ++ "\n"
    }
