module Lia.Parser.Input exposing
    ( add
    , getPermission
    , isIdentified
    , isInput
    , pop
    , setGroupPermission
    , setPermission
    )

{-| Inline quizzes (blocks like `[[option]]`) are collected in the `Context`
while a paragraph or a group (`data-group`) is parsed, so that they can be
turned into a single multi-quiz afterwards.
-}

import Array
import Combine
    exposing
        ( Parser
        , ignore
        , keep
        , modifyState
        , succeed
        , withState
        )
import Lia.Markdown.HTML.Attributes as Params exposing (Parameters)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Multi.Types as Multi
import Lia.Markdown.Types as Markdown
import Lia.Parser.Context exposing (Context)


{-| Enable or disable collecting inline quizzes, within a group it stays
disabled.
-}
setPermission : Bool -> Parser Context ()
setPermission enable =
    updateInput (\input -> { input | isEnabled = not input.grouping && enable })


{-| Start or end a group, the attribute `data-group` always starts one. The
attributes are passed through.
-}
setGroupPermission : Bool -> Parameters -> Parser Context Parameters
setGroupPermission enable attr =
    updateInput
        (\input ->
            { input
                | isEnabled = False
                , grouping = Params.isSet "data-group" attr || enable
            }
        )
        |> keep (succeed attr)


{-| Are inline quizzes collected currently?
-}
getPermission : Parser Context Bool
getPermission =
    withState (\state -> succeed (state.input.isEnabled || state.input.grouping))


{-| Get the collected quizzes and reset them.
-}
pop : Parser Context (Multi.Quiz Markdown.Block Inlines)
pop =
    withState (.input >> .blocks >> succeed)
        |> ignore (updateInput (\input -> { input | blocks = Multi.init }))


{-| Collect an inline quiz with the given length (in characters), the result
is the width of the input field and the id of the quiz, `-1` if quizzes are not
collected currently.
-}
add : ( Int, Block.Quiz Inlines ) -> Parser Context ( String, Int )
add ( length, block ) =
    withState
        (\state ->
            succeed
                -- one spare character, plus padding (2 × 0.5rem) and border (≤ 2px)
                ( "calc(" ++ String.fromInt (length + 1) ++ "ch + 1rem + 4px)"
                , if state.input.isEnabled || state.input.grouping then
                    Array.length state.input.blocks.options

                  else
                    -1
                )
        )
        |> ignore
            (updateInput
                (\input ->
                    if input.isEnabled || input.grouping then
                        { input | blocks = Multi.push block input.blocks }

                    else
                        input
                )
            )


{-| Have inline quizzes been collected in the current paragraph?
-}
isIdentified : Parser Context Bool
isIdentified =
    withState (.input >> isInput >> succeed)


{-| Collecting is enabled and there are collected quizzes.
-}
isInput : { a | isEnabled : Bool, blocks : Multi.Quiz Markdown.Block Inlines } -> Bool
isInput input =
    input.isEnabled && not (Multi.isEmpty input.blocks)


{-| Update the input state of the `Context`.
-}
updateInput : (Input -> Input) -> Parser Context ()
updateInput fn =
    modifyState (\state -> { state | input = fn state.input })


{-| The `input` field of the `Context`.
-}
type alias Input =
    { isEnabled : Bool
    , grouping : Bool
    , blocks : Multi.Quiz Markdown.Block Inlines
    }
