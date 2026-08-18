module Parser.Block.QuizScripts exposing (associatedScript_Suite)

{-| The docs' "Associated Scripts" feature: a `<script>...</script>` block
directly following a quiz's options (no blank line in between) is consumed by
`Quiz.Parser.maybeJS`, not by the normal block-parsing machinery - it never
shows up as a node in the returned `Blocks` tree at all. Instead it's pushed
onto `Context.effect_model.javascript` (same array every other Effect script
uses) and the pushed script's array index is recorded as
`Context.quiz_vector[i].scriptID`, so the runtime knows which script to
execute when this quiz is "checked". This is unrelated to the gap-text
(`Multi_Type`) `Script`-inline/`toQuiz` path exercised elsewhere - that one is
for a `<script>` trailing a plain paragraph that gets promoted to a quiz; this
one is `Quiz.Parser.modify_State`'s own `maybeJS` call, reached for every
quiz type (`Block_Type`, `Vector_Type`, `Generic_Type`, `Matrix_Type` alike).

Like `Parser.Block.QuizTweaks`, these tests go through `parseWithState` and
inspect the resulting `Context` rather than the returned `Blocks`, since the
script itself isn't part of that tree.

-}

import Array
import Expect
import Lia.Markdown.Effect.Script.Input as Input
import Lia.Markdown.Effect.Script.Types exposing (Modifiable(..), Script, Stdout(..))
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Types exposing (Type(..))
import Lia.Markdown.Quiz.Vector.Types exposing (State(..))
import Lia.Markdown.Types exposing (Block(..))
import Lia.Section exposing (SubSection)
import Parser.Block.Fixtures exposing (paragraph, parseWithState)
import Test exposing (Test, describe, test)


{-| The first (only, in these tests) pushed script, or `Nothing` if none was
attached.
-}
firstScript : String -> Maybe (Script SubSection)
firstScript str =
    parseWithState str
        |> Tuple.second
        |> .effect_model
        |> .javascript
        |> Array.get 0


{-| The first (only, in these tests) quiz's `scriptID`, pointing back into
`effect_model.javascript`.
-}
firstScriptID : String -> Maybe (Maybe Int)
firstScriptID str =
    parseWithState str
        |> Tuple.second
        |> .quiz_vector
        |> Array.get 0
        |> Maybe.map .scriptID


{-| `maybeJS` always calls `eScript` with the same three default attributes
(`input="hidden"`, `block="true"`, `default="undefined"`) - these show up
verbatim in every pushed script below regardless of the quiz type or script
body, since none of these examples set any explicit `<script ...>`
attributes of their own.
-}
defaultInput : Input.Input
defaultInput =
    { active = False
    , alwaysActive = False
    , value = ""
    , default = ""
    , updateOnChange = True
    , type_ = Just Input.Hidden_
    }


associatedScript_Suite : Test
associatedScript_Suite =
    describe "a <script>...</script> block directly following a quiz's options attaches as that quiz's check-script"
        [ test "a Block_Type (standalone [[text]]) quiz with a script computing correctness" <|
            \_ ->
                {- [[dam]]
                   <script>
                   let input = "@input".trim().toLowerCase()

                   input == "dam" || input == "damn"
                   </script>
                -}
                let
                    input =
                        "[[dam]]\n<script>\nlet input = \"@input\".trim().toLowerCase()\n\ninput == \"dam\" || input == \"damn\"\n</script>\n"
                in
                ( parseWithState input |> Tuple.first
                , firstScript input
                , firstScriptID input
                )
                    |> Expect.equal
                        ( [ Quiz []
                                { quiz = Block_Type { options = [], solution = Block.Text "dam" }
                                , id = 0
                                , hints = []
                                }
                                Nothing
                          ]
                        , Just
                            { effect_id = 0
                            , script = "let input = \"@input\".trim().toLowerCase()\n\ninput == \"dam\" || input == \"damn\""
                            , updated = False
                            , running = False
                            , block = True
                            , update = False
                            , runOnce = False
                            , modify = Yes
                            , highlighting = "javascript"
                            , edit = False
                            , result = Just (Text "undefined")
                            , output = Nothing
                            , inputs = []
                            , counter = 0
                            , input = defaultInput
                            , intl = Nothing
                            , worker = False
                            }
                        , Just (Just 0)
                        )
        , test "a Vector_Type (multiple-choice) quiz with a script" <|
            \_ ->
                {- [[X]] A
                   [[ ]] B
                   [[X]] C
                   <script> alert("@input") </script>
                -}
                let
                    input =
                        "[[X]] A\n[[ ]] B\n[[X]] C\n<script> alert(\"@input\") </script>\n"
                in
                ( parseWithState input |> Tuple.first
                , firstScript input |> Maybe.map .script
                , firstScriptID input
                )
                    |> Expect.equal
                        ( [ Quiz []
                                { quiz =
                                    Vector_Type
                                        { options = [ [ paragraph "A" ], [ paragraph "B" ], [ paragraph "C" ] ]
                                        , solution = MultipleChoice [ True, False, True ]
                                        }
                                , id = 0
                                , hints = []
                                }
                                Nothing
                          ]
                        , Just "alert(\"@input\")"
                        , Just (Just 0)
                        )
        , test "a Generic_Type ([[!]]) quiz with a script" <|
            \_ ->
                {- [[!]]
                   <script>alert("@input")</script>
                -}
                let
                    input =
                        "[[!]]\n<script>alert(\"@input\")</script>\n"
                in
                ( parseWithState input |> Tuple.first
                , firstScript input |> Maybe.map .script
                , firstScriptID input
                )
                    |> Expect.equal
                        ( [ Quiz [] { quiz = Generic_Type, id = 0, hints = [] } Nothing ]
                        , Just "alert(\"@input\")"
                        , Just (Just 0)
                        )
        , test "a script body spanning multiple lines (e.g. the docs' async/'LIA: wait' pattern) parses intact" <|
            \_ ->
                {- [[X]] correct
                   [[ ]] wrong
                   <script>
                   async function check() {
                     await send.lia("answer")

                     return "LIA: wait"
                   }

                   check()
                   </script>
                -}
                let
                    body =
                        "async function check() {\n  await send.lia(\"answer\")\n\n  return \"LIA: wait\"\n}\n\ncheck()"

                    input =
                        "[[X]] correct\n[[ ]] wrong\n<script>\n" ++ body ++ "\n</script>\n"
                in
                firstScript input
                    |> Maybe.map .script
                    |> Expect.equal (Just body)
        ]
