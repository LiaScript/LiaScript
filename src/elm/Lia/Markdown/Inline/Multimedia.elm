module Lia.Markdown.Inline.Multimedia exposing (audio, movie, search)

import Regex


type alias Stream =
    { embed : String -> String
    , pattern : String
    }


movie : String -> ( Bool, String )
movie =
    [ { embed = \w -> "https://www.youtube.com/embed/" ++ w
      , pattern = "(?:http(?:s)?://)?(?:www\\.)?(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:v|vi|user)/))([^\\?&\"'<> #]+)"
      }
    , { embed = \w -> "https://player.vimeo.com/video/" ++ w
      , pattern = "(?:http(?:s)?://)?(?:www\\.)?(?:player.)?(?:vimeo\\.com).*?(\\d+)"
      }
    , { embed = \w -> "https://www.teachertube.com/embed/video/" ++ w
      , pattern = "(?:http(?:s)?://)?(?:www\\.)?(?:teachertube\\.com).*?(\\d+)"
      }
    ]
        |> search


audio : String -> ( Bool, String )
audio =
    [ { embed = \w -> "https://w.soundcloud.com/player/?url=https://soundcloud.com/" ++ w
      , pattern = "https?:\\/\\/(?:w\\.|www\\.|)(?:soundcloud\\.com\\/)(?:(?:player\\/\\?url=https\\%3A\\/\\/api.soundcloud.com\\/tracks\\/)|)(((\\w|-)[^A-z]{7})|([A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*(?!\\/sets(?:\\/|$))(?:\\/[A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*){1,2}))"
      }

    -- , { embed = \w -> "http://open.spotify.com/track/" ++ w
    --   , pattern = regex "https?:\\/\\/(?:embed\\.|open\\.)(?:spotify\\.com\\/)(?:track\\/|\\?uri=spotify:track:)((\\w|-){22})\n"
    --   }
    ]
        |> search


search : List Stream -> String -> ( Bool, String )
search patterns url =
    case patterns of
        t :: ts ->
            case check t.pattern url of
                Just str ->
                    ( True, t.embed str )

                _ ->
                    search ts url

        [] ->
            ( False, url )


regex : String -> Regex.Regex
regex pattern =
    pattern
        |> Regex.fromString
        |> Maybe.withDefault Regex.never


check : String -> String -> Maybe String
check pattern url =
    case Regex.findAtMost 1 (regex pattern) url of
        [ match ] ->
            match.submatches
                |> List.head
                |> Maybe.withDefault Nothing

        _ ->
            Nothing
