module Lia.Markdown.Effect.Script.Intl exposing (Intl, from, view)

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


from : String -> Parameters -> Maybe Intl
from lang params =
    Maybe.map ((::) (locale lang params)) <|
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


locale : String -> Parameters -> ( String, String )
locale lang =
    Params.get "locale"
        >> Maybe.withDefault lang
        >> Tuple.pair "locale"


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
    Html.node "lia-format"
        (attr
            |> Params.toAttribute
            |> (::) (Attr.property "value" (JE.string value))
        )
        [ Html.text value ]
