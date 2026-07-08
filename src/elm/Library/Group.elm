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
    JD.map2
        (\a b ->
            if Just a /= b then
                Just a

            else
                Nothing
        )
        (JD.at [ "target", "dataset", "groupId" ] JD.string)
        (JD.at [ "relatedTarget" ] closestGroupId)
        |> JD.andThen (maybeGroupId msg)


{-| Walks up from a node (e.g. `relatedTarget`) to find the nearest
`data-group-id`, mimicking `Element.closest`. Elements injected into a
group's container by third-party scripts (e.g. the Google Translate
widget's `<select>`) don't carry that attribute themselves, but their
ancestor container does, so they still count as "inside" the group.
-}
closestGroupId : JD.Decoder (Maybe String)
closestGroupId =
    JD.oneOf
        [ JD.at [ "dataset", "groupId" ] JD.string |> JD.map Just
        , JD.field "parentElement" (JD.lazy (\_ -> closestGroupId))
        , JD.succeed Nothing
        ]


maybeGroupId : (String -> msg) -> Maybe String -> JD.Decoder msg
maybeGroupId msg change =
    case change of
        Just a ->
            JD.succeed (msg a)

        Nothing ->
            JD.fail "no change"
