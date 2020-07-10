module Port.Event exposing
    ( Event
    , decode
    , encode
    , store
    )

import Json.Decode as JD
import Json.Encode as JE


type alias Event =
    { topic : String
    , section : Int
    , message : JE.Value
    }


encode : Event -> JE.Value
encode { topic, section, message } =
    JE.object
        [ ( "topic", JE.string topic )
        , ( "section", JE.int section )
        , ( "message", message )
        ]



{-
   unzip : List JE.Value -> ( List JE.Value, List JE.Value )
   unzip =
       List.foldl
           (\list ( extern, base ) ->
               case list of
                   [] ->
                       ( extern, base )

                   e :: es ->
                       if isBase e then
                           ( extern, e :: base )

                       else
                           ( e :: extern, base )
           )
           ( [], [] )
-}


decode : JD.Value -> Result JD.Error Event
decode =
    JD.decodeValue
        (JD.map3 Event
            (JD.field "topic" JD.string)
            (JD.field "section" JD.int)
            (JD.field "message" JD.value)
        )


store : JE.Value -> Event
store =
    Event "store" -1
