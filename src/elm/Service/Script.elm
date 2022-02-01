module Service.Script exposing
    ( Eval
    , decode
    , decoder
    , eval
    , input
    , replace_input
    , replace_inputID
    , replace_inputKey
    , stop
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Utils exposing (toEscapeString, toJSstring)
import Service.Event as Event exposing (Event)


{-| The evaluation of code from code-snippets is passed back as `Eval`:

    -- everything went fine
    { ok = True
    , result = "42" -- the result is always a string
    , details = [] -- the details are directly passed to the ACE editor instance
    }

    -- an error has occurred
    { ok = False
    , result = "42" -- this is now treated as an Error message
    -- the details are directly passed to the ACE editor instance
    , details = [[{
        row = 10,
        column = 0,
        text = "some error message or warning" ,
        type = "error|warning|info",
        }],
        []]
    }

The `details` entry contains a list of list of dicts. This way multiple warnings
or information can be associated to one file within a project in a code-snippet.
Thus, the very first list in details is associated with the first file in a
project, etc.

-}
type alias Eval =
    { ok : Bool
    , result : String
    , details : List JE.Value
    }


{-| Base decoder for `eval` results
-}
decoder : JD.Decoder Eval
decoder =
    JD.map3 Eval
        (JD.field "ok" JD.bool)
        (JD.field "result" JD.string)
        (JD.field "details" (JD.list JD.value))


{-| Decode base evaluation results. If the result cannot be decoded, then an
error `Eval` is created, which describes the parsing error.
-}
decode : JD.Value -> Eval
decode json =
    case JD.decodeValue decoder json of
        Ok result ->
            result

        Err info ->
            Eval False (JD.errorToString info) []


{-| Replace all appearances of the `@input` macro within the code, which is
thought to represent the default input.

This should be done as the last step, after all instances of parameterized
`@input` have been replaced:

  - `replace_inputID`
  - `replace_inputKey`

```
replace_input "hello world" "console.log('@input')"
    == "console.log('hello world')"
```

-}
replace_input : String -> String -> String
replace_input replacement code =
    replace_ "" replacement code


{-| When dealing with projects in LiaScript, then these projects can contain
multiple files, which shall be injected into the code, send to the execution.
The position is marked as a `@input(id)`, where id is a number ranging from
0 to 9.

    replace_input ( 1, "hello world" ) "console.log('@input(1)')"
        == "console.log('hello world')"

-}
replace_inputID : ( Int, String ) -> String -> String
replace_inputID ( id, replacement ) code =
    replace_ ("(" ++ String.fromInt id ++ ")") replacement code


{-| Keyed inputs are marked by a string as input parameter. This is used to
inject results from other scripts that have a topic on which they publish
their results:

    replace_input ( "topic", "hello world" ) "console.log('@input(`topic`)')"
        == "console.log('hello world')"

-}
replace_inputKey : ( String, String ) -> String -> String
replace_inputKey ( key, replacement ) code =
    replace_ ("(`" ++ key ++ "`)") replacement code


{-| **private:** This helper is used to replace normal `@input` macros as well
as those in debugging mode `@'input`.
-}
replace_ pattern replacement =
    String.replace ("@'input" ++ pattern) (toEscapeString replacement)
        >> String.replace ("@input" ++ pattern) replacement


{-| Send stop notification to the evaluated script, the handling has to be
implemented manually.
-}
stop : Event
stop =
    event "stop" JE.null


{-| Send a typed string from the terminal to the evaluated script, the handler
has to be implemented manually.
-}
input : String -> Event
input string =
    string
        |> JE.string
        |> event "input"


{-| Send an evaluation request to the Script-Service, defined in `Script.ts`.

  - `code`: defines the original code snippet that should be evaluated
  - `scripts`: is a keyed list of results from other scripts, where the first
    parameter defines the topic and the second one the replacement string
  - `inputs`: mostly contains all files from a LiaScript code-snippet project,
    which is used to replace numbered input macros => `@input(id)`

-}
eval : String -> List ( String, String ) -> List String -> Event
eval code scripts inputs =
    let
        -- the first input parameter is also used as the default
        -- one to replace the `@input` without parenthesis
        default =
            inputs
                |> List.head
                |> Maybe.withDefault ""
                |> toJSstring

        -- this will replace all inputs, that are originally the
        -- results from other scripts, to which this script is
        -- subscribed
        code_ =
            List.foldl replace_inputKey code scripts
    in
    inputs
        |> List.indexedMap (\i r -> ( i, toJSstring r ))
        |> List.foldl replace_inputID code_
        |> replace_input default
        |> JE.string
        |> event "eval"


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Script.ts`.
-}
event : String -> JE.Value -> Event
event cmd param =
    Event.init "script" { cmd = cmd, param = param }
