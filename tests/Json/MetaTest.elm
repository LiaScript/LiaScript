module Json.MetaTest exposing (suite)

{-| The course description the SCORM "suspend" connectors report with
(`Lia.Json.Meta`): one entry per state, in the order of the state vectors,
with the question in front and the solutions.
-}

import Array
import Expect
import Json.Decode as JD
import Json.Encode as JE
import Lia.Json.Meta as Meta
import Lia.Script
import Lia.Update exposing (generate)
import Test exposing (Test, describe, test)


course : String
course =
    """<!--
language: en
-->

# Course

## Quizzes

What is 2 + 2?

[( )] 3
[(X)] 4
[( )] 5

[[ (red) | green | (blue) ]]

The capital of France is [[Paris]] and of Italy [[ (Rome) | Milan ]].

Checked by a script:

[[!]]
<script>true</script>

## Surveys

How are you?

- [(good)] Good
- [(bad)]  Bad

Topics:

- [[ai]]  AI
- [[web]] Web

Your opinion:

[[___ ___ ___]]

## Nothing to answer

Just text.
"""


{-| Parses the course like the worker does: definition, titles, then every
section's body.
-}
parse : String -> Lia.Script.Model
parse script =
    let
        initial =
            Lia.Script.init
                { seed = 0
                , hasShareApi = Just False
                , openTOC = True
                , isFullscreen = False
                , settings = JE.null
                , backends = { support = [], enabled = False }
                , url = ""
                , readme = ""
                , origin = ""
                , anchor = Nothing
                }
                |> (\model -> Lia.Script.init_script model script)

        titles model code =
            case code of
                Nothing ->
                    model

                Just rest ->
                    Lia.Script.parse_section model rest |> (\( m, c ) -> titles m c)

        bodies active model =
            if active == Array.length model.sections then
                model

            else
                bodies (active + 1) (generate { model | section_active = active })
    in
    titles initial.model initial.code |> bodies 0


slides : List JE.Value
slides =
    parse course
        |> .sections
        |> Array.toList
        |> List.map Meta.slide


at : Int -> JD.Decoder a -> Result JD.Error a
at i decoder =
    case List.drop i slides of
        slide :: _ ->
            JD.decodeValue decoder slide

        [] ->
            Err (JD.Failure "no such slide" JE.null)


suite : Test
suite =
    describe "Lia.Json.Meta"
        [ test "one entry per element of the state vectors" <|
            \_ ->
                parse course
                    |> .sections
                    |> Array.toList
                    |> List.map (\s -> ( Array.length s.quiz_vector, Array.length s.survey_vector ))
                    |> Expect.equal
                        (List.map
                            (\slide ->
                                ( JD.decodeValue (JD.field "quiz" (JD.list JD.value)) slide |> Result.map List.length |> Result.withDefault -1
                                , JD.decodeValue (JD.field "survey" (JD.list JD.value)) slide |> Result.map List.length |> Result.withDefault -1
                                )
                            )
                            slides
                        )
        , test "a choice quiz with its question, options and solution" <|
            \_ ->
                at 1
                    (JD.field "quiz"
                        (JD.index 0
                            (JD.map4 (\a b c d -> { type_ = a, question = b, options = c, solution = d })
                                (JD.field "type" JD.string)
                                (JD.field "question" JD.string)
                                (JD.field "options" (JD.list JD.string))
                                (JD.field "solution" (JD.list JD.bool))
                            )
                        )
                    )
                    |> Expect.equal (Ok { type_ = "single", question = "What is 2 + 2?", options = [ "3", "4", "5" ], solution = [ False, True, False ] })
        , test "a selection with two correct options" <|
            \_ ->
                at 1 (JD.field "quiz" (JD.index 1 (JD.map2 Tuple.pair (JD.field "type" JD.string) (JD.field "solution" (JD.list JD.int)))))
                    |> Expect.equal (Ok ( "select", [ 0, 2 ] ))
        , test "a gap text numbers its gaps" <|
            \_ ->
                at 1
                    (JD.field "quiz"
                        (JD.index 2
                            (JD.map2 Tuple.pair
                                (JD.field "question" JD.string)
                                (JD.field "gaps" (JD.list (JD.field "type" JD.string)))
                            )
                        )
                    )
                    |> Expect.equal (Ok ( "The capital of France is [1] and of Italy [2].", [ "text", "select" ] ))
        , test "a script quiz has no solution" <|
            \_ ->
                at 1
                    (JD.field "quiz"
                        (JD.index 3
                            (JD.map3 (\a b c -> ( a, b, c ))
                                (JD.field "type" JD.string)
                                (JD.field "solution" (JD.null "null"))
                                (JD.field "question" JD.string)
                            )
                        )
                    )
                    |> Expect.equal (Ok ( "generic", "null", "Checked by a script:" ))
        , test "survey types come from the syntax, keys stay" <|
            \_ ->
                at 2
                    (JD.field "survey"
                        (JD.list
                            (JD.map2 Tuple.pair
                                (JD.field "type" JD.string)
                                (JD.maybe (JD.field "options" (JD.list (JD.field "key" JD.string))))
                            )
                        )
                    )
                    |> Expect.equal
                        (Ok
                            [ ( "single", Just [ "good", "bad" ] )
                            , ( "multiple", Just [ "ai", "web" ] )
                            , ( "textarea", Nothing )
                            ]
                        )
        , test "a slide without elements has empty lists and its title" <|
            \_ ->
                at 3 (JD.map2 Tuple.pair (JD.field "title" JD.string) (JD.field "quiz" (JD.list JD.value)))
                    |> Expect.equal (Ok ( "Nothing to answer", [] ))
        ]
