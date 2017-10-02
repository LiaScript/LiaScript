module Lia.Quiz.Parser exposing (parse)

import Array
import Combine exposing (..)
import Lia.Inline.Parser exposing (..)
import Lia.Inline.Types exposing (..)
import Lia.PState exposing (PState)
import Lia.Quiz.Types exposing (Hints, Quiz(..), QuizState(..), QuizVector, Solution(..))


parse : Parser PState Quiz
parse =
    quiz >>= modify_PState


quiz : Parser PState Quiz
quiz =
    choice [ single_choice, multi_choice, text ] <*> get_counter <*> hints


get_counter : Parser PState Int
get_counter =
    withState (\s -> succeed (Array.length s.quiz_vector))


pattern : Parser s a -> Parser s a
pattern p =
    regex "[ \\t]*\\[" *> p <* string "]"


quest : Parser PState a -> Parser PState Line
quest p =
    pattern p *> line <* newline


text : Parser PState (ID -> Hints -> Quiz)
text =
    Text <$> pattern (string "[" *> regex "[^\n\\]]+" <* regex "\\][ \\t]*") <* newline


multi_choice : Parser PState (ID -> Hints -> Quiz)
multi_choice =
    let
        checked b p =
            (\l -> ( b, l )) <$> quest p

        gen m =
            let
                ( list, questions ) =
                    List.unzip m
            in
            MultipleChoice (Array.fromList list) questions
    in
    gen
        <$> many1
                (choice
                    [ checked True (string "[X]")
                    , checked False (string "[ ]")
                    ]
                )


single_choice : Parser PState (ID -> Hints -> Quiz)
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
    par <$> wrong <*> correct <*> wrong


hints : Parser PState (List Line)
hints =
    many (quest (string "[?]"))


modify_PState : Quiz -> Parser PState Quiz
modify_PState quiz_ =
    let
        add_state e s =
            { s
                | quiz_vector =
                    Array.push
                        { solved = Open, state = e, trial = 0, hints = 0 }
                        s.quiz_vector
            }

        state =
            case quiz_ of
                Text _ _ _ ->
                    TextState ""

                SingleChoice _ _ _ _ ->
                    SingleChoiceState -1

                MultipleChoice x _ _ _ ->
                    MultipleChoiceState (Array.repeat (Array.length x) False)
    in
    modifyState (add_state state) *> succeed quiz_
