module Lia.Sync.Via exposing
    ( Backend(..)
    , Msg
    , checkbox
    , eq
    , fromString
    , icon
    , info
    , infoOn
    , input
    , toString
    , update
    , view
    )

import Conditional.List as CList
import Const
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Lia.Utils as Util


type Backend
    = Edrys
    | GUN { urls : String, persistent : Bool }
      --| Jitsi String
      --| Matrix { baseURL : String, userId : String, accessToken : String }
    | P2PT String
    | PubNub { pubKey : String, subKey : String }
      -- Trystero
    | NoStr
    | MQTT
    | Torrent


toString : Bool -> Backend -> String
toString full via =
    case via of
        Edrys ->
            "Edrys"

        NoStr ->
            "NoStr"

        MQTT ->
            "MQTT"

        Torrent ->
            "Torrent"

        GUN { urls, persistent } ->
            "GUN"
                ++ (if full then
                        (if persistent then
                            "|t"

                         else
                            "|f"
                        )
                            ++ "|"
                            ++ urls

                    else
                        ""
                   )

        -- Jitsi domain ->
        --     "JitSi"
        --         ++ (if full then
        --                 "|" ++ domain
        --             else
        --                 ""
        --            )
        -- Matrix { baseURL, userId, accessToken } ->
        --     "Matrix"
        --         ++ (if full then
        --                 "|" ++ baseURL ++ "|" ++ userId ++ "|" ++ accessToken
        --             else
        --                 ""
        --            )
        PubNub { pubKey, subKey } ->
            "PubNub"
                ++ (if full then
                        "|" ++ pubKey ++ "|" ++ subKey

                    else
                        ""
                   )

        P2PT urls ->
            "P2PT"
                ++ (if full then
                        "|" ++ urls

                    else
                        ""
                   )


icon : Backend -> Html msg
icon via =
    Util.icon
        (case via of
            Edrys ->
                "icon-edrys icon-xs"

            GUN _ ->
                "icon-gundb icon-xs"

            NoStr ->
                "icon-nostr icon-xs"

            MQTT ->
                "icon-mqtt icon-xs"

            Torrent ->
                "icon-torrent icon-xs"

            -- Jitsi _ ->
            --     "icon-jitsi icon-xs"
            -- Matrix _ ->
            --     "icon-matrix icon-xs"
            PubNub _ ->
                "icon-pubnub icon-xs"

            P2PT _ ->
                "icon-p2pt icon-xs"
        )
        [ Attr.style "padding-right" "5px"
        , Attr.style "vertical-align" "middle"
        , Attr.style "font-size" "inherit"
        ]


fromString : String -> Maybe Backend
fromString via =
    case via |> String.split "|" |> mapHead String.toLower of
        [ "edrys" ] ->
            Just Edrys

        [ "nostr" ] ->
            Just NoStr

        [ "mqtt" ] ->
            Just MQTT

        [ "torrent" ] ->
            Just Torrent

        [ "gun" ] ->
            Just (GUN { urls = "", persistent = False })

        [ "gun", "f" ] ->
            Just (GUN { urls = "", persistent = False })

        [ "gun", "f", urls ] ->
            Just (GUN { urls = urls, persistent = False })

        [ "gun", "t" ] ->
            Just (GUN { urls = "", persistent = True })

        [ "gun", "t", urls ] ->
            Just (GUN { urls = urls, persistent = True })

        -- [ "jitsi" ] ->
        --     Just (Jitsi "")
        -- [ "jitsi", domain ] ->
        --     Just (Jitsi domain)
        -- [ "matrix" ] ->
        --     Just <| Matrix { baseURL = "", userId = "", accessToken = "" }
        -- [ "matrix", baseURL ] ->
        --     Just <| Matrix { baseURL = baseURL, userId = "", accessToken = "" }
        -- [ "matrix", baseURL, userId ] ->
        --     Just <| Matrix { baseURL = baseURL, userId = userId, accessToken = "" }
        -- [ "matrix", baseURL, userId, accessToken ] ->
        --     Just <| Matrix { baseURL = baseURL, userId = userId, accessToken = accessToken }
        [ "p2pt" ] ->
            Just (P2PT "")

        [ "p2pt", urls ] ->
            Just (P2PT urls)

        [ "pubnub" ] ->
            Just <| PubNub { pubKey = "", subKey = "" }

        [ "pubnub", pub, sub ] ->
            Just <| PubNub { pubKey = pub, subKey = sub }

        _ ->
            Nothing


