module Lia.Quiz.Parser exposing (quiz)

import Array exposing (push)
import Combine exposing (..)
import Lia.Inline.Parser exposing (..)
import Lia.Inline.Types exposing (..)
import Lia.PState exposing (PState)
import Lia.Quiz.Types exposing (Quiz(..), QuizBlock, QuizState(..), QuizVector)


quiz : Parser PState QuizBlock
quiz =
    let
        counter =
            let
                pp par =
                    succeed par.num_quiz

                increment_counter c =
                    { c | num_quiz = c.num_quiz + 1 }
            in
            withState pp <* modifyState increment_counter
    in
    QuizBlock <$> choice [ quiz_SingleChoice, quiz_MultipleChoice, quiz_TextInput ] <*> counter <*> quiz_hints


quiz_TextInput : Parser PState Quiz
quiz_TextInput =
    let
        state txt =
            modifyState (\s -> push_state s (Text "" txt)) *> succeed txt
    in
    TextInput <$> ((regex "[ \\t]*\\[\\[" *> regex "[^\n\\]]+" <* regex "\\]\\]( *)\\n") >>= state)


push_state : PState -> QuizState -> PState
push_state p q =
    { p
        | quiz_vector =
            push
                { solved = Nothing
                , state = q
                , trial = 0
                , hint = 0
                }
                p.quiz_vector
    }


quiz_SingleChoice : Parser PState Quiz
quiz_SingleChoice =
    let
        get_result list =
            list
                |> List.indexedMap (,)
                |> List.filter (\( _, ( rslt, _ ) ) -> rslt == True)
                |> (\l ->
                        case List.head l of
                            Just ( i, _ ) ->
                                i

                            Nothing ->
                                -1
                   )

        state a =
            modifyState (\s -> push_state s (Single -1 <| List.length a)) *> succeed a
    in
    many (checked False (regex "[ \\t]*\\[\\( \\)\\]"))
        |> map (\a b -> List.append a [ b ])
        |> andMap (checked True (regex "[ \\t]*\\[\\(X\\)\\]"))
        |> map (++)
        |> (\p -> andMap (many (checked False (regex "[ \\t]*\\[\\( \\)\\]")) >>= state) p)
        |> map (\q -> SingleChoice (get_result q) (List.map (\( _, qq ) -> qq) q))


checked : Bool -> Parser PState res -> Parser PState ( Bool, List Inline )
checked b p =
    (\l -> ( b, l )) <$> (p *> line <* newline)


quiz_hints : Parser PState (List (List Inline))
quiz_hints =
    many (regex "[ \\t]*\\[\\[\\?\\]\\]" *> line <* newline)


quiz_MultipleChoice : Parser PState Quiz
quiz_MultipleChoice =
    let
        state mc =
            let
                element =
                    mc
                        |> List.map (\( b, _ ) -> ( False, b ))
                        |> Array.fromList
                        |> Multi
            in
            modifyState (\s -> push_state s element) *> succeed mc
    in
    MultipleChoice
        <$> (many1
                (choice
                    [ checked True (regex "[ \\t]*\\[\\[X\\]\\]")
                    , checked False (regex "[ \\t]*\\[\\[ \\]\\]")
                    ]
                )
                >>= state
            )
