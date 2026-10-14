module Script.Types exposing (suite)

{-| The `modify` attribute of a `<script>`, which is rare in real courses.
-}

import Array
import Expect
import Lia.Markdown.Effect.Script.Types as Script exposing (Modifiable(..))
import Test exposing (Test, describe, test)


modify : List ( String, String ) -> Maybe Modifiable
modify params =
    Array.empty
        |> Script.push "en" 0 params "1+1"
        |> Array.get 0
        |> Maybe.map .modify


suite : Test
suite =
    describe "modify"
        ([ ( [], Yes )
         , ( [ ( "modify", "" ) ], Yes )
         , ( [ ( "modify", " TRUE " ) ], Yes )
         , ( [ ( "modify", "1" ) ], Yes )
         , ( [ ( "modify", "False" ) ], No )
         , ( [ ( "modify", "0" ) ], No )
         , ( [ ( "modify", " // \\n" ) ], Partially " // \n" )
         , ( [ ( "modify", "a\\tb" ) ], Partially "a\tb" )
         ]
            |> List.map
                (\( params, expected ) ->
                    test (Debug.toString params) <|
                        \_ -> Expect.equal (Just expected) (modify params)
                )
        )