mapHead : (a -> a) -> List a -> List a
mapHead fn list =
    case list of
        x :: xs ->
            fn x :: xs

        _ ->
            list


box : List (Html msg) -> Html msg
box =
    Html.p
        [ Attr.style "padding" "5px 15px 5px 15px"
        , Attr.style "border" "1px solid white"
        , Attr.style "margin-top" "2rem"
        ]


line : Html msg
line =
    Html.hr [ Attr.style "margin" "5px 0px" ] []


info : Html msg
info =
    box
        [ Html.text "The LiaScript classroom enables a lightweight collaboration between small groups of users. "
        , Html.text "\"Lightweight\" means that there is no chat (video-conferencing), no logging, and no user roles. "
        , Html.text "Instead, there is only one global state created and shared between the browsers of all users. "
        , Html.text "Thus, a user joins a room with her/his data and when she/he leaves, this data gets removed from the classroom. "
        , Html.text "No data is stored, and no data gets preserved, it is only shared among uses during a classroom session. "
        , Html.text "LiaScript enables the synchronization on the following elements:"
        , Html.ol [ Attr.style "padding" "10px 25px 0px" ]
            [ Html.li [] [ Html.text "Global overview on quizzes" ]
            , Html.li [] [ Html.text "Global overview on surveys" ]
            , Html.li [] [ Html.text "Collaborative editing of executable code snippets (you have to switch to sync-mode, per editor)" ]
            , Html.li [] [ Html.text "A chat that parses LiaScript, such that you can dynamically create quizzes, surveys, collaborative editors, but also to share videos, galleries, oEmbeds, etc..." ]
            ]
        , Html.text "To synchronize the state between users, we apply "
        , link "Conflict Free Replicated Datatypes (CRDTs)" "https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type"
        , Html.text " as implemented by "
        , yjsLink
        , Html.text ". Communication is realized with the help of different backends, which only provide a relay service. "
        , Html.text "The implementation can be found "
        , link "here" "https://github.com/LiaScript/LiaScript/tree/development/src/typescript/sync"
        , Html.text ". Different browsers might support different backends, which require different settings. "
        , Html.text "You can help us with implementing other backend services. "
        , line
        , Html.text "Every room needs a unique name; you can click on the generator-button to do this randomly. "
        , Html.text "After a successful connection, you can either share your settings with your audience or the new URL, which contains the entire classroom configuration. "
        , Html.text "A combination of your course-URL and the room name are used to create a unique ID and to prevent collisions with other courses. "
        , Html.text "However, if you want to establish a connection between exported courses (see "
        , link "LiaScript-Exporter" ""
        , Html.text ") on different platforms, such as "
        , link "Moodle" "https://en.wikipedia.org/wiki/Moodle"
        , Html.text ", "
        , link "ILIAS" "https://en.wikipedia.org/wiki/ILIAS"
        , Html.text ", "
        , link "OPAL" "https://de.wikipedia.org/wiki/OPAL_(Lernplattform)"
        , Html.text ", etc., you can put your room name in single or double quotation marks. "
        , Html.text "This will instruct LiaScript to use the room name only (no course-URL), but you will have to make sure that all users are on the same course and version, to prevent collisions ..."
        , line
        , Html.text "Note, most backend services are free, and you can also host them by your own. "
        , Html.text "There might be cases where the synchronization is slow or there are collisions, but we are working in the background on optimizations and fixes ;-)"
        ]


yjsLink : Html msg
yjsLink =
    link "Y-js" "https://github.com/yjs/yjs"


