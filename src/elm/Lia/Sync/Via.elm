module Lia.Sync.Via exposing
    ( Backend(..)
    , Msg
    , badge
    , badges
    , checkbox
    , eq
    , fromString
    , icon
    , info
    , infoOn
    , input
    , tagline
    , toString
    , update
    , view
    )

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
    | IPFS { turnConfig : String }
    | PubNub { pubKey : String, subKey : String }
    | Ably { apiKey : String, persistent : Bool }
      -- Trystero
    | NoStr { relayUrls : String, turnConfig : String }
    | MQTT { relayUrls : String, turnConfig : String }
    | Torrent { relayUrls : String, turnConfig : String }
    | WebSocket { url : String }
    | PeerJS { host : String, port_ : String, path : String, iceServers : String }
    | SimplePeer { signaling : String, iceServers : String }
    | Local


toString : Bool -> Backend -> String
toString full via =
    case via of
        Edrys ->
            "Edrys"

        NoStr { relayUrls, turnConfig } ->
            "NoStr"
                ++ (if full then
                        "|" ++ relayUrls ++ "|" ++ turnConfig

                    else
                        ""
                   )

        MQTT { relayUrls, turnConfig } ->
            "MQTT"
                ++ (if full then
                        "|" ++ relayUrls ++ "|" ++ turnConfig

                    else
                        ""
                   )

        Torrent { relayUrls, turnConfig } ->
            "Torrent"
                ++ (if full then
                        "|" ++ relayUrls ++ "|" ++ turnConfig

                    else
                        ""
                   )

        IPFS { turnConfig } ->
            "IPFS"
                ++ (if full then
                        "|" ++ turnConfig

                    else
                        ""
                   )

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

        Ably { apiKey, persistent } ->
            "Ably"
                ++ (if full then
                        (if persistent then
                            "|t"

                         else
                            "|f"
                        )
                            ++ "|"
                            ++ apiKey

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

        WebSocket { url } ->
            "WebSocket"
                ++ (if full then
                        "|" ++ url

                    else
                        ""
                   )

        PeerJS { host, port_, path, iceServers } ->
            "PeerJS"
                ++ (if full then
                        "|" ++ host ++ "|" ++ port_ ++ "|" ++ path ++ "|" ++ iceServers

                    else
                        ""
                   )

        SimplePeer { signaling, iceServers } ->
            "SimplePeer"
                ++ (if full then
                        "|" ++ signaling ++ "|" ++ iceServers

                    else
                        ""
                   )

        Local ->
            "Local"


icon : Backend -> Html msg
icon via =
    Util.icon
        (case via of
            Edrys ->
                "icon-edrys icon-xs"

            GUN _ ->
                "icon-gundb icon-xs"

            NoStr _ ->
                "icon-nostr icon-xs"

            MQTT _ ->
                "icon-mqtt icon-xs"

            Torrent _ ->
                "icon-torrent icon-xs"

            IPFS _ ->
                "icon-ipfs icon-xs"

            -- Jitsi _ ->
            --     "icon-jitsi icon-xs"
            -- Matrix _ ->
            --     "icon-matrix icon-xs"
            PubNub _ ->
                "icon-pubnub icon-xs"

            Ably _ ->
                "icon-ably icon-xs"

            P2PT _ ->
                "icon-p2pt icon-xs"

            WebSocket _ ->
                "icon-websocket icon-xs"

            PeerJS _ ->
                "icon-peerjs icon-xs"

            SimplePeer _ ->
                "icon-webrtc icon-xs"

            Local ->
                "icon-pencil icon-xs"
        )
        [ Attr.class "lia-sync-icon" ]


{-| A handful of short, hand-picked tags describing a backend's key
properties, distilled from the longer prose in `infoOn`. Used to render the
small pill badges in the backend picker.
-}
badges : Backend -> List String
badges via =
    case via of
        Edrys ->
            [ "Embedded platform", "No setup" ]

        GUN _ ->
            [ "Decentralized", "Self-hostable", "WebSocket", "Public relays" ]

        NoStr _ ->
            [ "Relay based", "Open protocol", "WebSocket", "WebRTC", "Public relays" ]

        MQTT _ ->
            [ "Broker based", "Custom brokers", "WebSocket", "WebRTC", "Public relays" ]

        Torrent _ ->
            [ "BitTorrent", "Tracker based", "WebSocket", "WebRTC", "Public relays" ]

        IPFS _ ->
            [ "Peer-to-peer", "Decentralized", "WebSocket", "WebRTC", "Public relays" ]

        PubNub _ ->
            [ "Managed service", "Account required", "HTTP", "Dedicated infra" ]

        Ably _ ->
            [ "Managed service", "Account required", "WebSocket", "Dedicated infra" ]

        P2PT _ ->
            [ "WebTorrent", "Tracker based", "WebSocket", "WebRTC", "Public relays" ]

        WebSocket _ ->
            [ "Self-hostable", "Experimental", "Dedicated infra" ]

        PeerJS _ ->
            [ "WebRTC", "Public relays" ]

        SimplePeer _ ->
            [ "WebRTC", "Self-hostable", "Dedicated infra" ]

        Local ->
            [ "Offline", "No network" ]


badge : String -> Html msg
badge text =
    Html.span [ Attr.class "lia-badge" ] [ Html.text text ]


{-| A one-line description shown next to the backend's icon and name, above
the badges. Kept short on purpose — the longer explanation follows below.
-}
tagline : Backend -> String
tagline via =
    case via of
        Edrys ->
            "Embedded remote-teaching platform, no setup required."

        GUN _ ->
            "Small, fast real-time database for syncing data."

        NoStr _ ->
            "Relay-based open protocol for decentralized exchange."

        MQTT _ ->
            "Broker-based realtime communication."

        Torrent _ ->
            "BitTorrent trackers used for WebRTC signaling."

        IPFS _ ->
            "Peer-to-peer hypermedia protocol for decentralized data."

        PubNub _ ->
            "Managed real-time messaging platform."

        Ably _ ->
            "Managed real-time messaging with a global edge network."

        P2PT _ ->
            "WebTorrent trackers used for WebRTC signaling."

        WebSocket _ ->
            "Full-duplex communication over your own WebSocket server."

        PeerJS _ ->
            "Simplified WebRTC peer-to-peer data channels."

        SimplePeer _ ->
            "Minimal WebRTC library for direct peer connections."

        Local ->
            "Offline notes, stored only in this browser."


fromString : String -> Maybe Backend
fromString via =
    case via |> String.split "|" |> mapHead String.toLower of
        [ "edrys" ] ->
            Just Edrys

        [ "nostr" ] ->
            Just (NoStr { relayUrls = "", turnConfig = "" })

        [ "nostr", relayUrls ] ->
            Just (NoStr { relayUrls = relayUrls, turnConfig = "" })

        [ "nostr", relayUrls, turnConfig ] ->
            Just (NoStr { relayUrls = relayUrls, turnConfig = turnConfig })

        [ "mqtt" ] ->
            Just (MQTT { relayUrls = "", turnConfig = "" })

        [ "mqtt", relayUrls ] ->
            Just (MQTT { relayUrls = relayUrls, turnConfig = "" })

        [ "mqtt", relayUrls, turnConfig ] ->
            Just (MQTT { relayUrls = relayUrls, turnConfig = turnConfig })

        [ "ipfs" ] ->
            Just (IPFS { turnConfig = "" })

        [ "ipfs", turnConfig ] ->
            Just (IPFS { turnConfig = turnConfig })

        [ "torrent" ] ->
            Just (Torrent { relayUrls = "", turnConfig = "" })

        [ "torrent", relayUrls ] ->
            Just (Torrent { relayUrls = relayUrls, turnConfig = "" })

        [ "torrent", relayUrls, turnConfig ] ->
            Just (Torrent { relayUrls = relayUrls, turnConfig = turnConfig })

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

        [ "ably" ] ->
            Just <| Ably { apiKey = "", persistent = False }

        [ "ably", "f" ] ->
            Just <| Ably { apiKey = "", persistent = False }

        [ "ably", "f", apiKey ] ->
            Just <| Ably { apiKey = apiKey, persistent = False }

        [ "ably", "t" ] ->
            Just <| Ably { apiKey = "", persistent = True }

        [ "ably", "t", apiKey ] ->
            Just <| Ably { apiKey = apiKey, persistent = True }

        [ "ably", apiKey ] ->
            Just <| Ably { apiKey = apiKey, persistent = False }

        [ "websocket" ] ->
            Just (WebSocket { url = "" })

        [ "websocket", url ] ->
            Just (WebSocket { url = url })

        [ "peerjs" ] ->
            Just (PeerJS { host = "", port_ = "", path = "", iceServers = "" })

        [ "peerjs", host ] ->
            Just (PeerJS { host = host, port_ = "", path = "", iceServers = "" })

        [ "peerjs", host, port_, path, iceServers ] ->
            Just (PeerJS { host = host, port_ = port_, path = path, iceServers = iceServers })

        [ "simplepeer" ] ->
            Just (SimplePeer { signaling = "", iceServers = "" })

        [ "simplepeer", signaling ] ->
            Just (SimplePeer { signaling = signaling, iceServers = "" })

        [ "simplepeer", signaling, iceServers ] ->
            Just (SimplePeer { signaling = signaling, iceServers = iceServers })

        [ "local" ] ->
            Just Local

        _ ->
            Nothing


mapHead : (a -> a) -> List a -> List a
mapHead fn list =
    case list of
        x :: xs ->
            fn x :: xs

        _ ->
            list


line : Html msg
line =
    Html.hr [ Attr.style "margin" "5px 0px" ] []


info : Html msg
info =
    Html.p
        []
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
    Html.p [] <|
        case ( about, supported ) of
            ( Edrys, _ ) ->
                [ link "Edrys" "https://edrys-labs.github.io"
                , Html.text " is an open, modular remote-teaching platform. The site linked here runs "
                , link "edrys-Lite" "https://github.com/edrys-labs/edrys-Lite"
                , Html.text ", a serverless, browser-only rewrite that syncs directly between peers over WebTorrent — no backend server required. "
                , Html.text "It is a great platform for building remote labs and share them by using only a browser locally. "
                , Html.text "Thus, this synchronization will only work, if you are within an Edrys classroom, for more information try the following link: "
                , link "https://github.com/edrys-labs" "https://github.com/edrys-labs"
                , Html.text ". Additionally, your course has to be loaded via the "
                , link "module-liascript" "https://github.com/edrys-labs/module-liascript"
                , Html.text "."
                ]

            ( GUN _, _ ) ->
                [ link "GunDB" "https://gun.eco"
                , Html.text " is a small, easy, and fast real-time database for syncing data across various users, talking to relay servers over "
                , link "WebSocket" "https://developer.mozilla.org/en-US/docs/Web/API/WebSocket"
                , Html.text ". You can use the default relay servers hosted at "
                , link Const.gunDB_ServerURL Const.gunDB_ServerURL
                , Html.text ", themselves community-hosted volunteer relays, not run by LiaScript — or pick others, or add your own, from the list "
                , link "here" "https://github.com/amark/gun/wiki/volunteer.dht"
                , Html.text ". The implementation of this classroom can be found "
                , link "here" "https://github.com/LiaScript/LiaScript/tree/development/src/typescript/sync/Gun"
                , Html.text ". Since these are free, community-run services, we cannot guarantee your messages will be stored forever or that a relay stays online — if you need certainty, host your own GunDB instance and point the URL below at it."
                ]

            ( IPFS _, _ ) ->
                [ Html.text "Despite the name, this strategy doesn't use the classic "
                , link "IPFS" "https://ipfs.tech"
                , Html.text " file-storage network — under the hood it runs on "
                , link "Waku" "https://waku.org"
                , Html.text ", a "
                , link "libp2p" "https://libp2p.io"
                , Html.text "-based decentralized publish/subscribe messaging protocol, purely to find peers and exchange the WebRTC handshake. "
                , Html.text "It has the least relay redundancy of the decentralized strategies offered here (behind MQTT and BitTorrent), so expect connections to occasionally take longer to establish."
                ]

            ( NoStr _, _ ) ->
                [ link "NoStr" "https://nostr.com"
                , Html.text " is a decentralized protocol designed for creating a censorship-resistant global social network."
                , Html.text "The acronym stands for \"Notes and Other Stuff Transmitted by Relays\""
                , Html.text "It operates through a network of clients and relays, where clients are interfaces for users to interact with the network, and relays act as databases storing and transmitting data. "
                , Html.text "Users are identified by public keys, and all events (like messages or updates) are signed for verification. "
                , Html.text "NoStr's decentralization ensures resilience against censorship and single points of failure, as data is distributed across multiple nodes. "
                , Html.text "It's an open standard, allowing anyone to build upon it, and its design promotes freedom of speech and global accessibility."
                , trysteroRelayHint "relay"
                ]

            ( MQTT _, _ ) ->
                [ link "MQTT (Message Queuing Telemetry Transport)" "https://mqtt.org"
                , Html.text " is a lightweight, publish-subscribe messaging protocol designed for machine-to-machine (M2M) communication, particularly in the Internet of Things (IoT) and industrial IoT (IIoT) contexts. "
                , Html.text "It enables devices to efficiently publish and subscribe to data over the Internet, facilitating communication between embedded devices, sensors, and industrial PLCs. "
                , Html.text "MQTT normally runs directly over TCP, but browsers can't open raw TCP sockets — so this backend speaks MQTT-over-WebSocket instead, which is why broker URLs look like "
                , Html.code [ Attr.class "lia-code lia-code--inline" ] [ Html.text "wss://" ]
                , Html.text " addresses rather than a plain host:port. "
                , Html.text "The protocol is event-driven, with a broker managing the distribution of messages between publishers and subscribers based on topics. "
                , Html.text "This decoupling allows for scalable and reliable data exchange, making MQTT a standard for IoT data transmission."
                , trysteroRelayHint "broker"
                ]

            ( Torrent _, _ ) ->
                [ link "WebTorrent" "https://webtorrent.io"
                , Html.text " trackers are the same kind of signaling servers "
                , link "BitTorrent" "https://en.wikipedia.org/wiki/BitTorrent"
                , Html.text " clients use to find peers sharing a file — here they're repurposed to bootstrap real-time connections for chat and quizzes instead; no file-sharing involved."
                , trysteroRelayHint "tracker"
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
                , Html.text " is a managed real-time communication platform — no server of your own to run. "
                , Html.text "LiaScript ships with a shared, free-tier keyset so this works immediately, but its capacity is split across everyone who leaves the fields below empty. "
                , Html.text "Unlike Ably or GunDB here, this backend has no persistent-storage option — the room's state only exists while participants are connected. "
                , Html.text "If you'll use this regularly, create your own free account instead (no credit card required, capped at 3 keysets) — full setup steps are in PubNub's own docs "
                , link "here" "https://www.pubnub.com/docs/general/setup/account-setup"
                , Html.text "."
                ]

            ( Ably _, _ ) ->
                [ link "Ably" "https://ably.com"
                , Html.text " is a managed real-time messaging platform with a global edge network — no server of your own to run. "
                , Html.text "LiaScript ships with a shared, free-tier API key so this works immediately, but its capacity (200 concurrent connections, 6M messages/month) is split across everyone who leaves the field below empty. "
                , Html.text "If you'll use this regularly, create your own free Ably account instead — no credit card required."
                ]

            ( WebSocket _, _ ) ->
                [ link "WebSocket" "https://developer.mozilla.org/en-US/docs/Web/API/WebSocket"
                , Html.text " provides full-duplex communication over a single TCP connection. "
                , Html.text "This backend only works with a server that speaks the "
                , link "y-websocket" "https://github.com/yjs/y-websocket"
                , Html.text " wire protocol — either y-websocket's own reference server or any compatible implementation, self-hosted; there's no public default to fall back to."
                ]

            ( PeerJS _, _ ) ->
                [ link "PeerJS" "https://peerjs.com"
                , Html.text " simplifies WebRTC peer-to-peer data channel connections. "
                , Html.text "By default it uses the free PeerJS Cloud signaling server — no setup required. "
                , Html.text "For production use or larger groups, host your own "
                , link "PeerServer" "https://github.com/peers/peerjs-server"
                , Html.text " instead and point the fields below at it. "
                , Html.text "The implementation can be found "
                , link "here" "https://github.com/LiaScript/LiaScript/tree/development/src/typescript/sync/PeerJS"
                , Html.text "."
                ]

            ( SimplePeer _, _ ) ->
                [ link "SimplePeer" "https://github.com/feross/simple-peer"
                , Html.text " is a minimal WebRTC library for direct peer-to-peer data connections in the browser. "
                , Html.text "It uses a signaling server only for peer discovery; actual data flows directly between browsers. "
                , Html.text "A signaling server URL is "
                , Html.strong [] [ Html.text "required" ]
                , Html.text " — the previously public default server is no longer available. "
                , Html.text "Host your own — the signaling server bundled with "
                , link "y-webrtc" "https://github.com/yjs/y-webrtc"
                , Html.text " works fine here too, since it's a generic topic-based relay rather than something specific to that protocol. "
                , Html.text "The implementation can be found "
                , link "here" "https://github.com/LiaScript/LiaScript/tree/development/src/typescript/sync/SimplePeer"
                , Html.text "."
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
                , Html.text "Thus, you have to provide one or more WebSocket tracker URLs, starting with "
                , Html.code [ Attr.class "lia-code lia-code--inline" ] [ Html.text "wss://" ]
                , Html.text ", separated by commas if you list several — there is no built-in default, so at least one is required."
                ]

            ( Local, _ ) ->
                [ Html.text "This is a purely local classroom — nothing is sent over the network. "
                , Html.text "Your notes are written to this browser's storage only and never shared with anyone."
                ]


trysteroRelayHint : String -> Html msg
trysteroRelayHint kind =
    Html.text (" This backend uses the " ++ kind ++ " only to discover peers and exchange the WebRTC handshake — the actual chat and quiz data still flows directly between browsers over WebRTC.")


link : String -> String -> Html msg
link title url =
    Html.a [ Attr.href url, Attr.target "blank" ] [ Html.text title ]


view : Bool -> Backend -> Html Msg
view editable backend =
    case backend of
        GUN { urls, persistent } ->
            details
                [ input
                    { active = editable
                    , type_ = "text"
                    , msg = InputGun
                    , value = urls
                    , placeholder = "https://gun1.server, https://gun2.server, ..."
                    , label = Html.text "relay server"
                    , autocomplete = Just "gun-server"
                    }
                , fieldHint "Add multiple relay servers, separated by commas."
                , checkbox
                    { active = editable
                    , value = persistent
                    , msg = CheckboxGun
                    , label = Html.text "persistent storage"
                    }
                , fieldHint "Writes the room's state to the relay server(s) so it survives after everyone disconnects — nothing is ever cached in your own browser either way. Left unchecked, the room only exists in the relay's memory and disappears once it empties."
                ]

        NoStr { relayUrls, turnConfig } ->
            trysteroSettings editable "relay" "wss://relay.damus.io, wss://nos.lol, ..." relayUrls turnConfig

        MQTT { relayUrls, turnConfig } ->
            trysteroSettings editable "broker" "wss://broker.emqx.io:8084/mqtt, wss://broker.hivemq.com:8884/mqtt, ..." relayUrls turnConfig

        Torrent { relayUrls, turnConfig } ->
            trysteroSettings editable "tracker" "wss://tracker.openwebtorrent.com, wss://tracker.webtorrent.dev, ..." relayUrls turnConfig

        IPFS { turnConfig } ->
            details
                [ input
                    { active = editable
                    , type_ = "text"
                    , msg = InputTrystero "turn"
                    , value = turnConfig
                    , placeholder = "[{\"urls\":\"turn:turn.example.com\",\"username\":\"user\",\"credential\":\"pass\"}]"
                    , label = Html.text "TURN servers as JSON (optional)"
                    , autocomplete = Just "trystero-turn"
                    }
                , fieldHint "Waku only finds peers and exchanges the WebRTC handshake — the actual chat and quiz data flows directly between browsers. Add TURN servers here if participants sit behind firewalls/NATs that block a direct WebRTC connection; there's no separate relay URL to configure for this strategy."
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
            details
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
                , fieldHint "Leave both empty to use LiaScript's shared keyset. For regular use, create your own free App/Keyset in the PubNub dashboard and paste its publish and subscribe key here instead, so you're not sharing capacity with everyone else."
                ]

        Ably { apiKey, persistent } ->
            details
                [ input
                    { active = editable
                    , type_ = "password"
                    , msg = InputAbly
                    , label = Html.text "API key"
                    , value = apiKey
                    , placeholder = "xVLyHw.XXXX:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                    , autocomplete = Just "ably-apiKey"
                    }
                , fieldHint "Leave empty to use LiaScript's shared key. For regular use, create a free App in your own Ably dashboard and paste one of its API keys here instead, so you're not sharing capacity with everyone else."
                , checkbox
                    { active = editable
                    , value = persistent
                    , msg = CheckboxAbly
                    , label = Html.text "persistent storage"
                    }
                , fieldHint "Uses Ably's LiveObjects to keep the chat and modified code available after everyone disconnects, retained for up to 90 days by default. Left unchecked, the state is dropped once the room empties."
                ]

        P2PT urls ->
            details
                [ input
                    { active = editable
                    , type_ = "text"
                    , msg = InputP2PT
                    , value = urls
                    , placeholder = "wss://tracker.openwebtorrent.com, wss://tracker.webtorrent.dev, ..."
                    , label = Html.text "WebTorrent tracker URLs (required, comma-separated)"
                    , autocomplete = Just "websocket-urls"
                    }
                ]

        WebSocket { url } ->
            details
                [ input
                    { active = editable
                    , type_ = "text"
                    , msg = InputWebSocket
                    , value = url
                    , placeholder = "wss://your-server.example.com"
                    , label = Html.text "server URL"
                    , autocomplete = Just "websocket-url"
                    }
                , fieldHint "Required — the full WebSocket URL of your y-websocket-compatible server."
                ]

        PeerJS { host, port_, path, iceServers } ->
            details
                [ input
                    { active = editable
                    , type_ = "text"
                    , msg = InputPeerJS "host"
                    , value = host
                    , placeholder = "my-peerjs-server.example.com"
                    , label = Html.text "server host (optional)"
                    , autocomplete = Just "peerjs-host"
                    }
                , input
                    { active = editable
                    , type_ = "text"
                    , msg = InputPeerJS "port"
                    , value = port_
                    , placeholder = "443"
                    , label = Html.text "server port (optional)"
                    , autocomplete = Just "peerjs-port"
                    }
                , input
                    { active = editable
                    , type_ = "text"
                    , msg = InputPeerJS "path"
                    , value = path
                    , placeholder = "/"
                    , label = Html.text "server path (optional)"
                    , autocomplete = Just "peerjs-path"
                    }
                , fieldHint "All three fields above are optional — leave them empty to use the free PeerJS Cloud signaling server."
                , input
                    { active = editable
                    , type_ = "text"
                    , msg = InputPeerJS "ice"
                    , value = iceServers
                    , placeholder = "[{\"urls\":\"stun:stun.l.google.com:19302\"}]"
                    , label = Html.text "ICE / TURN servers as JSON (optional)"
                    , autocomplete = Just "peerjs-ice"
                    }
                , iceServersHint
                ]

        SimplePeer { signaling, iceServers } ->
            details
                [ input
                    { active = editable
                    , type_ = "text"
                    , msg = InputSimplePeer "signaling"
                    , value = signaling
                    , placeholder = "wss://your-signaling-server.example.com"
                    , label = Html.text "signaling server URLs (required, comma-separated)"
                    , autocomplete = Just "simplepeer-signaling"
                    }
                , fieldHint "Required. Multiple comma-separated URLs can be provided for redundancy."
                , input
                    { active = editable
                    , type_ = "text"
                    , msg = InputSimplePeer "ice"
                    , value = iceServers
                    , placeholder = "[{\"urls\":\"stun:stun.l.google.com:19302\"}]"
                    , label = Html.text "ICE / TURN servers as JSON (optional)"
                    , autocomplete = Just "simplepeer-ice"
                    }
                , iceServersHint
                ]

        _ ->
            Html.text ""


trysteroSettings : Bool -> String -> String -> String -> String -> Html Msg
trysteroSettings editable kind placeholder relayUrls turnConfig =
    details
        [ input
            { active = editable
            , type_ = "text"
            , msg = InputTrystero "relay"
            , value = relayUrls
            , placeholder = placeholder
            , label = Html.text (kind ++ " URLs (optional)")
            , autocomplete = Just "trystero-relay"
            }
        , fieldHint ("Comma-separated. Leave empty to use Trystero's built-in default " ++ kind ++ "s.")
        , input
            { active = editable
            , type_ = "text"
            , msg = InputTrystero "turn"
            , value = turnConfig
            , placeholder = "[{\"urls\":\"turn:turn.example.com\",\"username\":\"user\",\"credential\":\"pass\"}]"
            , label = Html.text "TURN servers as JSON (optional)"
            , autocomplete = Just "trystero-turn"
            }
        , fieldHint "Only needed if some participants sit behind firewalls/NATs that block a direct WebRTC connection."
        ]


{-| A small greyed-out caption placed right under a field in "Infrastructure
settings" to explain what it does, without bloating the longer `infoOn` prose
above.
-}
fieldHint : String -> Html msg
fieldHint text =
    fieldHintHtml [ Html.text text ]


{-| Like `fieldHint`, but for the (rare) case where the caption itself needs
a link or inline code, e.g. `iceServersHint`.
-}
fieldHintHtml : List (Html msg) -> Html msg
fieldHintHtml content =
    Html.p
        [ Attr.style "font-size" "smaller"
        , Attr.style "opacity" "0.7"
        , Attr.style "margin-block-start" "0.35rem"
        , Attr.style "margin-block-end" "0"
        ]
        content


{-| Shared by PeerJS and SimplePeer, whose "ICE / TURN servers" fields are
identical in shape and meaning.
-}
iceServersHint : Html msg
iceServersHint =
    fieldHintHtml
        [ Html.text "Optional. Takes a JSON array of "
        , link "RTCIceServer" "https://developer.mozilla.org/en-US/docs/Web/API/RTCIceServer"
        , Html.text " objects, e.g. "
        , Html.code [ Attr.class "lia-code lia-code--inline" ] [ Html.text "[{\"urls\":\"stun:stun.l.google.com:19302\"}]" ]
        , Html.text ". Add TURN servers to improve connectivity in restricted networks."
        ]


details options =
    Html.details [ Attr.style "margin-block-start" "2rem" ]
        [ Html.summary
            [ Attr.style "cursor" "pointer"
            , Attr.style "font-weight" "bold"
            , Attr.style "color" "white"
            ]
            [ Html.text "Infrastructure settings"
            ]
        , Html.div [ Attr.style "padding-right" "3.5rem" ]
            options
        ]


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
            , Attr.style "margin-block-start" "2rem"
            , Attr.style "width" "100%"
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
                |> List.append
                    (case autocomplete of
                        Just autoc ->
                            [ Attr.name autoc, Attr.attribute "autocomplete" autoc ]

                        Nothing ->
                            []
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
    Html.label [ Attr.style "margin-block-start" "2rem", Attr.class "lia-label" ]
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
    | InputAbly String
    | CheckboxAbly
      --| InputMatrix String String
      --| InputJitsi String
    | InputP2PT String
    | InputWebSocket String
    | InputPeerJS String String
    | InputSimplePeer String String
    | InputTrystero String String


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

        ( InputAbly new, Ably data ) ->
            Ably { data | apiKey = new }

        ( CheckboxAbly, Ably data ) ->
            Ably { data | persistent = not data.persistent }

        -- ( InputMatrix "url" new, Matrix data ) ->
        --     Matrix { data | baseURL = new }
        -- ( InputMatrix "user" new, Matrix data ) ->
        --     Matrix { data | userId = new }
        -- ( InputMatrix "token" new, Matrix data ) ->
        --     Matrix { data | accessToken = new }
        ( InputP2PT urls, P2PT _ ) ->
            P2PT urls

        ( InputWebSocket url, WebSocket _ ) ->
            WebSocket { url = url }

        ( InputPeerJS "host" v, PeerJS data ) ->
            PeerJS { data | host = v }

        ( InputPeerJS "port" v, PeerJS data ) ->
            PeerJS { data | port_ = v }

        ( InputPeerJS "path" v, PeerJS data ) ->
            PeerJS { data | path = v }

        ( InputPeerJS "ice" v, PeerJS data ) ->
            PeerJS { data | iceServers = v }

        ( InputSimplePeer "signaling" v, SimplePeer data ) ->
            SimplePeer { data | signaling = v }

        ( InputSimplePeer "ice" v, SimplePeer data ) ->
            SimplePeer { data | iceServers = v }

        ( InputTrystero "relay" v, NoStr data ) ->
            NoStr { data | relayUrls = v }

        ( InputTrystero "turn" v, NoStr data ) ->
            NoStr { data | turnConfig = v }

        ( InputTrystero "relay" v, MQTT data ) ->
            MQTT { data | relayUrls = v }

        ( InputTrystero "turn" v, MQTT data ) ->
            MQTT { data | turnConfig = v }

        ( InputTrystero "relay" v, Torrent data ) ->
            Torrent { data | relayUrls = v }

        ( InputTrystero "turn" v, Torrent data ) ->
            Torrent { data | turnConfig = v }

        ( InputTrystero "turn" v, IPFS data ) ->
            IPFS { data | turnConfig = v }

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

        ( Ably _, Ably _ ) ->
            True

        -- ( Jitsi _, Jitsi _ ) ->
        --     True
        ( P2PT _, P2PT _ ) ->
            True

        ( WebSocket _, WebSocket _ ) ->
            True

        ( PeerJS _, PeerJS _ ) ->
            True

        ( SimplePeer _, SimplePeer _ ) ->
            True

        ( NoStr _, NoStr _ ) ->
            True

        ( MQTT _, MQTT _ ) ->
            True

        ( Torrent _, Torrent _ ) ->
            True

        ( IPFS _, IPFS _ ) ->
            True

        _ ->
            a == b
