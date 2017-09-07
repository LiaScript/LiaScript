module Main exposing (..)

import Html exposing (Html)
import Lia


main : Program Flags Lia.Model Lia.Msg
main =
    Html.programWithFlags
        { update = Lia.update
        , init = ( Lia.parse <| Lia.set_script (Lia.init_slides Readme.text) Readme.text, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , view = Lia.view
        }


type alias Flags =
    { script : String
    }



-- INIT


init : Flags -> ( Lia.Model, Cmd msg )
init flags =
    ( Lia.parse <| Lia.set_script (Lia.init_slides flags.script) flags.script, Cmd.none )



-- MODEL
-- UPDATE
-- VIEW
