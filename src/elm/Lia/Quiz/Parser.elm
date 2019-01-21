module Lia.Quiz.Parser exposing (parse)

import Array
import Combine exposing (..)
import Lia.Helper exposing (..)
import Lia.Macro.Parser exposing (macro)
import Lia.Markdown.Inline.Parser exposing (..)
import Lia.Markdown.Inline.Types exposing (..)
import Lia.PState exposing (PState)
import Lia.Quiz.Types exposing (Element, Hints, Quiz(..), Solution(..), State(..), Vector)


parse : Parser PState Quiz
parse =
    quiz |> andThen modify_PState


quiz : Parser PState Quiz
quiz =
    [ single_choice, multi_choice, empty, text ]
        |> choice
        |> andMap get_counter
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


get_counter : Parser PState Int
get_counter =
    withState (\s -> succeed (Array.length s.quiz_vector))


pattern : Parser s a -> Parser s a
pattern p =
    regex "[\t ]*\\["
        |> keep p
        |> ignore (regex "\\][\t ]*")


quest : Parser PState a -> Parser PState Inlines
quest p =
    pattern p
        |> keep line
        |> ignore newline


empty : Parser PState (Int -> Hints -> Maybe String -> Quiz)
empty =
    spaces
        |> ignore (string "[[!]]")
        |> ignore newline
        |> onsuccess Empty


text : Parser PState (Int -> Hints -> Maybe String -> Quiz)
text =
    string "["
        |> keep (regex "[^\n\\]]+")
        |> ignore (regex "\\][\t ]*")
        |> pattern
        |> ignore newline
        |> map Text


multi_choice : Parser PState (Int -> Hints -> Maybe String -> Quiz)
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


single_choice : Parser PState (Int -> Hints -> Maybe String -> Quiz)
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


hints : Parser PState MultInlines
hints =
    many (quest (string "[?]"))


modify_PState : Quiz -> Parser PState Quiz
modify_PState quiz_ =
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
                Empty _ _ _ ->
                    EmptyState

                Text _ _ _ _ ->
                    TextState ""

                SingleChoice _ _ _ _ _ ->
                    SingleChoiceState -1

                MultipleChoice x _ _ _ _ ->
                    MultipleChoiceState (List.map (\_ -> False) x)
    in
    modifyState (add_state state_)
        |> keep (succeed quiz_)
