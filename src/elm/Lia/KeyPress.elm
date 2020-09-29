module Lia.KeyPress exposing (KeyPress(..), decoder, preventDefaultOn)

import Json.Decode as JD
import Lia.Utils as Utils


type KeyPress
    = ArrowLeft
    | ArrowRight
    | ArrowDown
    | ArrowUp


decoder : JD.Decoder KeyPress
decoder =
    JD.field "key" JD.string
        |> JD.andThen match


match : String -> JD.Decoder KeyPress
match key =
    case key of
        "ArrowLeft" ->
            JD.succeed ArrowLeft

        "ArrowRight" ->
            JD.succeed ArrowRight

        _ ->
            JD.fail ""


preventDefaultOn =
    decoder
        |> JD.map (\key -> ( key, True ))
        >> Utils.blockKeydown
