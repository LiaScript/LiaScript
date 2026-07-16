module Parser.Block.Gallery exposing
    ( gallery_Suite
    , notAGallery_Suite
    )

import Lia.Markdown.Types exposing (Block(..))
import Parser.Block.Fixtures exposing (toTests)
import Parser.Inline.Fixtures exposing (image)
import Test exposing (Test, describe)


gallery_Suite : Test
gallery_Suite =
    describe "generating media galleries (two or more media references)" <|
        toTests
            [ ( "![alt1](http://example.com/1.png)\n![alt2](http://example.com/2.png)\n"
              , Gallery []
                    { media =
                        [ image "alt1" "http://example.com/1.png"
                        , image "alt2" "http://example.com/2.png"
                        ]
                    , id = 0
                    }
              )
            , ( "![alt1](http://example.com/1.png)![alt2](http://example.com/2.png)\n"
              , Gallery []
                    { media =
                        [ image "alt1" "http://example.com/1.png"
                        , image "alt2" "http://example.com/2.png"
                        ]
                    , id = 0
                    }
              )
            ]


{-| A single media reference alone is just a regular paragraph containing a
media reference, not a gallery - the parser explicitly requires more than one.
-}
notAGallery_Suite : Test
notAGallery_Suite =
    describe "a single media reference does not become a gallery" <|
        toTests
            [ ( "![alt1](http://example.com/1.png)\n"
              , Paragraph [] [ image "alt1" "http://example.com/1.png" ]
              )
            ]
