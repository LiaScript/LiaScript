module Lia.Sync.Via exposing
    ( Backend(..)
    , fromString
    , toString
    )


type Backend
    = Beaker
    | Matrix


toString : Backend -> String
toString via =
    case via of
        Beaker ->
            "Beaker"

        Matrix ->
            "Matrix"


fromString : String -> Maybe Backend
fromString via =
    case String.toLower via of
        "beaker" ->
            Just Beaker

        "matrix" ->
            Just Matrix

        _ ->
            Nothing
