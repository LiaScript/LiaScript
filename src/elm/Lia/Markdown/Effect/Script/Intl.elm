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
    , "localestyle"
    , "currency"
    , "localematcher"
    , "usegrouping"
    , "minimumintegerdigits"
    , "minimumfractiondigits"
    , "maximumfractiondigits"
    , "minimumsignificantdigits"
    , "maximumsignificantdigits"
    ]


datetime : List String
datetime =
    [ "locale"
    , "localematcher"
    , "timezone"
    , "hour12"
    , "hourcycle"
    , "formatmatcher"
    , "weekday"
    , "era"
    , "year"
    , "month"
    , "day"
    , "hour"
    , "minute"
    , "second"
    , "timezonename"
    ]


from : Parameters -> Maybe Intl
from params =
    case params |> Params.get "format" |> Maybe.map String.toLower of
        Just "number" ->
            params
                |> Params.filterNames number
                |> (::) ( "format", "number" )
                |> Just

        Just "datetime" ->
            params
                |> Params.filterNames datetime
                |> (::) ( "format", "datetime" )
                |> Just

        _ ->
            Nothing


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
