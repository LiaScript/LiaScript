module Library.Group exposing (blur, id)

import Html exposing (Attribute)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as JD


blur : (String -> msg) -> Attribute msg
blur msg =
    Event.on "blur" (decodeGroupIdChanged msg)


id : String -> Attribute msg
id groupId =
    Attr.attribute "data-group-id" groupId


decodeGroupIdChanged : (String -> msg) -> JD.Decoder msg
decodeGroupIdChanged msg =
    JD.oneOf
        [ JD.map2
            (\a b ->
                if a /= b then
                    Just a

                else
                    Nothing
            )
            (JD.at [ "target", "dataset", "groupId" ] JD.string)
            (JD.at [ "relatedTarget", "dataset", "groupId" ] JD.string)
        , JD.at [ "target", "dataset", "groupId" ] JD.string
            |> JD.andThen (\a -> JD.succeed (Just a))
        ]
        |> JD.andThen (maybeGroupId msg)


maybeGroupId : (String -> msg) -> Maybe String -> JD.Decoder msg
maybeGroupId msg change =
    case change of
        Just a ->
            JD.succeed (msg a)

        Nothing ->
            JD.fail "no change"
