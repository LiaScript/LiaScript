module Lia.Markdown.Effect.Script.Input exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.HTML.Attributes as Attr exposing (Parameters)
import Port.Eval as Eval exposing (Eval)
import Regex


type Type_
    = Button_
    | Checkbox_ (List String)
    | Color_
    | Date_
    | DatetimeLocal_
    | Email_
    | File_
    | Hidden_
    | Image_
    | Month_
    | Number_
    | Password_
    | Radio_ (List String)
    | Range_
      --| Reset_
    | Search_
    | Select_ (List String)
    | Tel_
    | Text_ -- default
    | Textarea_
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
        val =
            params
                |> Attr.get "value"
                |> Maybe.withDefault ""
    in
    params
        |> Attr.get "input"
        |> Maybe.map (parseType_ params)
        |> Input False val val


type_ : Type_ -> String
type_ t =
    case t of
        Button_ ->
            "button"

        Checkbox_ _ ->
            "checkbox"

        Color_ ->
            "color"

        Date_ ->
            "date"

        DatetimeLocal_ ->
            "datetime-local"

        Email_ ->
            "email"

        File_ ->
            "file"

        Hidden_ ->
            "hidden"

        Image_ ->
            "image"

        Month_ ->
            "month"

        Number_ ->
            "number"

        Password_ ->
            "password"

        Radio_ _ ->
            "radio"

        Range_ ->
            "range"

        Search_ ->
            "search"

        Select_ _ ->
            "select"

        Tel_ ->
            "tel"

        Text_ ->
            "text"

        Textarea_ ->
            "textarea"

        Time_ ->
            "time"

        Url_ ->
            "url"

        Week_ ->
            "week"


parseType_ : Parameters -> String -> Type_
parseType_ params input_ =
    case input_ of
        "button" ->
            Button_

        "checkbox" ->
            Checkbox_ (options params)

        "color" ->
            Color_

        "date" ->
            Date_

        "datetime-local" ->
            DatetimeLocal_

        "email" ->
            Email_

        "file" ->
            File_

        "hidden" ->
            Hidden_

        "image" ->
            Image_

        "month" ->
            Month_

        "number" ->
            Number_

        "password" ->
            Password_

        "radio" ->
            Radio_ (options params)

        "range" ->
            Range_

        "search" ->
            Search_

        "select" ->
            Select_ (options params)

        "submit" ->
            Button_

        "tel" ->
            Tel_

        "textarea" ->
            Textarea_

        "time" ->
            Time_

        "url" ->
            Url_

        "week" ->
            Week_

        _ ->
            Text_


{-| Defines if an input-type should be reevaluted on change.
-}
runnable : Type_ -> Bool
runnable t =
    case t of
        Email_ ->
            False

        Password_ ->
            False

        Search_ ->
            False

        Tel_ ->
            False

        Textarea_ ->
            False

        Url_ ->
            False

        _ ->
            True


options : Parameters -> List String
options =
    Attr.get "options"
        >> Maybe.map (String.split "|")
        >> Maybe.withDefault []
        >> List.map String.trim
        >> List.filter (String.isEmpty >> not)


active : Bool -> Input -> Input
active bool i =
    { i | active = bool }


value : String -> Input -> Input
value str i =
    { i | value = str }


toggle : String -> Input -> Input
toggle str i =
    { i
        | value =
            encodeList <|
                case decodeList i.value of
                    Just list ->
                        if List.member str list then
                            List.filter ((/=) str) list

                        else
                            str :: list

                    Nothing ->
                        []
    }


decodeList : String -> Maybe (List String)
decodeList =
    JD.decodeString (JD.list JD.string) >> Result.toMaybe


encodeList : List String -> String
encodeList =
    JE.list JE.string >> JE.encode 0


default : Input -> Input
default i =
    { i | value = i.default }


isHidden : Input -> Bool
isHidden =
    .type_ >> (==) (Just Hidden_)
