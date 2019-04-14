module Lia.Markdown.Inline.Tube exposing (tube)

import Regex


type alias Tube =
    { embed : String -> String
    , pattern : Regex.Regex
    }


tube_list : List Tube
tube_list =
    [ { embed = \w -> "https://www.youtube.com/embed/" ++ w
      , pattern = regex youtube
      }
    , { embed = \w -> "https://player.vimeo.com/video/" ++ w
      , pattern = regex vimeo
      }
    , { embed = \w -> "https://www.teachertube.com/embed/video/" ++ w
      , pattern = regex teachertube
      }
    ]


tube : String -> ( Bool, String )
tube =
    tube_ tube_list


tube_ : List Tube -> String -> ( Bool, String )
tube_ patterns url =
    case patterns of
        t :: ts ->
            case check t.pattern url of
                Just str ->
                    ( True, t.embed str )

                _ ->
                    tube_ ts url

        [] ->
            ( False, url )


regex : String -> Regex.Regex
regex pattern =
    pattern
        |> Regex.fromString
        |> Maybe.withDefault Regex.never


check : Regex.Regex -> String -> Maybe String
check pattern url =
    case Regex.findAtMost 1 pattern url of
        [ match ] ->
            match.submatches
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
