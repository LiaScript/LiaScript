module Lia.Markdown.Effect.Script.Types exposing
    ( Modifiable(..)
    , Msg(..)
    , Script
    , Scripts
    , Stdout(..)
    , count
    , outputs
    , push
    , text
    )

{-| Inline `<script>` elements of a section. Every script is stored with its
index in the section's `Scripts` array, which is also the id used by the
`Script` inline and in the event track (`("script", id)`).
-}

import Array exposing (Array)
import Lia.Markdown.Effect.Script.Input as Input exposing (Input)
import Lia.Markdown.Effect.Script.Intl as Intl exposing (Intl)
import Lia.Markdown.HTML.Attributes as Attr exposing (Parameters)
import Regex
import Service.Event exposing (Event)


{-| All scripts of a section, `a` is the type of a nested LiaScript result
(`SubSection`, see `IFrame`).
-}
type alias Scripts a =
    Array (Script a)


{-| The last result of a script:

  - `Text`: plain text, formatted via `Intl` if `format` is set
  - `HTML`: the result started with `HTML:` and is inserted as markup
  - `IFrame`: the result started with `LIASCRIPT:` and was parsed as LiaScript
  - `Error`: the script failed or `LIASCRIPT:` could not be parsed

-}
type Stdout a
    = Error String
    | Text String
    | HTML String
    | IFrame a


type Msg sub
    = Click Int
    | Reset Int
    | Execute Int String
    | Activate Bool Int
    | Value Int Bool String
    | Radio Int Bool String
    | Checkbox Int Bool String
    | Edit Bool Int
    | EditCode Int String
    | EditParam Int String String
    | NoOp
    | Handle Event
    | Delay Float (Msg sub)
    | Batch (List (Msg sub))
    | Sub Int sub


{-| Defined by the attribute `modify`: can the code be edited by a double click
on the result? `Partially` only allows to edit the part between the first two
appearances of the given separator.
-}
type Modifiable
    = Yes
    | No
    | Partially String


{-| The text result of a script, used to turn a script into a string.
-}
text : Stdout a -> Maybe String
text stdout =
    case stdout of
        Text str ->
            Just str

        _ ->
            Nothing


type alias Script a =
    { effect_id : Int
    , script : String
    , updated : Bool -- the input was changed, do not close it on Activate
    , running : Bool
    , block : Bool -- the script is only executed by an external handler (quiz, survey, task)
    , update : Bool -- rerun the script after the current run, its input or a subscribed output changed
    , runOnce : Bool
    , modify : Modifiable
    , highlighting : String
    , edit : Bool
    , result : Maybe (Stdout a)
    , output : Maybe String -- the topic this script publishes its result on
    , inputs : List String -- the topics this script is subscribed to via @input(`topic`)
    , counter : Int
    , input : Input
    , intl : Maybe Intl
    , worker : Bool
    , solution : Maybe String -- only executed, when this quiz/survey solution gets visible
    }


{-| Matches subscriptions to other scripts, i.e. ``@input(`topic`)``.
-}
inputTopic : Regex.Regex
inputTopic =
    Maybe.withDefault Regex.never <|
        Regex.fromString "@input\\(`([^`]+)`\\)"


modifications : Parameters -> Modifiable
modifications params =
    case Attr.get "modify" params of
        Nothing ->
            Yes

        Just pattern ->
            case pattern |> String.trim |> String.toLower of
                "true" ->
                    Yes

                "1" ->
                    Yes

                "" ->
                    Yes

                "false" ->
                    No

                "0" ->
                    No

                _ ->
                    pattern
                        |> String.replace "\\n" "\n"
                        |> String.replace "\\t" "\t"
                        |> Partially


{-| Append a new script with the language `lang` (default locale for `Intl`),
the effect id it is bound to, the attributes of the `<script>` tag and its
code.
-}
push : String -> Int -> Parameters -> String -> Scripts a -> Scripts a
push lang id params script =
    Array.push
        { effect_id = id
        , script = script
        , updated = False
        , running = False
        , block = Attr.isSet "block" params
        , update = False
        , runOnce = Attr.isSet "run-once" params
        , modify = modifications params
        , highlighting =
            params
                |> Attr.get "type"
                |> Maybe.map (String.replace "text/" "")
                |> Maybe.withDefault "javascript"
        , edit = False
        , result =
            params
                |> Attr.get "default"
                |> Maybe.map Text
        , output = Attr.get "output" params
        , inputs =
            script
                |> Regex.find inputTopic
                |> List.filterMap (.submatches >> List.head >> Maybe.andThen identity)
        , counter = 0
        , input = Input.from params
        , intl = Intl.from lang params
        , worker = Attr.isSet "worker" params
        , solution = Nothing
        }


{-| Index of the last script, `-1` if there is none.
-}
count : Scripts a -> Int
count =
    Array.length >> (+) -1


{-| All published text results as `(topic, result)`, these replace the
``@input(`topic`)`` macros of subscribed scripts and code blocks.
-}
outputs : Scripts a -> List ( String, String )
outputs =
    Array.foldr
        (\js list ->
            case ( js.output, js.result ) of
                ( Just output, Just (Text result) ) ->
                    ( output, result ) :: list

                _ ->
                    list
        )
        []
