module Lia.Markdown.Effect.Script.Intl exposing (Intl, from, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.HTML.Attributes as Params exposing (Parameters)


type alias Intl =
    Parameters


number : List String
number =
    [ "locale"
    , "compactdisplay"
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
    [ "locale"
    , "calendar"
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
    [ "locale"
    , "unit"
    , "localematcher"
    , "numeric"
    , "localestyle"
    ]


list : List String
list =
    [ "locale"
    , "localematcher"
    , "type"
    , "localestyle"
    ]


pluralrules : List String
pluralrules =
    [ "locale"
    , "localematcher"
    , "type"
    , "minimumintegerdigits"
    , "minimumfractiondigits"
    , "maximumfractiondigits"
    , "minimumsignificantdigits"
    , "maximumsignificantdigits"
    ]


from : Parameters -> Maybe Intl
from params =
    case params |> Params.get "format" |> Maybe.map String.toLower of
        Just "number" ->
            to "number" number params

        Just "datetime" ->
            to "datetime" datetime params

        Just "relativetime" ->
            to "relativetime" relativetime params

        Just "list" ->
            to "list" list params

        Just "pluralrules" ->
            to "pluralrules" pluralrules params

        _ ->
            Nothing


to : String -> List String -> Parameters -> Maybe Intl
to format names =
    Params.filterNames names
        >> (::) ( "format", format )
        >> Just


view : Maybe Intl -> String -> Html msg
view intl =
    case intl of
        Nothing ->
            Html.text

        Just attr ->
            node attr


node : Parameters -> String -> Html msg
node attr value =
    Html.node "intl-format"
        (attr
            |> Params.toAttribute
            |> (::) (Attr.property "value" (JE.string value))
        )
        [ Html.text value ]
