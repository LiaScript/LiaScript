module Lia.Markdown.Effect.Types exposing
    ( Class(..)
    , Effect
    , class
    , empty
    , init
    , isIn
    )


type alias Effect body =
    { content : List body
    , playback : Bool
    , begin : Int
    , end : Maybe Int
    , voice : String
    , id : Int
    }


init : String -> Effect body
init voice =
    { playback = False
    , begin = -1
    , end = Nothing
    , content = []
    , voice = voice
    , id = -1
    }


isIn : Maybe Int -> Effect x -> Bool
isIn id effect =
    Maybe.map (isIn_ effect) id
        |> Maybe.withDefault True


isIn_ : Effect x -> Int -> Bool
isIn_ effect id =
    case effect.end of
        Nothing ->
            effect.begin <= id

        Just end ->
            (effect.begin <= id) && (end > id)


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
