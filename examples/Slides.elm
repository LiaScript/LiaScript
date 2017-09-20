module Main exposing (..)

import Html exposing (Html)
import Lia
import Readme


main : Program Flags Lia.Model Lia.Msg
main =
    Html.programWithFlags
        { update = Lia.update
        , init = init
        , subscriptions = \_ -> Sub.none
        , view = Lia.view
        }


type alias Flags =
    {
    }



-- INIT


init : Flags -> ( Lia.Model, Cmd msg )
init flags =
    ( Lia.parse <| Lia.set_script (Lia.init_slides Readme.text) Readme.text, Cmd.none )



-- MODEL
-- UPDATE
-- VIEW
