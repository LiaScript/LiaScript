module I18n.Quotation exposing (quotation)

{-| Single and double quotation marks for different languages which are defined by their language code.
As source for this list the following Wikipedia article was used:

<https://en.wikipedia.org/wiki/Quotation_mark>

-}


quotation :
    String
    ->
        { double : ( String, String ) -- double quotation marks
        , single : ( String, String ) -- single quotation marks
        }
quotation languageCode =
    { double = two languageCode
    , single = one languageCode
    }



-- The values of the arrays were sorted by ChatGPT, starting with the languages with the most speakers.


double1 =
    -- “…”
    [ "en" -- English
    , "hi" -- Hindi
    , "id" -- Indonesian
    , "pt" -- Portuguese
    , "ur" -- Urdu
    , "vi" -- Vietnamese
    , "tr" -- Turkish
    , "ta" -- Tamil
    , "th" -- Thai
    , "ko" -- Korean
    , "fil" -- Filipino
    , "az" -- Azerbaijani
    , "af" -- Afrikaans
    , "lo" -- Lao
    , "lv" -- Latvian
    , "mt" -- Maltese
    , "ia" -- Interlingua
    , "eo" -- Esperanto
    , "ga" -- Irish
    , "cy" -- Welsh
    , "gd" -- Scottish Gaelic
    ]


double2 =
    -- „…“
    [ "de" -- German
    , "sr" -- Serbian
    , "bg" -- Bulgarian
    , "cs" -- Czech
    , "sk" -- Slovak
    , "lt" -- Lithuanian
    , "mk" -- Macedonian
    , "sq" -- Albanian
    , "sl" -- Slovene
    , "ka" -- Georgian
    , "et" -- Estonian
    , "is" -- Icelandic
    , "sb" -- Sorbian
    ]


double3 =
    -- ”…”
    [ "sv" -- Swedish
    , "fi" -- Finnish
    , "bs" -- Bosnian
    ]


double4 =
    -- «…»
    [ "es" -- Spanish
    , "fr" -- French
    , "ar" -- Arabic
    , "ru" -- Russian
    , "fa" -- Persian
    , "uz" -- Uzbek
    , "kk" -- Kazakh
    , "am" -- Amharic
    , "uk" -- Ukrainian
    , "ps" -- Pashto
    , "hy" -- Armenian
    , "km" -- Khmer
    , "oc" -- Occitan
    , "ca" -- Catalan
    , "gl" -- Galician
    , "el" -- Greek
    , "it" -- Italian
    , "ug" -- Uyghur
    , "eu" -- Basque
    , "rm" -- Romansh
    , "ti" -- Tigrinya
    , "kaa" -- Karakalpak
    , "no" -- Norwegian
    , "io" -- Ido
    ]


double5 =
    -- „…”
    [ "pl" -- Polish
    , "nl" -- Dutch
    , "hu" -- Hungarian
    , "ro" -- Romanian
    , "hr" -- Croatian
    ]


double6 =
    -- »…«
    [ "da" -- Danish
    ]


double7 =
    -- 《…》
    [ "bo" -- Tibetan
    , "khb" -- New Tai Lue
    , "tdd" -- Tai Le
    ]


double8 =
    -- 「…」
    [ "zh" -- Chinese
    , "ja" -- Japanese
    ]


single1 =
    -- ‘…’
    [ "zh" -- Chinese (Simplified)
    , "en" -- English
    , "es" -- Spanish
    , "ru" -- Russian
    , "hi" -- Hindi
    , "id" -- Indonesian
    , "ta" -- Tamil
    , "tr" -- Turkish
    , "ur" -- Urdu
    , "no" -- Norwegian
    , "ko" -- Korean
    , "af" -- Afrikaans
    , "sq" -- Albanian
    , "fil" -- Filipino
    , "eo" -- Esperanto
    , "ga" -- Irish
    , "mt" -- Maltese
    , "ia" -- Interlingua
    , "io" -- Ido
    , "ua" -- Ukrainian
    , "cy" -- Welsh
    , "gd" -- Scottish Gaelic
    ]


single2 : List String
single2 =
    -- ‹…›
    [ "fr" -- French
    , "am" -- Amharic
    , "ti" -- Tigrinya
    , "ug" -- Uyghur
    , "rm" -- Romansh
    ]


single3 =
    -- ’…’
    [ "sv" -- Swedish
    , "fi" -- Finnish
    , "bg" -- Bulgarian
    , "hr" -- Croatian
    , "bs" -- Bosnian
    ]


single4 =
    -- ‚…‘
    [ "de" -- German
    , "cs" -- Czech
    , "sr" -- Serbian
    , "sk" -- Slovak
    , "lt" -- Lithuanian
    , "is" -- Icelandic
    , "sl" -- Slovene
    , "sb" -- Sorbian
    , "uz" -- Uzbek
    ]


single5 =
    -- ‚…’
    [ "nl" -- Dutch
    , "he" -- Hebrew
    ]


single6 =
    --〈…〉
    [ "bo" -- Tibetan
    , "khb" -- New Tai Lue
    , "tdd" -- Tai Le
    ]


one : String -> ( String, String )
one languageCode =
    if List.member languageCode single1 then
        -- (1,672.7 million)
        ( "‘", "’" )

    else if List.member languageCode single4 then
        -- (224.4 million)
        ( "‚", "‘" )

    else if List.member languageCode single2 then
        --  (109.06 million)
        ( "‹", "›" )

    else if List.member languageCode single5 then
        -- (32 million)
        ( "‚", "’" )

    else if List.member languageCode single3 then
        -- (24.9 million)
        ( "’", "’" )

    else if List.member languageCode single6 then
        -- (1.2 million (approximate))
        ( "〈", "〉" )

    else
        ( "'", "'" )


two : String -> ( String, String )
two languageCode =
    if List.member languageCode double8 then
        --  (1,043 million)
        ( "「", "」" )

    else if List.member languageCode double4 then
        --  (899.91 million)
        ( "«", "»" )

    else if List.member languageCode double1 then
        -- (729.6 million)
        ( "“", "”" )

    else if List.member languageCode double2 then
        -- (143.5 million)
        ( "„", "“" )

    else if List.member languageCode double5 then
        -- (127.5 million)
        ( "„", "”" )

    else if List.member languageCode double3 then
        -- (18.9 million)
        ( "”", "”" )

    else if List.member languageCode double7 then
        -- (1.2 million (approximate))
        ( "《", "》" )

    else if List.member languageCode double6 then
        -- (5.5 million)
        ( "»", "«" )

    else
        ( "\"", "\"" )
