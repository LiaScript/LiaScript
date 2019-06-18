module Lia.Markdown.Quiz.Parser exposing (parse)

import Array
import Combine
    exposing
        ( Parser
        , andMap
        , andThen
        , brackets
        , choice
        , fail
        , ignore
        , keep
        , many
        , many1
        , map
        , maybe
        , modifyState
        , onsuccess
        , or
        , parens
        , regex
        , sepBy
        , sepBy1
        , string
        , succeed
        , withState
        )
import Lia.Markdown.Inline.Parser exposing (javascript, line, parse_inlines)
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


splitter : String -> State -> Parser s (QuizAdds -> Quiz)
splitter str state =
    case String.split "|" str of
        [ one ] ->
            Text one |> succeed

        list ->
            let
                inlines =
                    parse_inlines state
            in
            list
                |> List.map String.trim
                |> List.indexedMap
                    (\i s ->
                        if String.startsWith "(" s && String.endsWith ")" s then
                            ( i
                            , s
                                |> String.slice 1 -1
                                |> String.trim
                                |> inlines
                            )

                        else
                            ( -1, inlines s )
                    )
                |> select


select : List ( Int, Inlines ) -> Parser s (QuizAdds -> Quiz)
select list =
    case
        list
            |> List.filter (Tuple.first >> (<=) 0)
            |> List.head
            |> Maybe.map Tuple.first
    of
        Just i ->
            list
                |> List.map Tuple.second
                |> Selection i
                |> succeed

        Nothing ->
            fail "no solution provided"


selection : Parser State (QuizAdds -> Quiz)
selection =
    string "[["
        |> keep (stringTill (string "]]"))
        |> ignore newline
        |> map splitter
        |> andThen withState


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
                    State_Empty

                Text _ _ ->
                    State_Text ""

                Selection x _ _ ->
                    State_Selection -1 False

                SingleChoice _ _ _ ->
                    State_SingleChoice -1

                MultipleChoice x _ _ ->
                    State_MultipleChoice (List.map (\_ -> False) x)
    in
    modifyState (add_state state_)
        |> keep (succeed quiz_)
