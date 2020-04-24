module Lia.Markdown.Effect.Types exposing
    ( Class(..)
    , Effect
    , class
    , empty
    , init
    )


type alias Effect body =
    { playback : Bool
    , begin : Int
    , end : Int
    , content : List body
    , voice : String
    , id : Int
    }


init : String -> Effect body
init voice =
    { playback = False
    , begin = -1
    , end = 999999
    , content = []
    , voice = voice
    , id = -1
    }


empty : Effect body -> Bool
empty e =
    not e.playback && e.begin < 0


type Class
    = Animation
    | PlayBack
    | PlayBackAnimation


class : Effect body -> Class
class effect =
    if effect.playback then
        if effect.begin < 0 then
            PlayBack

        else
            PlayBackAnimation

    else
        Animation
