module Lia.Voice exposing
    ( Voice
    , getLang
    , getVoiceFor
    )

{-| The ResponsiveVoice narrators (`US English Male`, `Deutsch Female`, ...),
their languages, and which narrator to use for a translated course.
-}

import List.Extra


{-| A narrator and the language it speaks, `translated` is true if it
replaces the narrator of the course, because the course got translated.
-}
type alias Voice =
    { translated : Bool
    , lang : String
    , name : String
    }


{-| The voices of one language, `default` is used for languages that only have
a voice without gender.
-}
type alias ResponsiveVoice =
    { lang : String
    , female : Maybe String
    , male : Maybe String
    , default : Maybe String
    }


voices : List ResponsiveVoice
voices =
    [ toVoice "US English" "en" True True
    , toVoice "UK English" "en" True True
    , toVoice "Australian" "en" True True
    , toVoice "Fallback UK" "en" True False
    , toVoice "Afrikaans" "af" False True
    , toVoice "Albanian" "sq" False True
    , toVoice "Arabic" "ar" True True
    , toVoice "Armenian" "hy" False True
    , toVoice "Bangla Bangladesh" "bn" True True
    , toVoice "Bangla India" "bn" True True
    , toVoice "Bosnian" "bs" False True
    , toVoice "Catalan" "ca" False True
    , toVoice "Chinese" "zh" True True
    , toVoice "Chinese (Hong Kong)" "zh" True True
    , toVoice "Chinese Taiwan" "zh" True True
    , toVoice "Croatian" "hr" False True
    , toVoice "Czech" "cz" True False
    , toVoice "Danish" "da" True False
    , toVoice "Deutsch" "de" True True
    , toVoice "German" "de" True True
    , toVoice "Dutch" "nl" True True
    , toVoice "Esperanto" "eo" False True
    , toVoice "Estonian" "et" False True
    , toVoice "Filipino" "ph" True False
    , toVoice "Finnish" "fi" True False
    , toVoice "French" "fr" True True
    , toVoice "French Canadian" "fr" True True
    , toVoice "Greek" "el" True False
    , toVoice "Hindi" "hi" True True
    , toVoice "Hungarian" "hu" True False
    , toVoice "Icelandic" "is" False True
    , toVoice "Indonesian" "id" True True
    , toVoice "Italian" "it" True True
    , toVoice "Japanese" "ja" True True
    , toVoice "Korean" "ko" True True
    , toVoice "Latin" "la" False True
    , toVoice "Latvian" "lv" False True
    , toVoice "Macedonian" "mk" False True
    , toVoice "Moldavian" "mo" True False
    , toVoice "Montenegrin" "me" False True
    , toVoice "Nepali" "ne" False False
    , toVoice "Norwegian" "no" True True
    , toVoice "Polish" "pl" True True
    , toVoice "Portuguese" "pt" True True
    , toVoice "Brazilian Portuguese" "pt" False True
    , toVoice "Romanian" "ro" True False
    , toVoice "Russian" "ru" True False
    , toVoice "Serbian" "sr" False True
    , toVoice "Serbo-Croatian" "sh" False True
    , toVoice "Sinhala" "si" False False
    , toVoice "Slovak" "sk" True False
    , toVoice "Spanish Latin American" "es" True True
    , toVoice "Spanish" "es" True False
    , toVoice "Swahili" "sw" False True
    , toVoice "Swedish" "sv" True True
    , toVoice "Tamil" "ta" True True
    , toVoice "Thai" "th" True True
    , toVoice "Turkish" "tr" True True
    , toVoice "Ukrainian" "uk" True False
    , toVoice "Vietnamese" "vi" True True
    , toVoice "Welsh" "cy" False True
    ]


{-| `toVoice name lang hasFemale hasMale`
-}
toVoice : String -> String -> Bool -> Bool -> ResponsiveVoice
toVoice name lang female male =
    { lang = lang
    , female = maybeIf female (name ++ " Female")
    , male = maybeIf male (name ++ " Male")
    , default = maybeIf (not male && not female) name
    }


maybeIf : Bool -> a -> Maybe a
maybeIf condition value =
    if condition then
        Just value

    else
        Nothing


{-| The language of the first narrator, whose male or female name starts with
`voice` (voices without gender are not found):

    getLang "Deutsch Female" == Just "de"

    getLang "Deutsch" == Just "de"

-}
getLang : String -> Maybe String
getLang voice =
    voices
        |> List.Extra.find
            (\v ->
                [ v.male, v.female ]
                    |> List.filterMap identity
                    |> List.any (String.startsWith voice)
            )
        |> Maybe.map .lang


{-| The voice of the first entry of language `lang`, with the requested gender
(male if unknown) or else the other one.
-}
getVoiceFromLang : String -> Maybe Bool -> Maybe String
getVoiceFromLang lang male =
    voices
        |> List.Extra.find (\v -> v.lang == lang)
        |> Maybe.andThen
            (\v ->
                (if male == Just False then
                    [ v.female, v.male, v.default ]

                 else
                    [ v.male, v.female, v.default ]
                )
                    |> List.filterMap identity
                    |> List.head
            )


{-| The gender of a voice is its last word, `Male` or `Female`.
-}
isMale : String -> Maybe Bool
isMale voice =
    case voice |> String.split " " |> List.reverse of
        "Male" :: _ ->
            Just True

        "Female" :: _ ->
            Just False

        _ ->
            Nothing


{-| The narrator for the comments of a course, that was written in language
`old` and is now shown in `new` (`name` is the name of the new language). If
the narrator speaks the old language, it gets replaced by a voice of the new
language with the same gender, or by the name of the new language if there is
no such voice:

    getVoiceFor "Russian Female" { old = "en", new = "en", name = Nothing }
    --> Just { translated = False, lang = "ru", name = "Russian Female" }

    getVoiceFor "Russian Female" { old = "en", new = "de", name = Nothing }
    --> Just { translated = False, lang = "ru", name = "Russian Female" }

    getVoiceFor "US English Male" { old = "en", new = "en", name = Nothing }
    --> Just { translated = False, lang = "en", name = "US English Male" }

    getVoiceFor "US English Male" { old = "en", new = "de", name = Nothing }
    --> Just { translated = True, lang = "de", name = "Deutsch Male" }

-}
getVoiceFor : String -> { x | name : Maybe String, old : String, new : String } -> Maybe Voice
getVoiceFor voice lang =
    if lang.old == lang.new then
        -- Nothing has changed: the audio (recorded or synthesized) still
        -- matches the document's own language, so it must not be
        -- overridden/muted in favor of a synthesized translation
        Just { translated = False, lang = getLang voice |> Maybe.withDefault lang.old, name = voice }

    else if getLang voice == Just lang.old then
        -- the old voice needs to be translated too
        case ( getVoiceFromLang lang.new (isMale voice), lang.name ) of
            ( Just newName, _ ) ->
                Just { translated = True, lang = lang.new, name = newName }

            ( Nothing, Just langName ) ->
                Just
                    { translated = True
                    , lang = lang.new
                    , name =
                        case isMale voice of
                            Just True ->
                                langName ++ " Male"

                            Just False ->
                                langName ++ " Female"

                            Nothing ->
                                langName
                    }

            ( Nothing, Nothing ) ->
                Nothing

    else
        -- the narrator speaks another language than the course
        Just { translated = False, lang = getLang voice |> Maybe.withDefault lang.new, name = voice }
