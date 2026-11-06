module Lia.Parser.Context exposing
    ( Context
    , addAbort
    , checkAbort
    , checkBracket
    , choice
    , emphasized
    , getSeed
    , inRef
    , init
    , nested
    , popAbort
    , refLevel
    , remember
    , searchIndex
    , tooDeep
    )

{-| This module defines everything that is necessary to deal with the state of
the parser. This state is called `Context` and might have an influence on the
parsing. It is passed to all successively applied parser.
-}

import Array
import Combine
    exposing
        ( Parser
        , app
        , ignore
        , keep
        , modifyState
        , primitive
        , succeed
        , withState
        )
import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Types as Code
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Footnote.Model as Footnote
import Lia.Markdown.Gallery.Types as Gallery
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Multi.Types as Multi
import Lia.Markdown.Quiz.Types as Quiz
import Lia.Markdown.Survey.Types as Survey
import Lia.Markdown.Table.Types as Table
import Lia.Markdown.Task.Types as Task
import Lia.Markdown.Types as Markdown
import Lia.Parser.Helper exposing (startsWith)
import Lia.Section exposing (SubSection)
import PseudoRandom as Random


{-| The `Context` defines the current state of the parser. It keeps track of the
current indentation as well as on all identified elements that might require state
control:

  - `indentation`: a list of `["  ", "> "]`, elements are pushed on and popped
    off this stack, to check the currently defined indentation.
  - `indentation_skip`: defines if the indentation should be skipped within the
    next step
  - `abort`: a stack of strings that end the current inline parsing (e.g. the
    closing tag of an HTML element)
  - `nesting`: the current nesting of HTML elements, links, emphasis and
    effects, see `Nesting`
  - `****_vector`: any kind of state to preserve for the applied sub-modules.
    Normally new states are pushed on this stack/array and their position (id) is
    later used to identify the required element from within the views.
  - `effect_model` & `effect_number` are specific, the `effect_number` is a
    stack of Int that is required to keep the current animation-id, if for
    example `<script>` are used within a effect or to deal with nested effects.
  - `defines`: is a set of macros and other definitions, that are normally
    defined within the head of every LiaScript document
  - `footnotes`: the footnotes of the section
  - `defines_updated`: set if the section has its own definitions
  - `input`: collects inline quizzes (blocks) within a paragraph or a group
  - `search_index`: a function, that translates a string title into a section
    number
  - `seed`: the state of the pseudo random number generator, see `getSeed`

> Context is commonly used per section, since sections are pre-parsed at first
> and afterwards only the current section is parsed, in order to speed up
> execution.

-}
type alias Context =
    { indentation : List String
    , abort : List String
    , nesting : Nesting
    , indentation_skip : Bool
    , task_vector : Task.Vector
    , code_model : Code.Model
    , quiz_vector : Quiz.Vector
    , survey_vector : Survey.Vector
    , table_vector : Table.Vector
    , gallery_vector : Gallery.Vector
    , effect_model : Effect.Model SubSection
    , effect_number : List Int
    , effect_id : Int
    , input :
        { isEnabled : Bool
        , grouping : Bool
        , blocks : Multi.Quiz Markdown.Block Inlines
        }
    , defines : Definition
    , footnotes : Footnote.Model
    , defines_updated : Bool
    , search_index : String -> String
    , seed : Int
    }


{-| The nesting of inline elements and where they failed before:

  - `depth`: of HTML elements, links, emphasis and effects, see `nested`
  - `emphasis`: of emphasis and quotes only, see `emphasized`
  - `failed`: see `remember`, `failures` only grows with it, so that `choice`
    can see at once if an alternative added a failure

These are not fields of `Context`, one more field there makes V8 copy the
record much slower, the whole parser took about 20% longer.

-}
type alias Nesting =
    { depth : Int
    , emphasis : Int
    , failures : Int
    , failed : Dict ( Int, Int, String ) Failure
    }


