module Library.SplitPane.Bound exposing (Bound, Bounded, getValue, putValue, updateValue, putBound, createBound, createBounded)

{-| This module defines a value that is between two other values.

@docs Bound, Bounded, getValue, putValue, updateValue, putBound, createBound, createBounded

-}


{-| Type that defines a border of values
-}
type alias Bound a =
    ( a, a )


{-| Type that defines a value that is within a border of two other values
-}
type alias Bounded a =
    ( a, Bound a )


{-| Create a new bounded value.
-}
getValue : Bounded comparable -> comparable
getValue value =
    Tuple.first value


{-| Create a new bounded value.
-}
createBounded : comparable -> Bound comparable -> Bounded comparable
createBounded value bound =
    putValue ( value, bound ) value


{-| Change the value that is bounded.
-}
putValue : Bounded comparable -> comparable -> Bounded comparable
putValue ( _, bound ) value =
    ( boundTo bound value, bound )


{-| Update the value that is bounded.
-}
updateValue : (comparable -> comparable) -> Bounded comparable -> Bounded comparable
updateValue f ( value, bound ) =
    ( boundTo bound (f value), bound )


{-| Change the bound of the bounded value.
-}
putBound : Bounded comparable -> Bound comparable -> Bounded comparable
putBound ( value, _ ) bound =
    ( value, bound )


{-| Create a new bound that can be used to restrict a value.
-}
createBound : comparable -> comparable -> Bound comparable
createBound a b =
    ( min a b, max a b )


boundTo : Bound comparable -> comparable -> comparable
boundTo ( a, b ) =
    min b << max a
