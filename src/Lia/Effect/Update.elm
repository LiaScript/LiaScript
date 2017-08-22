module Lia.Effect.Update exposing (next, previous, update)

import Lia.Effect.Model exposing (Model)


type Msg
    = Next
    | Previous


update : Msg -> Model -> ( Model, Bool )
update msg model =
    case msg of
        Next ->
            if model.visible == model.effects then
                ( model, True )
            else
                ( { model | visible = model.visible + 1 }, False )

        Previous ->
            if model.visible == 0 then
                ( model, True )
            else
                ( { model | visible = model.visible - 1 }, False )


next : Model -> ( Model, Bool )
next =
    update Next


previous : Model -> ( Model, Bool )
previous =
    update Previous
