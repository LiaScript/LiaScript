module Lia.Markdown.Inline.Multimedia exposing
    ( audio
    , movie
    , reverseMovie
    , website
    )

import Lia.Parser.PatReplace exposing (replace)
import Lia.Parser.UrlPattern.Generic exposing (root)


website =
    { youtube = "https://www.youtube.com/embed/"
    }


{-| <http://embedcodedailymotion.blogspot.com/2016/05/dailymotion-embed-generator-tdborder.html>

<https://developers.google.com/youtube/player_parameters>

<https://vimeo.zendesk.com/hc/en-us/articles/360001494447-Using-Player-Parameters>

-}
movie : String -> ( Bool, String )
movie =
    [ { by =
            \url w ->
                website.youtube
                    ++ w
                    ++ preserve url youTubeRules
      , pattern = root "(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:v|vi|user)/))([^\\?&\"'<> #]+)"
      }
    , { by =
            \url w ->
                "https://player.vimeo.com/video/"
                    ++ w
                    ++ preserve url vimeoRules
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
    , { by =
            \url w ->
                "https://video.tu-freiberg.de/media/embed?key="
                    ++ w
                    ++ preserve url tuFreibergRules
      , pattern = root "(?:video\\.tu\\-freiberg\\.de/video/[^/]+/)(.+)"
      }
    ]
        |> replace


{-| Reverse transformation of embed URLs back to original website URLs.

    reverseMovie "https://www.youtube.com/embed/dQw4w9WgXcQ"
        == Just "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

    reverseMovie "https://player.vimeo.com/video/123456"
        == Just "https://vimeo.com/123456"

    reverseMovie "https://example.com/unknown"
        == Nothing

-}
reverseMovie : String -> Maybe String
reverseMovie url =
    case
        [ { by =
                \u w ->
                    "https://www.youtube.com/watch?v="
                        ++ w
                        ++ reversePreserve u
          , pattern = root "(?:www\\.)?youtube\\.com/embed/([^\\?&\"'<> #]+)"
          }
        , { by =
                \u w ->
                    "https://vimeo.com/"
                        ++ w
                        ++ reversePreserve u
          , pattern = root "player\\.vimeo\\.com/video/(\\d+)"
          }
        , { by =
                \u w ->
                    "https://www.dailymotion.com/video/"
                        ++ w
                        ++ reversePreserve u
          , pattern = root "(?:www\\.)?dailymotion\\.com/embed/video/(.+)"
          }
        , { by = \_ w -> "https://peertube.tv/videos/watch/" ++ w
          , pattern = root "peertube\\.tv/videos/embed/(.+)"
          }
        , { by =
                \u w ->
                    "https://www.teachertube.com/video/"
                        ++ w
                        ++ reversePreserve u
          , pattern = root "(?:www\\.)?teachertube\\.com/embed/video/(\\d+.*)"
          }
        ]
            |> replace
            |> (\f -> f url)
    of
        ( True, result ) ->
            Just result

        ( False, _ ) ->
            Nothing


{-| Preserve query parameters and fragment from the original URL for reverse transformation.
-}
reversePreserve : String -> String
reversePreserve url =
    let
        params =
            url
                |> String.split "?"
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.map (String.split "#")
                |> Maybe.andThen List.head
                |> Maybe.withDefault ""

        frag =
            url
                |> String.split "#"
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.map ((++) "#")
                |> Maybe.withDefault ""
    in
    (if String.isEmpty params then
        ""

     else
        "&" ++ params
    )
        ++ frag


audio : String -> ( Bool, String )
audio =
    [ { by =
            \_ w ->
                let
                    link =
                        "https://widget.deezer.com/widget/dark/" ++ w
                in
                if String.startsWith "artist" w then
                    link ++ "/top_tracks"

                else
                    link
      , pattern = "https://(?:www\\.|widget\\.)?deezer\\.com/(?:.*)/(.*/.*)\\??"
      }
    , { by =
            \url w ->
                "https://www.youtube.com/embed/"
                    ++ w
                    ++ preserve url youTubeRules
      , pattern = root "music\\.(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:v|vi|user)/))([^\\?&\"'<> #]+)"
      }
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
        >> String.join "&"
        >> (++) "?"
        >> fragment url
        >> (\parameters ->
                case parameters of
                    "?" ->
                        ""

                    _ ->
                        parameters
           )


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


{-| <https://developers.google.com/youtube/player_parameters>
-}
youTubeRules : List String
youTubeRules =
    [ "autoplay"
    , "cc_lang_pref"
    , "color"
    , "disablekb"
    , "enablejsapi"
    , "end"
    , "fs"
    , "hl"
    , "iv_load_policy"
    , "list"
    , "listType"
    , "loop"
    , "modestbranding"
    , "mute"
    , "origin"
    , "playlist"
    , "playsinline"
    , "rel"
    , "start"
    , "widget_referrer"
    ]


{-| <https://vimeo.zendesk.com/hc/en-us/articles/360001494447-Using-Player-Parameters>
-}
vimeoRules : List String
vimeoRules =
    [ "autopause"
    , "autoplay"
    , "background"
    , "byline"
    , "color"
    , "controls"
    , "dnt"
    , "keyboard"
    , "loop"
    , "muted"
    , "pip"
    , "playsinline"
    , "portrait"
    , "quality"
    , "speed"
    , "texttrack"
    , "title"
    , "transparent"
    ]


tuFreibergRules : List String
tuFreibergRules =
    [ "key"
    , "width"
    , "height"
    , "autoplay"
    , "autolightsoff"
    , "loop"
    , "chapters"
    , "related"
    , "responsive"
    , "t"
    ]
