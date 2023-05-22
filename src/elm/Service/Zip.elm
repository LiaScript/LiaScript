module Service.Zip exposing
    ( decode
    , decompress
    )

import Http
import Json.Decode as JD
import Json.Encode as JE
import Service.Event as Event exposing (Event)


decompress : { template : Bool, id : String, data : String } -> Event
decompress { template, id, data } =
    Event.init "zip"
        { cmd = "unzip"
        , param =
            JE.object
                [ ( "template", JE.bool template )
                , ( "id", JE.string id )
                , ( "data", JE.string data )
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
            , data.id
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


decoder : JD.Decoder { template : Bool, id : String, body : ( Bool, String ) }
decoder =
    JD.map3 (\template id body -> { template = template, id = id, body = body })
        (JD.field "template" JD.bool)
        (JD.field "id" JD.string)
        (JD.field "data"
            (JD.map2 Tuple.pair
                (JD.field "ok" JD.bool)
                (JD.field "body" JD.string)
            )
        )
