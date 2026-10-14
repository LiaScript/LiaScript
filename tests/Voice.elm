module Voice exposing (suite)

{-| Characterization tests of `Lia.Voice`: the language of a ResponsiveVoice
narrator and the voice to use for a translated course.
-}

import Expect
import Lia.Voice as Voice
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Lia.Voice"
        [ describe "getLang"
            (List.map
                (\( voice, lang ) ->
                    test (voice ++ " -> " ++ Debug.toString lang) <|
                        \_ -> Voice.getLang voice |> Expect.equal lang
                )
                [ ( "US English Male", Just "en" )
                , ( "Deutsch Female", Just "de" )
                , ( "Russian Female", Just "ru" )
                , ( "Brazilian Portuguese Male", Just "pt" )
                , ( "Fallback UK Female", Just "en" )

                -- a prefix of a male or female voice is enough
                , ( "Deutsch", Just "de" )
                , ( "Chinese (Hong", Just "zh" )
                , ( "", Just "en" )

                -- voices without gender are not found
                , ( "Nepali", Nothing )
                , ( "Klingon Male", Nothing )
                , ( "deutsch female", Nothing )
                ]
            )
        , describe "getVoiceFor"
            (List.map
                (\( ( voice, old, new ), name, expected ) ->
                    test (voice ++ " " ++ old ++ "->" ++ new ++ " " ++ Debug.toString name) <|
                        \_ ->
                            Voice.getVoiceFor voice { old = old, new = new, name = name }
                                |> Expect.equal expected
                )
                [ -- not translated
                  ( ( "Russian Female", "en", "en" ), Nothing, Just { translated = False, lang = "ru", name = "Russian Female" } )
                , ( ( "Klingon", "xx", "xx" ), Nothing, Just { translated = False, lang = "xx", name = "Klingon" } )
                , ( ( "US English Male", "en", "en" ), Nothing, Just { translated = False, lang = "en", name = "US English Male" } )

                -- the narrator does not speak the language of the course
                , ( ( "Russian Female", "en", "de" ), Nothing, Just { translated = False, lang = "ru", name = "Russian Female" } )
                , ( ( "Klingon", "en", "de" ), Nothing, Just { translated = False, lang = "de", name = "Klingon" } )

                -- translated, the gender is kept if possible
                , ( ( "US English Male", "en", "de" ), Nothing, Just { translated = True, lang = "de", name = "Deutsch Male" } )
                , ( ( "UK English Female", "en", "de" ), Nothing, Just { translated = True, lang = "de", name = "Deutsch Female" } )
                , ( ( "US English", "en", "de" ), Nothing, Just { translated = True, lang = "de", name = "Deutsch Male" } )
                , ( ( "US English Male", "en", "ru" ), Nothing, Just { translated = True, lang = "ru", name = "Russian Female" } )
                , ( ( "US English", "en", "ru" ), Nothing, Just { translated = True, lang = "ru", name = "Russian Female" } )
                , ( ( "US English Female", "en", "af" ), Nothing, Just { translated = True, lang = "af", name = "Afrikaans Male" } )
                , ( ( "US English Female", "en", "es" ), Nothing, Just { translated = True, lang = "es", name = "Spanish Latin American Female" } )
                , ( ( "US English Male", "en", "ne" ), Nothing, Just { translated = True, lang = "ne", name = "Nepali" } )

                -- no voice for the new language, then the name of the language
                , ( ( "US English Male", "en", "xx" ), Just "Klingon", Just { translated = True, lang = "xx", name = "Klingon Male" } )
                , ( ( "US English Female", "en", "xx" ), Just "Klingon", Just { translated = True, lang = "xx", name = "Klingon Female" } )
                , ( ( "US English", "en", "xx" ), Just "Klingon", Just { translated = True, lang = "xx", name = "Klingon" } )
                , ( ( "US English Male", "en", "xx" ), Nothing, Nothing )
                ]
            )
        ]
