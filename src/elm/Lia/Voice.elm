module Lia.Voice exposing (Voice, getVoiceFor)


type alias Voice =
    { lang : String
    , female : Maybe String
    , male : Maybe String
    }


voices : List Voice
voices =
    [ toVoice "US English" "en" True True
    , toVoice "UK English" "en" True True
    , toVoice "Australian" "en" True True
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
    , toVoice "Czech" "cz" True True
    , toVoice "Danish" "da" True True
    , toVoice "Deutsch" "de" True True
    , toVoice "Dutch" "nl" True True
    , toVoice "Esperanto" "eo" False True
    , toVoice "Estonian" "et" False True
    , toVoice "Filipino" "ph" True False
    , toVoice "Finnish" "fi" True True
    , toVoice "French" "fr" True True
    , toVoice "French Canadian" "fr" True True
    , toVoice "Greek" "el" True True
    , toVoice "Hindi" "hi" True True
    , toVoice "Hungarian" "hu" True True
    , toVoice "Icelandic" "is" False True
    , toVoice "Indonesian" "id" True True
    , toVoice "Italian" "it" True True
    , toVoice "Japanese" "ja" True True
    , toVoice "Korean" "ko" True True
    , toVoice "Latin" "la" True True
    , toVoice "Latvian" "lv" False True
    , toVoice "Macedonian" "mk" False True
    , toVoice "Moldavian" "mo" True True
    , toVoice "Montenegrin" "me" False True
    , toVoice "Nepali" "ne" True True
    , toVoice "Norwegian" "no" True True
    , toVoice "Polish" "pl" True True
    , toVoice "Portuguese" "pl" True True
    , toVoice "Brazilian Portuguese" "pt" False True
    , toVoice "Romanian" "ro" True True
    , toVoice "Russian" "ru" True True
    , toVoice "Serbian" "sr" False True
    , toVoice "Serbo-Croatian" "sh" False True
    , toVoice "Sinhala" "si" True True
    , toVoice "Slovak" "sk" True True
    , toVoice "Spanish" "es" True True
    , toVoice "Spanish Latin American" "es" True True
    , toVoice "Swahili" "si" False True
    , toVoice "Swedish" "sv" True True
    , toVoice "Tamil" "ta" True True
    , toVoice "Thai" "th" True True
    , toVoice "Turkish" "tr" True True
    , toVoice "Ukrainian" "uk" True False
    , toVoice "Vietnamese" "vi" True True
    , toVoice "Welsh" "cy" False True
    ]


toVoice : String -> String -> Bool -> Bool -> Voice
toVoice name lang female male =
    Voice lang
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


getLangFromVoice : String -> Maybe String
getLangFromVoice voice =
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


getVoice : Bool -> Voice -> Maybe String
getVoice male voice =
    if male && voice.male /= Nothing then
        voice.male

    else if male && voice.female /= Nothing then
        voice.female

    else if not male && voice.female /= Nothing then
        voice.female

    else
        voice.male


isMale : String -> Bool
isMale =
    String.split " "
        >> List.reverse
        >> List.head
        >> Maybe.map ((==) "Male")
        >> Maybe.withDefault False


getVoiceFor : String -> ( String, String ) -> Maybe String
getVoiceFor voice ( langOld, langNew ) =
    if langOld == langNew then
        -- Nothing has changed
        Just voice

    else if getLangFromVoice voice == Just langOld then
        -- the old voice needs to be translated too
        getVoiceFromLang langNew (isMale voice)

    else
        -- the voice
        Just voice
