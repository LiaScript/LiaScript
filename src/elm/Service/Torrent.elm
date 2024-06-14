module Service.Torrent exposing (decode, load)

import Http
import Json.Decode as JD
import Json.Encode as JE
import Service.Event as Event exposing (Event)


type alias Response =
    { template : Bool
    , uri : String
    , body : ( Bool, String )
    }


load : { template : Bool, uri : String } -> Event
load { template, uri } =
    Event.init "torrent"
        { cmd = "load"
        , param =
            JE.object
                [ ( "template", JE.bool template )
                , ( "uri", JE.string uri )
                ]
        }


decode :
    JD.Value
    ->
        ( Bool
        , String
        , Result Http.Error String
        )
decode json =
    case JD.decodeValue decoder json of
        Ok data ->
            ( data.template
            , data.uri
            , case data.body of
                ( True, content ) ->
                    Ok content

                ( False, info ) ->
                    info
                        |> Http.BadBody
                        |> Err
            )

        Err info ->
            ( False
            , ""
            , info
                |> JD.errorToString
                |> Http.BadBody
                |> Err
            )


decoder : JD.Decoder Response
decoder =
    JD.map3 Response
        (JD.field "template" JD.bool)
        (JD.field "uri" JD.string)
        (JD.field "data"
            (JD.map2 Tuple.pair
                (JD.field "ok" JD.bool)
                (JD.field "body" JD.string)
            )
        )
