module Lia.Parser.Input exposing (add, getPermission, isIdentified, isInput, pop, setGroupPermission, setPermission)

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


setPermission : Bool -> Parser Context ()
setPermission enable =
    modifyState
        (\state ->
            let
                input =
                    state.input
            in
            { state
                | input =
                    { input
                        | isEnabled =
                            if input.grouping then
                                False

                            else
                                enable
                    }
            }
        )


setGroupPermission : Bool -> Parameters -> Parser Context Parameters
setGroupPermission enable attr =
    modifyState
        (\state ->
            let
                input =
                    state.input
            in
            { state
                | input =
                    { input
                        | isEnabled = False
                        , grouping =
                            if Params.isSet "data-quiz-group" attr then
                                True

                            else
                                enable
                    }
            }
        )
        |> keep (succeed attr)


getPermission : Parser Context Bool
getPermission =
    withState
        (\state ->
            state.input.isEnabled
                || state.input.grouping
                |> succeed
        )


pop : Parser Context (Multi.Quiz Markdown.Block Inlines)
pop =
    withState (.input >> .blocks >> succeed)
        |> ignore
            (modifyState
                (\state ->
                    let
                        input =
                            state.input
                    in
                    { state | input = { input | blocks = Multi.init } }
                )
            )


add : ( Int, Block.Quiz Inlines ) -> Parser Context ( String, Int )
add ( length, block ) =
    withState
        (\state ->
            succeed <|
                ( String.fromFloat (toFloat (length + 2) * 0.4) ++ "em"
                , if state.input.isEnabled || state.input.grouping then
                    Array.length state.input.blocks.options

                  else
                    -1
                )
        )
        |> ignore
            (modifyState
                (\state ->
                    let
                        input =
                            state.input
                    in
                    if input.isEnabled || input.grouping then
                        { state
                            | input =
                                { input
                                    | blocks =
                                        Multi.push block input.blocks
                                }
                        }

                    else
                        state
                )
            )


isIdentified : Parser Context Bool
isIdentified =
    withState (.input >> isInput >> succeed)


isInput : { a | isEnabled : Bool, blocks : Multi.Quiz Markdown.Block Inlines } -> Bool
isInput input =
    if input.isEnabled then
        input.blocks
            |> Multi.isEmpty
            |> not

    else
        False