{-| Everything else, a failure of `remember` depends on.
-}
type alias Failure =
    { input : String
    , abort : List String
    , indentation : List String
    , inputs : Bool
    , emphasis : Int
    }


{-| Initialize the current `Context` with a searchIndex function and the global
definitions.
-}
init : Maybe Int -> Maybe (String -> String) -> Definition -> Context
init seed search_index global =
    { indentation = []
    , abort = []
    , nesting =
        { depth = 0
        , emphasis = 0
        , failures = 0
        , failed = Dict.empty
        }
    , indentation_skip = False
    , task_vector = Array.empty
    , code_model = Code.init
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
    , table_vector = Array.empty
    , gallery_vector = Array.empty
    , effect_model = Effect.init
    , effect_number = [ 0 ]
    , effect_id = 0
    , input =
        { isEnabled = False
        , grouping = False
        , blocks = Multi.init
        }
    , defines = global
    , footnotes = Footnote.init
    , defines_updated = False
    , search_index = Maybe.withDefault identity search_index
    , seed = seed |> Maybe.withDefault 0
    }


{-| Put the search\_index from the context into the parser-pipeline.
-}
searchIndex : Parser Context (String -> String)
searchIndex =
    withState (.search_index >> succeed)


{-| Get the next pseudo random number, used to shuffle quizzes and surveys.
-}
getSeed : Parser Context Int
getSeed =
    modifyState
        (\state ->
            { state
                | seed =
                    state.seed
                        |> Random.integerSequence 1
                        |> List.head
                        |> Maybe.withDefault 0
            }
        )
        |> keep (withState (.seed >> succeed))


{-| Push a string that ends the current inline parsing.
-}
addAbort : String -> Parser Context ()
addAbort name =
    modifyState (\s -> { s | abort = name :: s.abort })


{-| Nesting of all kinds (HTML elements, links, emphasis, effects, lists and
quotes) shares one limit of 64 levels, so that input like `<div>` x 300 or
64 lists with 64 `<div>` inside cannot overflow the stack.
-}
tooDeep : Context -> Bool
tooDeep state =
    state.nesting.depth + List.length state.indentation >= 64


{-| Parse nested content (HTML elements, links, emphasis, effects) one level
deeper. Beyond the limit of `tooDeep` it fails, such content is shown as text.
-}
nested : Parser Context a -> Parser Context a
nested p =
    primitive
        (\state stream ->
            if tooDeep state then
                ( state, stream, Err [ "nested too deep" ] )

            else
                ( deeper 1 0 state, stream, Ok () )
        )
        |> keep p
        |> ignore (modifyState (deeper -1 0))


{-| Emphasis and quotes can be nested by 5 levels
(`**a *"b _x^2^_"* c**`), deeper markers are shown as text. Mixed emphasis that cannot be closed (see
`remember`) is tried again on every level, so every level multiplies the time.
-}
emphasized : Parser Context a -> Parser Context a
emphasized p =
    primitive
        (\state stream ->
            if state.nesting.emphasis >= 5 then
                ( state, stream, Err [ "emphasis too deep" ] )

            else
                ( deeper 0 1 state, stream, Ok () )
        )
        |> keep p
        |> ignore (modifyState (deeper 0 -1))


deeper : Int -> Int -> Context -> Context
deeper depth emphasis state =
    let
        nesting =
            state.nesting
    in
    { state
        | nesting =
            { nesting
                | depth = nesting.depth + depth
                , emphasis = nesting.emphasis + emphasis
            }
    }


{-| Parse the text `[...]` of a link (1) or of a media reference (2), it ends
at the next `]`. Media text pushes the abort string `"]"` twice, so that
`refLevel` can tell both apart without another field in the context.
-}
inRef : Int -> Parser Context a -> Parser Context a
inRef level p =
    modifyState (\s -> { s | abort = List.repeat level "]" ++ s.abort })
        |> keep p
        |> ignore (modifyState (\s -> { s | abort = List.drop level s.abort }))


