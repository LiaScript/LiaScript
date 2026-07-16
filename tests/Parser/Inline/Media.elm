module Parser.Inline.Media exposing
    ( audio_Suite
    , audio_fuzz_Suite
    , audio_platformRewrite_Suite
    , embed_Suite
    , embed_fuzz_Suite
    , movie_Suite
    , movie_fuzz_Suite
    , movie_platformRewrite_Suite
    , preview_Suite
    , qr_Suite
    )

import Expect
import Lia.Markdown.Inline.Types exposing (Inline(..), Reference(..))
import LiaFuzz exposing (httpUrl, words)
import Parser.Inline.Fixtures exposing (audio, chars, embed, movie, parse, previewLia, previewLink, qr, toTests)
import Test exposing (Test, describe, fuzz2, test)


audio_Suite : Test
audio_Suite =
    describe "generating audio references" <|
        toTests
            [ ( "?[a title](http://example.com/audio.mp3)", audio "a title" "http://example.com/audio.mp3" )
            ]


audio_fuzz_Suite : Test
audio_fuzz_Suite =
    describe "generating audio references from arbitrary titles and URLs" <|
        [ fuzz2 words httpUrl "wrapped in ?[...](...)" <|
            \title url -> parse ("?[" ++ title ++ "](" ++ url ++ ")") |> Expect.equal [ audio title url ]
        ]


movie_platformRewrite_Suite : Test
movie_platformRewrite_Suite =
    describe "rewriting known video-platform URLs into their embed player"
        [ test "a YouTube watch URL is rewritten to the youtube-nocookie embed URL, dropping the video ID params" <|
            \_ ->
                parse "!?[a title](https://www.youtube.com/watch?v=dQw4w9WgXcQ)"
                    |> Expect.equal
                        [ Ref
                            (Movie [ chars "a title" ]
                                ( True, "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ" )
                                Nothing
                            )
                            []
                        ]
        ]


movie_Suite : Test
movie_Suite =
    describe "generating movie references" <|
        toTests
            [ ( "!?[a title](http://example.com/video.mp4)", movie "a title" "http://example.com/video.mp4" )
            ]


movie_fuzz_Suite : Test
movie_fuzz_Suite =
    describe "generating movie references from arbitrary titles and URLs" <|
        [ fuzz2 words httpUrl "wrapped in !?[...](...)" <|
            \title url -> parse ("!?[" ++ title ++ "](" ++ url ++ ")") |> Expect.equal [ movie title url ]
        ]


audio_platformRewrite_Suite : Test
audio_platformRewrite_Suite =
    describe "auto-converting known embeddable-audio-platform URLs from Audio to Embed"
        [ test "a SoundCloud URL becomes an Embed reference instead of Audio" <|
            \_ ->
                parse "?[a title](https://soundcloud.com/artist/track)"
                    |> Expect.equal [ embed "a title" "https://soundcloud.com/artist/track" ]
        , test "a Spotify URL becomes an Embed reference instead of Audio" <|
            \_ ->
                parse "?[a title](https://open.spotify.com/track/123)"
                    |> Expect.equal [ embed "a title" "https://open.spotify.com/track/123" ]
        ]


embed_Suite : Test
embed_Suite =
    describe "generating embed references" <|
        toTests
            [ ( "??[a title](http://example.com/embed)", embed "a title" "http://example.com/embed" )
            ]


embed_fuzz_Suite : Test
embed_fuzz_Suite =
    describe "generating embed references from arbitrary titles and URLs" <|
        [ fuzz2 words httpUrl "wrapped in ??[...](...)" <|
            \title url -> parse ("??[" ++ title ++ "](" ++ url ++ ")") |> Expect.equal [ embed title url ]
        ]


preview_Suite : Test
preview_Suite =
    describe "generating preview references" <|
        toTests
            [ ( "[preview-lia](some-course-id)", previewLia "some-course-id" )
            , ( "[preview-link](http://example.com)", previewLink "http://example.com" )
            ]


qr_Suite : Test
qr_Suite =
    describe "generating QR-code references" <|
        toTests
            [ ( "[qr-code](http://example.com)", qr "http://example.com" )
            ]
