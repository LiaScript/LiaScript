module Lia.Markdown.Effect.Script.Input exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Lia.Markdown.HTML.Attributes as Attr exposing (Parameters)
import Port.Eval as Eval exposing (Eval)
import Regex


type Type_
    = Checkbox_
    | Color_
    | Date_
    | DatetimeLocal_
    | Email_
      --| File_
      --| Hidden_
      --| Image_
    | Month_
    | Number_
    | Password_
      --| Radio_
    | Range_
      --| Reset_
    | Search_
    | Select_ (List String)
    | Submit_
    | Tel_
    | Text_ -- default
    | Time_
    | Url_
    | Week_


type alias Input =
    { active : Bool
    , value : String
    , default : String
    , type_ : Maybe Type_
    }


from : Parameters -> Input
from params =
    let
        value =
            params
                |> Attr.get "value"
                |> Maybe.withDefault ""
    in
    type_ params
        |> Input False value value


type_ : Parameters -> Maybe Type_
type_ params =
    case params |> Attr.get "input" >> Maybe.map (String.trim >> String.toLower) of
        Just "button" ->
            Just Submit_

        Just "checkbox" ->
            Just Checkbox_

        Just "color" ->
            Just Color_

        Just "date" ->
            Just Date_

        Just "datetime-local" ->
            Just DatetimeLocal_

        Just "email" ->
            Just Email_

        Just "month" ->
            Just Month_

        Just "password" ->
            Just Password_

        Just "search" ->
            Just Search_

        Just "select" ->
            Just (Select_ (options params))

        Just "submit" ->
            Just Submit_

        Just "tel" ->
            Just Tel_

        Just "time" ->
            Just Time_

        Just "url" ->
            Just Url_

        Just "week" ->
            Just Week_

        Just _ ->
            Just Text_

        Nothing ->
            Nothing


options : Parameters -> List String
options =
    Attr.get "options"
        >> Maybe.map (String.split "|")
        >> Maybe.withDefault []
        >> List.map String.trim
