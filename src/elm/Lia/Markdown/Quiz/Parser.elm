module Lia.Markdown.Quiz.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , choice
        , ignore
        , keep
        , many
        , many1
        , map
        , maybe
        , modifyState
        , onsuccess
        , regex
        , sepBy
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Inline.Parser exposing (javascript, line)
import Lia.Markdown.Inline.Types exposing (Inlines, MultInlines)
import Lia.Markdown.Macro.Parser exposing (macro)
import Lia.Markdown.Quiz.Types exposing (Element, Quiz(..), QuizAdds(..), Solution(..), State(..))
import Lia.Parser.Helper exposing (newline, spaces, stringTill)
import Lia.Parser.State exposing (State)


parse : Parser State Quiz
parse =
    quiz |> andThen modify_State


quiz : Parser State Quiz
quiz =
    [ single_choice, multi_choice, empty, selection ]
        |> choice
        |> andMap quizAdds


quizAdds : Parser State QuizAdds
quizAdds =
    map QuizAdds get_counter
        |> andMap hints
        |> andMap
            (macro
                |> keep
                    (maybe
                        (spaces
                            |> keep javascript
                            |> ignore newline
                        )
                    )
            )


get_counter : Parser State Int
get_counter =
    withState (\s -> succeed (Array.length s.quiz_vector))


pattern : Parser s a -> Parser s a
pattern p =
    regex "[\t ]*\\["
        |> keep p
        |> ignore (regex "\\][\t ]*")


quest : Parser State a -> Parser State Inlines
quest p =
    pattern p
        |> keep line
        |> ignore newline


empty : Parser State (QuizAdds -> Quiz)
empty =
    spaces
        |> ignore (string "[[!]]")
        |> ignore newline
        |> onsuccess Empty


text : Parser State (QuizAdds -> Quiz)
text =
    string "["
        |> keep (regex "[^\n\\]_]+")
        |> ignore (regex "\\][\t ]*")
        |> pattern
        |> ignore newline
        |> map Text


splitter str =
    case String.split "|" str of
        [ one ] ->
            Text one

        list ->
            Selection 1 list


selection : Parser State (QuizAdds -> Quiz)
selection =
    string "["
        |> keep (stringTill (string "]"))
        |> ignore (regex "\\][\t ]*")
        |> pattern
        |> ignore newline
        |> map Text


multi_choice : Parser State (QuizAdds -> Quiz)
multi_choice =
    let
        checked b p =
            quest p
                |> map (\l -> ( b, l ))

        gen m =
            let
                ( list, questions ) =
                    List.unzip m
            in
            MultipleChoice list questions
    in
    [ checked True (string "[X]")
    , checked False (string "[ ]")
    ]
        |> choice
        |> many1
        |> map gen


single_choice : Parser State (QuizAdds -> Quiz)
single_choice =
    let
        wrong =
            many (quest (string "( )"))

        correct =
            quest (string "(X)")

        par wrong1 c wrong2 =
            SingleChoice
                (List.length wrong1)
                (c :: wrong2 |> List.append wrong1)
    in
    map par wrong
        |> andMap correct
        |> andMap wrong


hints : Parser State MultInlines
hints =
    many (quest (string "[?]"))


modify_State : Quiz -> Parser State Quiz
modify_State quiz_ =
    let
        add_state e s =
            { s
                | quiz_vector =
                    Array.push
                        (Element Open e 0 0 "")
                        s.quiz_vector
            }

        state_ =
            case quiz_ of
                Empty _ ->
                    EmptyState

                Text _ _ ->
                    TextState ""

                Selection x _ _ ->
                    SelectionState x

                SingleChoice _ _ _ ->
                    SingleChoiceState -1

                MultipleChoice x _ _ ->
                    MultipleChoiceState (List.map (\_ -> False) x)
    in
    modifyState (add_state state_)
        |> keep (succeed quiz_)
