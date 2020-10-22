module Lia.Markdown.Effect.Script.Intl exposing (Intl, from, view)

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.HTML.Attributes as Params exposing (Parameters)


type Intl
    = Number Parameters
    | DateTime Parameters


number : List String
number =
    [ "locale"
    , "localeStyle"
    , "currency"
    , "localeMatcher"
    , "useGrouping"
    , "minimumIntegerDigits"
    , "minimumFractionDigits"
    , "maximumFractionDigits"
    , "minimumSignificantDigits"
    , "maximumSignificantDigits"
    ]


datetime : List String
datetime =
    []


from : Parameters -> Maybe Intl
from params =
    case params |> Params.get "format" |> Maybe.map String.toLower of
        Just "number" ->
            params
                |> Params.filterNames number
                |> Number
                |> Just

        Just "datetime" ->
            params
                |> Params.filterNames datetime
                |> Number
                |> Just

        _ ->
            Nothing


view : Maybe Intl -> String -> Html msg
view intl =
    case intl of
        Nothing ->
            Html.text

        Just (Number attr) ->
            node "intl-number" attr

        Just (DateTime attr) ->
            node "intl-datetime" attr


node : String -> Parameters -> String -> Html msg
node name attr value =
    Html.node name
        (attr
            |> Params.toAttribute
            |> (::) (Attr.property "value" (JE.string value))
        )
        []