{-| 0 outside of reference text, 1 within link text (only media references are
allowed), 2 within media text (no references), see `inRef`.
-}
refLevel : Context -> Int
refLevel state =
    case dropTillBracket state.abort of
        [] ->
            0

        _ :: "]" :: _ ->
            2

        _ ->
            1


dropTillBracket : List String -> List String
dropTillBracket abort =
    case abort of
        "]" :: _ ->
            abort

        _ :: rest ->
            dropTillBracket rest

        [] ->
            []


{-| Within the text of a reference, a `[` cannot be plain text. It starts an
inner reference that ends with the same `](...)`, and the inner one wins, since
markdown does not allow links within links. Failing here, the outer reference
fails at the first `[` and does not parse its text again for every `[` within
it, which would be exponential. Beyond the nesting limit no inner reference
can be parsed, there the `[` is text.
-}
checkBracket : Parser Context ()
checkBracket =
    primitive
        (\state stream ->
            if startsWith "[" stream.input && List.member "]" state.abort && not (tooDeep state) then
                ( state, stream, Err [ "[ within reference" ] )

            else
                ( state, stream, Ok () )
        )


{-| Remove the last pushed abort string.
-}
popAbort : Parser Context ()
popAbort =
    modifyState (\s -> { s | abort = List.drop 1 s.abort })


{-| Fail if the input starts with the last pushed abort string, otherwise
succeed without consuming input.

This runs before every inline element, therefore it is a single `primitive`.

-}
checkAbort : Parser Context ()
checkAbort =
    primitive
        (\state stream ->
            case state.abort of
                name :: _ ->
                    if startsWith name stream.input then
                        ( state, stream, Err [ "abort" ] )

                    else
                        ( state, stream, Ok () )

                [] ->
                    ( state, stream, Ok () )
        )


{-| Fail at once, where `p` (called `name`) has already failed with the same
input and state, otherwise run `p` and remember if it fails.

Mixed emphasis like `*_~*_~ x *_~*_~` has closing markers, but they do not
match. Every marker that fails is taken as text and the next ones are tried
again, without this, every marker doubles the time.

The failure is passed on with the state, which `Combine.choice` drops, so
`choice` must be used on the way back to where `p` is tried again.

-}
remember : String -> Parser Context a -> Parser Context a
remember name p =
    primitive
        (\state stream ->
            let
                nesting =
                    state.nesting

                key =
                    ( stream.position, nesting.depth, name )

                here =
                    { input = stream.input
                    , abort = state.abort
                    , indentation = state.indentation
                    , inputs = state.input.isEnabled
                    , emphasis = nesting.emphasis
                    }
            in
            if Dict.get key nesting.failed == Just here then
                ( state, stream, Err [ "failed before" ] )

            else
                case app p state stream of
                    ( estate, _, Err ms ) ->
                        ( { state
                            | nesting =
                                { nesting
                                    | failures = estate.nesting.failures + 1
                                    , failed = Dict.insert key here estate.nesting.failed
                                }
                          }
                        , stream
                        , Err ms
                        )

                    ok ->
                        ok
        )


{-| Like `Combine.choice`, but the failures `remember`ed by one alternative are
passed on to the next ones.
-}
choice : List (Parser Context a) -> Parser Context a
choice parsers =
    let
        try list state stream errors =
            case list of
                [] ->
                    ( state, stream, Err (List.reverse errors) )

                p :: rest ->
                    case app p state stream of
                        ( estate, _, Err ms ) ->
                            try rest
                                (if estate.nesting.failures == state.nesting.failures then
                                    state

                                 else
                                    let
                                        nesting =
                                            state.nesting
                                    in
                                    { state
                                        | nesting =
                                            { nesting
                                                | failures = estate.nesting.failures
                                                , failed = estate.nesting.failed
                                            }
                                    }
                                )
                                stream
                                (List.foldl (::) errors ms)

                        ok ->
                            ok
    in
    primitive (\state stream -> try parsers state stream [])
