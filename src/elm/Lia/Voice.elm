module Lia.Voice exposing
    ( Voice
    , getLang
    , getVoiceFor
    )


type alias Voice =
    { translated : Bool
    , lang : String
    , name : String
    }


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
    , toVoice "Swahili" "si" False True
    , toVoice "Swedish" "sv" True True
    , toVoice "Tamil" "ta" True True
    , toVoice "Thai" "th" True True
    , toVoice "Turkish" "tr" True True
    , toVoice "Ukrainian" "uk" True False
    , toVoice "Vietnamese" "vi" True True
    , toVoice "Welsh" "cy" False True
    ]


toVoice : String -> String -> Bool -> Bool -> ResponsiveVoice
toVoice name lang female male =
    ResponsiveVoice lang
        (if female then
            Just <| name ++ " Female"

         else
            Nothing
        )
        (if male then
            Just <| name ++ " Male"

         else
            Nothing
        )
        (if not male && not female then
            Just name

         else
            Nothing
        )


getLang : String -> Maybe String
getLang voice =
    voices
        |> List.filterMap
            (\v ->
                if v.male == Just voice || v.female == Just voice then
                    Just v.lang

                else
                    Nothing
            )
        |> List.head


getVoiceFromLang : String -> Bool -> Maybe String
getVoiceFromLang lang male =
    voices
        |> List.filterMap
            (\v ->
                if v.lang == lang then
                    Just v

                else
                    Nothing
            )
        |> List.head
        |> Maybe.andThen (getVoice male)


getVoice : Bool -> ResponsiveVoice -> Maybe String
getVoice male voice =
    case ( male, voice.male, voice.female ) of
        ( True, Just maleVoice, _ ) ->
            Just maleVoice

        ( True, Nothing, Just femaleVoice ) ->
            Just femaleVoice

        ( False, _, Just femaleVoice ) ->
            Just femaleVoice

        ( False, Just maleVoice, Nothing ) ->
            Just maleVoice

        ( _, Nothing, Nothing ) ->
            voice.default


isMale : String -> Bool
isMale =
    String.split " "
        >> List.reverse
        >> List.head
        >> Maybe.map ((==) "Male")
        >> Maybe.withDefault False


getVoiceFor : String -> ( String, String ) -> Maybe Voice
getVoiceFor voice ( langOld, langNew ) =
    if langOld == langNew then
        -- Nothing has changed
        Just
            { translated = True
            , lang = langOld
            , name = voice
            }

    else if getLang voice == Just langOld then
        -- the old voice needs to be translated too
        voice
            |> isMale
            |> getVoiceFromLang langNew
            |> Maybe.map (Voice True langNew)

    else
        -- the voice
        Just
            { translated = False
            , lang = langOld
            , name = voice
            }
