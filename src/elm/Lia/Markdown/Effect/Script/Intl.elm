module Lia.Markdown.Effect.Script.Intl exposing
    ( Intl
    , from
    , view
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.HTML.Attributes as Params exposing (Parameters)


type alias Intl =
    Parameters


number : List String
number =
    [ "compactdisplay"
    , "currency"
    , "currencydisplay"
    , "currencysign"
    , "localematcher"
    , "maximumfractiondigits"
    , "maximumsignificantdigits"
    , "minimumfractiondigits"
    , "minimumintegerdigits"
    , "minimumsignificantdigits"
    , "notation"
    , "numberingsystem"
    , "signdisplay"
    , "localestyle"
    , "unit"
    , "unitdisplay"
    , "usegrouping"
    ]


datetime : List String
datetime =
    [ "calendar"
    , "datestyle"
    , "day"
    , "dayperiod"
    , "era"
    , "formatmatcher"
    , "fractionalseconddigits"
    , "hour"
    , "hour12"
    , "hourcycle"
    , "localematcher"
    , "minute"
    , "month"
    , "numberingsystem"
    , "second"
    , "timestyle"
    , "timezone"
    , "timezonename"
    , "weekday"
    , "year"
    ]


relativetime : List String
relativetime =
    [ "unit"
    , "localematcher"
    , "numeric"
    , "localestyle"
    ]


list : List String
list =
    [ "localematcher"
    , "type"
    , "localestyle"
    ]


pluralrules : List String
pluralrules =
    [ "localematcher"
    , "type"
    , "minimumintegerdigits"
    , "minimumfractiondigits"
    , "maximumfractiondigits"
    , "minimumsignificantdigits"
    , "maximumsignificantdigits"
    ]


{-| Collect the `Intl` options of the `format` attribute (`number`,
`datetime`, `relativetime`, `list` or `pluralrules`) for `<lia-format>`,
`locale` defaults to the course language.
-}
from : String -> Parameters -> Maybe Intl
from lang params =
    let
        intl format names =
            params
                |> Params.filterNames names
                |> (::) ( "format", format )
                |> (::) ( "locale", Params.get "locale" params |> Maybe.withDefault lang )
                |> Just
    in
    case params |> Params.get "format" |> Maybe.map String.toLower of
        Just "number" ->
            intl "number" number

        Just "datetime" ->
            intl "datetime" datetime

        Just "relativetime" ->
            intl "relativetime" relativetime

        Just "list" ->
            intl "list" list

        Just "pluralrules" ->
            intl "pluralrules" pluralrules

        _ ->
            Nothing


{-| Plain text or, with `Intl` options, a `<lia-format>` element that formats
the value.
-}
view : Maybe Intl -> String -> Html msg
view intl value =
    case intl of
        Nothing ->
            Html.text value

        Just attr ->
            Html.node "lia-format"
                (Attr.property "value" (JE.string value) :: Params.toAttribute attr)
                [ Html.text value ]
