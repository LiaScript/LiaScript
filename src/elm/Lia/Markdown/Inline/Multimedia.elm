module Lia.Markdown.Inline.Multimedia exposing (audio, movie)

import Lia.Parser.PatReplace exposing (replace)


movie : String -> ( Bool, String )
movie =
    [ { by = \w -> "https://www.youtube.com/embed/" ++ w
      , pattern = "(?:http(?:s)?://)?(?:www\\.)?(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:v|vi|user)/))([^\\?&\"'<> #]+)"
      }
    , { by = \w -> "https://player.vimeo.com/video/" ++ w
      , pattern = "(?:http(?:s)?://)?(?:www\\.)?(?:player.)?(?:vimeo\\.com).*?(\\d+)"
      }
    , { by = \w -> "https://www.teachertube.com/embed/video/" ++ w
      , pattern = "(?:http(?:s)?://)?(?:www\\.)?(?:teachertube\\.com).*?(\\d+)"
      }
    ]
        |> replace


audio : String -> ( Bool, String )
audio =
    [ { by = \w -> "https://w.soundcloud.com/player/?url=https://soundcloud.com/" ++ w
      , pattern = "https?:\\/\\/(?:w\\.|www\\.|)(?:soundcloud\\.com\\/)(?:(?:player\\/\\?url=https\\%3A\\/\\/api.soundcloud.com\\/tracks\\/)|)(((\\w|-)[^A-z]{7})|([A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*(?!\\/sets(?:\\/|$))(?:\\/[A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*){1,2}))"
      }

    -- , { embed = \w -> "http://open.spotify.com/track/" ++ w
    --   , pattern = regex "https?:\\/\\/(?:embed\\.|open\\.)(?:spotify\\.com\\/)(?:track\\/|\\?uri=spotify:track:)((\\w|-){22})\n"
    --   }
    ]
        |> replace
