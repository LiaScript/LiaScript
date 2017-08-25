module Main exposing (..)

import Html exposing (Html)
import Lia
import Readme


main : Program Never Lia.Model Lia.Msg
main =
    Html.program
        { update = Lia.update
        , init = ( Lia.init_plain Readme.text, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , view = Lia.view
        }
