module LiaFuzz exposing (email, fuzzRegex, httpUrl, slug, word, words)

import Fuzz exposing (Fuzzer)
import Random.Regex exposing (Encoding(..))


fuzzRegex : String -> Fuzzer String
fuzzRegex str =
    case Random.Regex.generate ASCII 30 str of
        Ok re ->
            Fuzz.fromGenerator re

        Err info ->
            Fuzz.invalid ("not a valid regular expression (" ++ str ++ ") => " ++ info)


{-| A single word, e.g. for content that must not contain spaces.
-}
word : Fuzzer String
word =
    fuzzRegex "[A-Za-z]+"


{-| Multi-word text, e.g. "hello there world", for content wrapped by inline
markup such as emphasis or quotes.
-}
words : Fuzzer String
words =
    fuzzRegex "[A-Za-z]+( [A-Za-z]+){0,4}"


{-| A hyphenated, slug-like key, e.g. "some-longer-key", for footnote marks.
-}
slug : Fuzzer String
slug =
    fuzzRegex "[A-Za-z0-9]+(-[A-Za-z0-9]+){0,3}"


{-| A simple absolute URL, e.g. "https://example.com/path".
-}
httpUrl : Fuzzer String
httpUrl =
    fuzzRegex "https?://[a-z]{3,8}\\.(com|org|net)(/[a-z]{2,8}){0,3}"


{-| A simple email address, e.g. "test@example.com".
-}
email : Fuzzer String
email =
    fuzzRegex "[a-z]{3,8}@[a-z]{3,8}\\.(com|org|net)"
