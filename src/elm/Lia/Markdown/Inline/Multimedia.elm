module Lia.Markdown.Inline.Multimedia exposing (audio, movie)

import Lia.Parser.PatReplace exposing (replace, root)


movie : String -> ( Bool, String )
movie =
    [ { by =
            \url w ->
                "https://www.youtube.com/embed/"
                    ++ w
                    ++ preserve url [ "autoplay=", "start=", "end=", "mute=" ]
      , pattern = root "(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:v|vi|user)/))([^\\?&\"'<> #]+)"
      }
    , { by = \url w -> "https://player.vimeo.com/video/" ++ w ++ preserve url [ "autoplay=", "muted=", "loop" ]
      , pattern = root "(?:player.)?(?:vimeo\\.com).*?(\\d+)"
      }
    , { by = \_ w -> "https://www.dailymotion.com/embed/video/" ++ w
      , pattern = root "(?:dailymotion\\.com(?:/embed)?/video/)(.+)"
      }
    , { by = \_ w -> "https://peertube.tv/videos/embed/" ++ w
      , pattern = root "(?:peertube\\.tv/videos/watch/)(.+)"
      }
    , { by = \_ w -> "https://www.teachertube.com/embed/video/" ++ w
      , pattern = root "(?:teachertube\\.com).*?(\\d+.*)"
      }
    ]
        |> replace


audio : String -> ( Bool, String )
audio =
    [ { by = \_ w -> "https://w.soundcloud.com/player/?url=https://soundcloud.com/" ++ w
      , pattern = "https?:\\/\\/(?:w\\.|www\\.|)(?:soundcloud\\.com\\/)(?:(?:player\\/\\?url=https\\%3A\\/\\/api.soundcloud.com\\/tracks\\/)|)(((\\w|-)[^A-z]{7})|([A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*(?!\\/sets(?:\\/|$))(?:\\/[A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*){1,2}))"
      }
    , { by =
            \url w ->
                "https://www.youtube.com/embed/"
                    ++ w
                    ++ preserve url [ "autoplay=", "start=", "end=", "mute=" ]
      , pattern = root "music\\.(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:v|vi|user)/))([^\\?&\"'<> #]+)"
      }

    -- , { embed = \w -> "http://open.spotify.com/track/" ++ w
    --   , pattern = regex "https?:\\/\\/(?:embed\\.|open\\.)(?:spotify\\.com\\/)(?:track\\/|\\?uri=spotify:track:)((\\w|-){22})\n"
    --   }
    ]
        |> replace


preserve : String -> List String -> String
preserve url =
    let
        params =
            url
                |> String.split "?"
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.map (String.split "#")
                |> Maybe.andThen List.head
                |> Maybe.map (String.split "&")
                |> Maybe.withDefault []
    in
    List.filterMap
        (\w ->
            case List.filter (String.startsWith w) params of
                [] ->
                    Nothing

                p :: _ ->
                    Just p
        )
        >> List.intersperse "&"
        >> String.concat
        >> (++) "?"
        >> fragment url


fragment : String -> String -> String
fragment url params =
    params
        ++ (url
                |> String.split "#"
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.map ((++) "#")
                |> Maybe.withDefault ""
           )
