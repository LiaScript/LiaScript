module Lia.Parser.Input exposing (..)

import Array
import Combine
    exposing
        ( Parser
        , ignore
        , modifyState
        , succeed
        , withState
        )
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


setGroupPermission : Bool -> Parser Context ()
setGroupPermission enable =
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
                        , grouping = enable
                    }
            }
        )


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


add : ( Int, Block.Quiz Inlines ) -> Parser Context ( Int, Int )
add ( length, block ) =
    withState
        (\state ->
            succeed <|
                ( length
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
    withState
        (\state ->
            succeed <|
                if state.input.isEnabled then
                    state.input.blocks
                        |> Multi.isEmpty
                        |> not

                else
                    False
        )
