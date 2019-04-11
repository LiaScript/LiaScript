module Lia.Markdown.Inline.Tube exposing (inTube, tube)

import Regex


type alias Tube =
    { base : String
    , embed : String -> String
    , pattern : Regex.Regex
    }


tube_list : List Tube
tube_list =
    [ { base = "www.youtube"
      , embed = \w -> "https://www.youtube.com/embed/" ++ w
      , pattern = regex youtube
      }
    , { base = "vimeo.com"
      , embed = \w -> "https://player.vimeo.com/video/" ++ w
      , pattern = regex vimeo
      }
    , { base = "www.teachertube"
      , embed = \w -> "https://www.teachertube.com/embed/video/" ++ w
      , pattern = regex teachertube
      }
    ]


inTube : String -> Bool
inTube url =
    List.any (.base >> contains url) tube_list


contains : String -> String -> Bool
contains url base =
    String.contains base url


tube : String -> String
tube =
    tube_ tube_list


tube_ : List Tube -> String -> String
tube_ patterns url =
    case patterns of
        t :: ts ->
            case check t.pattern url of
                Just str ->
                    t.embed str

                _ ->
                    tube_ ts url

        [] ->
            url


regex : String -> Regex.Regex
regex pattern =
    pattern
        |> Regex.fromString
        |> Maybe.withDefault Regex.never


check : Regex.Regex -> String -> Maybe String
check pattern url =
    case Regex.findAtMost 1 pattern url of
        [ { index, match, number, submatches } ] ->
            submatches
                |> List.head
                |> Maybe.withDefault Nothing

        _ ->
            Nothing


teachertube : String
teachertube =
    "(?:http(?:s)?://)?(?:www\\.)?(?:teachertube\\.com).*?(\\d+)"


vimeo : String
vimeo =
    "(?:http(?:s)?://)?(?:www\\.)?(?:player.)?(?:vimeo\\.com).*?(\\d+)"


youtube : String
youtube =
    "(?:http(?:s)?://)?(?:www\\.)?(?:youtu\\.be/|youtube\\.com/(?:(?:watch)?\\?(?:.*&)?v(?:i)?=|(?:v|vi|user)/))([^\\?&\"'<> #]+)"