infoOn : Bool -> Backend -> Html msg
infoOn supported about =
    box <|
        case ( about, supported ) of
            ( Edrys, _ ) ->
                [ link "Edrys" "https://edrys-labs.github.io"
                , Html.text " is an open and modular remote teaching platform (and the first live LMS). "
                , Html.text "It is a great platform for building remote labs and share them by using only a browser locally. "
                , Html.text "Thus, this synchronization will only work, if you are within an Edrys classroom, for more information try the following link: "
                , link "https://github.com/edrys-labsg" "https://github.com/edrys-labs"
                , Html.text ". Additionally, your course has to be loaded via the "
                , link "module-liascript" "https://github.com/edrys-labs/module-liascript"
                , Html.text "."
                , Html.br [] []
                , Html.br [] []
                , allowScripts
                ]

            ( GUN _, _ ) ->
                [ link "GunDB" "https://gun.eco"
                , Html.text " is a small, easy, and fast real-time database for syncing data across various users."
                , Html.text " You can use the default relay server hosted at "
                , link Const.gunDB_ServerURL Const.gunDB_ServerURL
                , Html.text ". Or, if you don't trust us ;-) you can also use one of the free hosted relay servers listed "
                , link "here" "https://github.com/amark/gun/wiki/volunteer.dht"
                , Html.text ". Multiple peers have to be separated by commas."
                , Html.text " The implementation of this classroom can be found "
                , link "here" "https://github.com/LiaScript/LiaScript/tree/development/src/typescript/sync/Gun"
                , Html.text ". By checking \"persistent storage\" you can ensure that the chat messages and the modified code will be accessible over a longer time period, otherwise the state is deleted."
                , Html.text " However, since this is a free service, we cannot give guarantees that your messages will be stored forever and that the GunDB server might be offline."
                , Html.text " If you want to be certain, you can host your own instance of a GunDB server and change the URL appropriately."
                , Html.br [] []
                , Html.br [] []
                , allowScripts
                ]

            ( NoStr, _ ) ->
                [ link "NoStr" "https://nostr.com"
                , Html.text " is a decentralized protocol designed for creating a censorship-resistant global social network."
                , Html.text "The acronym stands for \"Notes and Other Stuff Transmitted by Relays\""
                , Html.text "It operates through a network of clients and relays, where clients are interfaces for users to interact with the network, and relays act as databases storing and transmitting data. "
                , Html.text "Users are identified by public keys, and all events (like messages or updates) are signed for verification. "
                , Html.text "NoStr's decentralization ensures resilience against censorship and single points of failure, as data is distributed across multiple nodes. "
                , Html.text "It's an open standard, allowing anyone to build upon it, and its design promotes freedom of speech and global accessibility."
                , Html.br [] []
                , Html.br [] []
                , allowScripts
                ]

            ( MQTT, _ ) ->
                [ link "MQTT (Message Queuing Telemetry Transport)" "https://mqtt.org"
                , Html.text " is a lightweight, publish-subscribe messaging protocol designed for machine-to-machine (M2M) communication, particularly in the Internet of Things (IoT) and industrial IoT (IIoT) contexts. "
                , Html.text "It enables devices to efficiently publish and subscribe to data over the Internet, facilitating communication between embedded devices, sensors, and industrial PLCs. "
                , Html.text "MQTT operates over a transport protocol like TCP/IP, ensuring ordered, lossless, bi-directional connections."
                , Html.text "The protocol is event-driven, with a broker managing the distribution of messages between publishers and subscribers based on topics. "
                , Html.text "This decoupling allows for scalable and reliable data exchange, making MQTT a standard for IoT data transmission."
                , Html.br [] []
                , Html.br [] []
                , allowScripts
                ]

            ( Torrent, _ ) ->
                [ link "Torrent" "https://www.beautifulcode.co/blog/58-understanding-bittorrent-protocol"
                , Html.text " is a peer-to-peer file-sharing protocol used for distributing large files across a network of computers. "
                , Html.text "In the context of browser-based Pub/Sub (Publish/Subscribe) messaging, Torrent can facilitate the distribution of messages or data across a network of peers, enabling efficient, decentralized communication without a central server. "
                , Html.text "This approach is particularly useful for real-time applications like chat or live streaming, ensuring data is quickly and reliably distributed to all interested peers."
                , Html.br [] []
                , Html.br [] []
                , allowScripts
                ]

            -- ( Jitsi _, _ ) ->
            --     [ link "Jitsi" "https://en.wikipedia.org/wiki/Jitsi"
            --     , Html.text " is a free and open-source multiplatform for video conferencing, voice over IP, and instant messaging. "
            --     , Html.text "It is probably best known for its public video conferencing server "
            --     , link "https://meet.jit.si" "https://meet.jit.si"
            --     , Html.text ", that we use a backend to establish classrooms via data-channels. "
            --     , Html.text "However, you can use their default service or host a server by your own, then you will have to change the domain setting."
            --     ]
            -- ( Matrix _, _ ) ->
            --     [ link "[Matrix]" "https://matrix.org"
            --     , Html.text " is an open network/standard/project for secure and decentralized real-time communication. "
            --     , Html.text " You can find more information about it "
            --     , link "here on Wikipedia" "https://en.wikipedia.org/wiki/Matrix_(protocol)"
            --     , Html.text ". Thus, if you have access to the following settings, you can establish a classroom that uses the "
            --     , link "Matrix-CRDT" "https://github.com/yousefED/matrix-crdt"
            --     , Html.text " provider for "
            --     , yjsLink
            --     , Html.text "."
            --     ]
            ( PubNub _, _ ) ->
                [ link "PubNub" "https://www.pubnub.com"
                , Html.text " is a real-time communication platform. "
                , Html.text "To create a classroom that uses this service, you will only require an account, which is free for testing. "
                , Html.text "After that, you simply have to create a new App with a new Keyset within their dashboard. "
                , Html.text "These are the keys you will have to provide for this room. "
                , Html.text "After this, you can simply generate a new set of keys. "
                , Html.text "The basic steps that are required, are described in more detail "
                , link "here" "https://www.appypie.com/faqs/how-to-get-pubnub-publish-key-and-subscribe-key"
                , Html.text "."
                , Html.br [] []
                , Html.br [] []
                , allowScripts
                ]

            ( P2PT _, _ ) ->
                [ Html.text "The "
                , link "P2PT" "https://github.com/subins2000/p2pt"
                , Html.text " project utilizes "
                , link "WebTorrent" "https://webtorrent.io"
                , Html.text " trackers as signaling servers for establishing peer-to-peer (P2P) connections via "
                , link "WebRTC" "https://en.wikipedia.org/wiki/WebRTC"
                , Html.text ". Therefor P2PT uses magnet-URIs as an app identifier to communicate with the WebTorrent trackers, which provide a list of web peers using the app."
                , Html.text "With this information, P2PT enables an browser applications to share real-time data and send messages interaction between connected peers."
                , Html.text "Thus, you have to provide WebSocket-URLs, which start with "
                , Html.code [ Attr.class "lia-code lia-code--inline" ] [ Html.text "wss://" ]
                , Html.text "."
                , Html.br [] []
                , Html.br [] []
                , allowScripts
                ]


