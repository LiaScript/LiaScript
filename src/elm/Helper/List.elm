module Helper.List exposing (..)

{-| Check if a list has exactly one element -
-}


isSingleton : List a -> Bool
isSingleton list =
    case list of
        [ _ ] ->
            True

        _ ->
            False


{-| Check if a list is empty or has exactly one element
-}
isEmptyOrSingleton : List a -> Bool
isEmptyOrSingleton list =
    case list of
        [] ->
            True

        [ _ ] ->
            True

        _ ->
            False
