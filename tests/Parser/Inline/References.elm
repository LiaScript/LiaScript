module Parser.Inline.References exposing
    ( autolink_Suite
    , escapedUrl_Suite
    , image_Suite
    , image_fuzz_Suite
    , link_Suite
    , link_fuzz_Suite
    , mail_Suite
    , mail_fuzz_Suite
    , relativeUrl_Suite
    , searchIndex_Suite
    , title_Suite
    )

import Expect
import Lia.Markdown.Inline.Types exposing (Inline(..), Reference(..))
import LiaFuzz exposing (email, httpUrl, words)
import Parser.Inline.Fixtures exposing (chars, image, link, mail, parse, toTests)
import Test exposing (Test, describe, fuzz2)


link_Suite : Test
link_Suite =
    describe "generating links" <|
        toTests
            [ ( "[some text](http://example.com)", link "some text" "http://example.com" )
            ]


link_fuzz_Suite : Test
link_fuzz_Suite =
    describe "generating links from arbitrary text and URLs" <|
        [ fuzz2 words httpUrl "wrapped in [...](...)" <|
            {- [example text](https://example.com) -} \text url -> parse ("[" ++ text ++ "](" ++ url ++ ")") |> Expect.equal [ link text url ]
        ]


image_Suite : Test
image_Suite =
    describe "generating images" <|
        toTests
            [ ( "![alt text](http://example.com/img.png)", image "alt text" "http://example.com/img.png" )
            ]


image_fuzz_Suite : Test
image_fuzz_Suite =
    describe "generating images from arbitrary alt text and URLs" <|
        [ fuzz2 words httpUrl "wrapped in ![...](...)" <|
            {- ![example alt text](https://example.com/image.png) -} \alt url -> parse ("![" ++ alt ++ "](" ++ url ++ ")") |> Expect.equal [ image alt url ]
        ]


mail_Suite : Test
mail_Suite =
    describe "generating mail links" <|
        toTests
            [ ( "[mail me](mailto:test@example.com)", mail "mail me" "mailto:test@example.com" )
            ]


mail_fuzz_Suite : Test
mail_fuzz_Suite =
    describe "generating mail links from arbitrary text and addresses" <|
        [ fuzz2 words email "wrapped in [...](mailto:...)" <|
            \text address ->
                {- [mail me](mailto:test@example.com) -}
                parse ("[" ++ text ++ "](mailto:" ++ address ++ ")")
                    |> Expect.equal [ mail text ("mailto:" ++ address) ]
        ]


title_Suite : Test
title_Suite =
    describe "generating references with titles" <|
        toTests
            [ ( "[some text](http://example.com \"a title\")"
              , Ref (Link [ chars "some text" ] "http://example.com" (Just [ chars "a title" ])) []
              )
            , ( "![alt text](http://example.com/img.png \"an image\")"
              , Ref (Image [ chars "alt text" ] "http://example.com/img.png" (Just [ chars "an image" ])) []
              )
            , ( "[mail me](mailto:test@example.com \"contact\")"
              , Ref (Mail [ chars "mail me" ] "mailto:test@example.com" (Just [ chars "contact" ])) []
              )
            ]


autolink_Suite : Test
autolink_Suite =
    describe "auto-linking bare URLs" <|
        toTests
            [ ( "http://example.com", link "http://example.com" "http://example.com" )
            , ( "https://example.com/path?a=1", link "https://example.com/path?a=1" "https://example.com/path?a=1" )
            , ( "<http://example.com>", link "http://example.com" "http://example.com" )
            ]


searchIndex_Suite : Test
searchIndex_Suite =
    describe "generating internal search-index links" <|
        toTests
            [ ( "[some text](#some-search-term)", link "some text" "#some-search-term" )
            ]


escapedUrl_Suite : Test
escapedUrl_Suite =
    describe "unescaping parentheses within reference URLs" <|
        toTests
            [ ( "[text](http://example.com/page\\(1\\))"
              , link "text" "http://example.com/page(1)"
              )
            ]


relativeUrl_Suite : Test
relativeUrl_Suite =
    describe "relative URLs pass through unchanged when no base/appendix is configured" <|
        toTests
            [ ( "[text](/path/to/page)", link "text" "/path/to/page" )
            ]