allowScripts : Html msg
allowScripts =
    Html.text "If you want to allow scripts to be executed in the chat, you can check this box, allowing for dynamic content and interactivity. However, please be cautious as this may pose security risks if untrusted code is executed."


link : String -> String -> Html msg
link title url =
    Html.a [ Attr.href url, Attr.target "blank" ] [ Html.text title ]


view : Bool -> Backend -> Html Msg
view editable backend =
    case backend of
        GUN { urls, persistent } ->
            Html.div []
                [ input
                    { active = editable
                    , type_ = "text"
                    , msg = InputGun
                    , value = urls
                    , placeholder = "https://gun1.server, https://gun2.server, ..."
                    , label = Html.text "relay server"
                    , autocomplete = Just "gun-server"
                    }
                , checkbox
                    { active = editable
                    , value = persistent
                    , msg = CheckboxGun
                    , label = Html.text "persistent storage"
                    }
                ]

        -- Jitsi domain ->
        --     input
        --         { active = editable
        --         , type_ = "text"
        --         , msg = InputJitsi
        --         , value = domain
        --         , placeholder = "domain.jit.si"
        --         , label = Html.text "domain"
        --         , autocomplete = Just "jitsi-domain"
        --         }
        -- Matrix { baseURL, userId, accessToken } ->
        --     Html.div []
        --         [ input
        --             { active = editable
        --             , type_ = "text"
        --             , msg = InputMatrix "url"
        --             , label = Html.text "base URL"
        --             , value = baseURL
        --             , placeholder = "https://matrix.org"
        --             , autocomplete = Just "matrix-url"
        --             }
        --         , input
        --             { active = editable
        --             , type_ = "text"
        --             , msg = InputMatrix "user"
        --             , label = Html.text "user ID"
        --             , value = userId
        --             , placeholder = "@USERID:matrix.org"
        --             , autocomplete = Just "matrix-user"
        --             }
        --         , input
        --             { active = editable
        --             , type_ = "text"
        --             , msg = InputMatrix "token"
        --             , label = Html.text "access token"
        --             , value = accessToken
        --             , placeholder = "....MDAxM2lkZW50aWZpZXIga2V5CjAwMTBjaWQgZ2Vu...."
        --             , autocomplete = Just "matrix-token"
        --             }
        --         ]
        PubNub { pubKey, subKey } ->
            Html.div []
                [ input
                    { active = editable
                    , type_ = "password"
                    , msg = InputPubNub "pub"
                    , label = Html.text "publishKey"
                    , value = pubKey
                    , placeholder = "pub-c-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
                    , autocomplete = Just "pubnup-publishKey"
                    }
                , input
                    { active = editable
                    , type_ = "password"
                    , msg = InputPubNub "sub"
                    , label = Html.text "subscribeKey"
                    , value = subKey
                    , placeholder = "sub-c-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
                    , autocomplete = Just "pubnup-subscribeKey"
                    }
                ]

        P2PT urls ->
            input
                { active = editable
                , type_ = "text"
                , msg = InputP2PT
                , value = urls
                , placeholder = "wss://tracker.torrent"
                , label = Html.text "WebTorrent tracker URLs"
                , autocomplete = Just "websocket-urls"
                }

        _ ->
            Html.text ""


