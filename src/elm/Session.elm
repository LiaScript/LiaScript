module Session exposing
    ( Room
    , Screen
    , Session
    , Type(..)
    , decodeRoom
    , encodeOwnerLink
    , encodeRoom
    , getType
    , load
    , navTo
    , navToHome
    , navToSlide
    , setClass
    , setFragment
    , setQuery
    , setScreen
    , setUrl
    , update
    , urlWithQuery
    )

{-| This module covers all relevant session functions/data that deal with
URL-navigation. Therefor all relevant information is stored and updated with the
`Session` record, a unique repository, that is passed on between modules.
-}

import Base64
import Browser.Navigation as Navigation
import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Url exposing (Url)


{-| This record encapsulates all relevant session information, that is not
handled directly by LiaScript:

  - **share**: does the Browser posses a Navigation.share API
  - **key**: the "elm" navigation key
  - **screen**: the current screen size
  - **url**: the current url, commonly only the course-parameter `?` gets
    updated and the fragment `#`. No query-parameter indicate that the course
    index should be displayed.

-}
type alias Session =
    { share : Bool
    , key : Navigation.Key
    , screen : Screen
    , url : Url
    }


{-| Current display size...
-}
type alias Screen =
    { width : Int
    , height : Int
    }


{-| At the moment there are only two types of modes of presentations, either
a `Course ReadMeURL slideNumber` is rendered or and `Index` of all
visited/stored courses. In most cases this state of representation is also
defined by the url:

`http://lia.../?ReadMeURL#slideNumber`

If this information is present, then it is a course otherwise the index.

-}
type Type
    = Index
    | Course String (Maybe String)
    | Class Room (Maybe String)


type alias Room =
    { backend : String
    , course : String
    , room : String
    , mode : Int

    -- hash of the room's owner secret, safe to share - see `ownerToken`
    , ownerTokenHash : String

    -- salted PBKDF2 password hint, both safe to share - see `Service.Sync.checkPassword`
    , pwSalt : String
    , pwCheck : String

    -- the raw owner secret. `Just` only on a dedicated "owner link" (see
    -- `encodeOwnerLink`) - `encodeRoom` never serializes it, which is what
    -- guarantees a normal, forwarded classroom link can never grant owner
    -- access.
    , ownerToken : Maybe String
    }


{-| Update the entire session-URL.

> In most case this is used only to update the query parameter (`?course-URL`)
> or the fragment (`#slideNumber`). All other parameters should not be touched.

-}
setUrl : Url -> Session -> Session
setUrl url session =
    { session | url = url }


{-| Update the query and thus, the current `?course-URL`.
-}
setQuery : String -> Session -> Session
setQuery query session =
    let
        url =
            session.url
    in
    { session | url = { url | query = Just query } }


{-| Update the query to represent a class room, which is for simplicity and
percent encoded string representation of the JSON encoded string for:

    { "backend": "Beaker"
    , "course": "https://....README.md"
    , "room": "some arbitrary room name"
    }

-}
setClass : Room -> Session -> Session
setClass room =
    setQuery (encodeRoom room)


{-| Update the fragment and thus, the current slide number
`?course-URL#fragment`.
-}
setFragment : Int -> Session -> Session
setFragment slide session =
    let
        url =
            session.url
    in
    { session | url = { url | fragment = Just (String.fromInt slide) } }


navTo : Session -> Url -> Cmd msg
navTo session =
    Url.toString >> Navigation.pushUrl session.key


{-| Use this to replace the current URL, with the settings define by session.
This will only replace the URL does not add an entry to the browser history.
-}
update : Session -> Cmd msg
update session =
    session.url
        |> Url.toString
        |> Navigation.replaceUrl session.key


load : Url -> Cmd msg
load =
    Url.toString >> Navigation.load


{-| A shortcut for going to the Index-page, by simply deleting the URL query and
fragment.
-}
navToHome : Session -> Cmd msg
navToHome session =
    let
        url =
            session.url
    in
    { url | query = Nothing, fragment = Nothing }
        |> navTo session


{-| A shortcut for changing the fragment number, which replicates the current
slideNumber.
-}
navToSlide : Session -> Int -> Cmd msg
navToSlide session id =
    let
        url =
            session.url
    in
    { url | fragment = Just <| String.fromInt (1 + id) }
        |> navTo session


{-| Parse the URL-query and fragment. If no query-string is present the Index
type is deduced, otherwise the Course type.
-}
getType : Url -> Type
getType url =
    case url.query of
        Just str ->
            case decodeRoom str of
                Just room ->
                    Class room url.fragment

                Nothing ->
                    Course str url.fragment

        Nothing ->
            Index


{-| Update the screen size.
-}
setScreen : Screen -> Session -> Session
setScreen size session =
    { session | screen = size }


{-| The raw `ownerToken` is deliberately never encoded here - this is the one
place that guarantees a normal classroom link (the one sitting in the address
bar, including the owner's own) can never leak owner access to whoever it's
forwarded to. Use `encodeOwnerLink` for the separate, dedicated owner link.
-}
encodeRoom : Room -> String
encodeRoom room =
    roomFields room
        |> JE.object
        |> JE.encode 0
        |> Base64.encode


{-| Like `encodeRoom`, but additionally includes the raw `ownerToken` when
present - only ever used to build the dedicated "owner link" copied from the
classroom settings, never for the address bar.
-}
encodeOwnerLink : Room -> String
encodeOwnerLink room =
    (roomFields room
        ++ (case room.ownerToken of
                Just token ->
                    [ ( "ownerToken", JE.string token ) ]

                Nothing ->
                    []
           )
    )
        |> JE.object
        |> JE.encode 0
        |> Base64.encode


roomFields : Room -> List ( String, JE.Value )
roomFields { backend, course, room, mode, ownerTokenHash, pwSalt, pwCheck } =
    [ ( "backend", JE.string backend )
    , ( "course", JE.string course )
    , ( "room", JE.string room )
    , ( "mode", JE.int mode )
    , ( "ownerTokenHash", JE.string ownerTokenHash )
    , ( "pwSalt", JE.string pwSalt )
    , ( "pwCheck", JE.string pwCheck )
    ]


{-| Missing `ownerTokenHash`/`pwSalt`/`pwCheck`/`ownerToken` (a link generated
before this scheme existed) simply default to "no security metadata", so old
links keep decoding instead of breaking.
-}
decodeRoom : String -> Maybe Room
decodeRoom =
    Base64.decode
        >> Result.toMaybe
        >> Maybe.andThen
            (JD.decodeString
                (JD.succeed Room
                    |> JDP.required "backend" JD.string
                    |> JDP.required "course" JD.string
                    |> JDP.required "room" JD.string
                    |> JDP.required "mode" JD.int
                    |> JDP.optional "ownerTokenHash" JD.string ""
                    |> JDP.optional "pwSalt" JD.string ""
                    |> JDP.optional "pwCheck" JD.string ""
                    |> JDP.optional "ownerToken" (JD.map Just JD.string) Nothing
                )
                >> Result.toMaybe
            )


{-| Build a full URL string from an already-encoded query, without touching
`session`/the browser history - used for the owner-link copy action, which
must never navigate to or replace the current address bar entry.
-}
urlWithQuery : String -> Session -> String
urlWithQuery query session =
    let
        url =
            session.url
    in
    Url.toString { url | query = Just query }
