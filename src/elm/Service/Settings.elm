module Service.Settings exposing (..)

import Json.Encode as JE
import Service.Event as Event exposing (Event)


{-| Perform a reset of the current settings
-}
reset : Event
reset =
    event "reset" JE.null


update : Maybe String -> JE.Value -> Event
update customStyle config =
    [ ( "custom"
      , customStyle
            |> Maybe.map JE.string
            |> Maybe.withDefault JE.null
      )
    , ( "config", config )
    ]
        |> JE.object
        |> event "update"


event : String -> JE.Value -> Event
event cmd param =
    { cmd = cmd, param = param }
        |> Event.init "settings"