input :
    { active : Bool
    , msg : String -> msg
    , label : Html msg
    , type_ : String
    , value : String
    , placeholder : String
    , autocomplete : Maybe String
    }
    -> Html msg
input { active, msg, label, type_, value, placeholder, autocomplete } =
    Html.label []
        [ Html.span
            [ Attr.class "lia-label"
            , Attr.style "margin-top" "2rem"
            ]
            [ label ]
        , Html.input
            ([ if active then
                Event.onInput msg

               else
                Attr.disabled True
             , Attr.value value
             , Attr.style "color" "black"
             , Attr.type_ type_
             , Attr.style "width" "100%"
             , Attr.placeholder placeholder
             ]
                |> CList.addWhen
                    (autocomplete
                        |> Maybe.map (Attr.attribute "autocomplete")
                    )
            )
            []
        ]


checkbox :
    { active : Bool
    , msg : msg
    , label : Html msg
    , value : Bool
    }
    -> Html msg
checkbox { active, msg, label, value } =
    Html.label [ Attr.style "margin-top" "2rem", Attr.class "lia-label" ]
        [ Html.input
            [ if active then
                Event.onClick msg

              else
                Attr.disabled True
            , Attr.style "color" "black"
            , Attr.type_ "checkbox"
            , Attr.checked value
            , Attr.class "lia-checkbox"

            --, Attr.style "display" "block"
            ]
            []
        , Html.span
            [ Attr.class "lia-label"
            ]
            [ label ]
        ]


type Msg
    = InputGun String
    | CheckboxGun
    | InputPubNub String String
      --| InputMatrix String String
      --| InputJitsi String
    | InputP2PT String


update : Msg -> Backend -> Backend
update msg backend =
    case ( msg, backend ) of
        ( InputGun urls, GUN data ) ->
            GUN { data | urls = urls }

        ( CheckboxGun, GUN data ) ->
            GUN { data | persistent = not data.persistent }

        -- ( InputJitsi domain, Jitsi _ ) ->
        --     Jitsi domain
        ( InputPubNub "pub" new, PubNub data ) ->
            PubNub { data | pubKey = new }

        ( InputPubNub "sub" new, PubNub data ) ->
            PubNub { data | subKey = new }

        -- ( InputMatrix "url" new, Matrix data ) ->
        --     Matrix { data | baseURL = new }
        -- ( InputMatrix "user" new, Matrix data ) ->
        --     Matrix { data | userId = new }
        -- ( InputMatrix "token" new, Matrix data ) ->
        --     Matrix { data | accessToken = new }
        ( InputP2PT urls, P2PT _ ) ->
            P2PT urls

        _ ->
            backend


eq : Backend -> Backend -> Bool
eq a b =
    case ( a, b ) of
        ( GUN _, GUN _ ) ->
            True

        -- ( Matrix _, Matrix _ ) ->
        --     True
        ( PubNub _, PubNub _ ) ->
            True

        -- ( Jitsi _, Jitsi _ ) ->
        --     True
        ( P2PT _, P2PT _ ) ->
            True

        _ ->
            a == b
