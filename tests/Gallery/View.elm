module Gallery.View exposing (suite)

{-| Rendering of a gallery: a row of clickable thumbnails and, if a media is
selected in `gallery_vector`, a lightbox modal with prev/next controls.
-}

import Array
import Dict
import Expect
import Html.Attributes as Attr
import I18n.Translations exposing (Lang(..))
import Json.Encode as JE
import Lia.Markdown.Gallery.Types exposing (Gallery, Vector)
import Lia.Markdown.Gallery.Update exposing (Msg(..))
import Lia.Markdown.Gallery.View exposing (view)
import Lia.Markdown.Inline.Config as Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inline(..), Reference(..))
import Lia.Settings.Types exposing (Mode(..))
import Test exposing (Test, describe, test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector exposing (attribute, class, classes, tag)


config : Config ()
config =
    Config.init
        { mode = Textbook
        , visible = Nothing
        , slide = 0
        , speaking = Nothing
        , paused = Nothing
        , lang = En
        , theme = Nothing
        , light = True
        , tooltips = False
        , hideVideoComments = False
        , media = Dict.empty
        , scripts = Array.empty
        , translations = Nothing
        , formulas = Nothing
        , sync = Nothing
        }


url : Int -> String
url i =
    "http://example.com/" ++ String.fromInt i ++ ".png"


{-| Gallery number `id` with `n` images.
-}
gallery : Int -> Int -> Gallery
gallery id n =
    { media =
        List.range 0 (n - 1)
            |> List.map (\i -> Ref (Image [ Chars ("alt" ++ String.fromInt i) [] ] (url i) Nothing) [])
    , id = id
    }


render : Vector -> Gallery -> Query.Single (Msg ())
render vector =
    view config vector [] >> Query.fromHtml


keyDown : Int -> ( String, JE.Value )
keyDown code =
    Event.custom "keydown" (JE.object [ ( "keyCode", JE.int code ), ( "shiftKey", JE.bool False ) ])


{-| The gallery div is always the last child of the rendered wrapper. It is
located by position, since `annotation` sets its class as a plain `class`
attribute, which `Test.Html` selectors cannot match.
-}
galleryDiv : Query.Single (Msg ()) -> Query.Single (Msg ())
galleryDiv =
    Query.children [] >> Query.index -1


thumbnails : Query.Single (Msg ()) -> Query.Multiple (Msg ())
thumbnails =
    galleryDiv >> Query.findAll [ class "lia-lightbox" ]


clickArea : Int -> Query.Single (Msg ()) -> Query.Single (Msg ())
clickArea i =
    thumbnails >> Query.index i >> Query.find [ class "lia-lightbox__clickarea" ]


modalButton : String -> Query.Single (Msg ()) -> Query.Single (Msg ())
modalButton cls =
    Query.find [ class "lia-modal" ] >> Query.find [ class cls ]


suite : Test
suite =
    describe "Lia.Markdown.Gallery.View"
        [ describe "thumbnails"
            [ test "one lightbox per media" <|
                \_ ->
                    render (Array.fromList [ -1 ]) (gallery 0 3)
                        |> thumbnails
                        |> Query.count (Expect.equal 3)
            , test "each thumbnail shows its media" <|
                \_ ->
                    render (Array.fromList [ -1 ]) (gallery 0 3)
                        |> thumbnails
                        |> Query.index 2
                        |> Query.has [ tag "img", attribute (Attr.src (url 2)) ]
            , test "the gallery carries its annotations next to the lia-gallery class" <|
                \_ ->
                    view config (Array.fromList [ -1 ]) [ ( "title", "my gallery" ) ] (gallery 0 2)
                        |> Query.fromHtml
                        |> galleryDiv
                        |> Query.has [ attribute (Attr.attribute "title" "my gallery") ]
            , test "the click area is an accessible button" <|
                \_ ->
                    render (Array.fromList [ -1 ]) (gallery 0 2)
                        |> clickArea 1
                        |> Query.has
                            [ attribute (Attr.attribute "role" "button")
                            , attribute (Attr.attribute "aria-label" "zoom media")
                            , attribute (Attr.tabindex 0)
                            ]
            , test "the click area contains the zoom icon" <|
                \_ ->
                    render (Array.fromList [ -1 ]) (gallery 0 2)
                        |> clickArea 0
                        |> Query.has [ tag "i", classes [ "icon", "icon-zoom", "lia-lightbox__icon" ] ]
            , test "clicking a thumbnail opens it" <|
                \_ ->
                    render (Array.fromList [ -1, -1 ]) (gallery 1 3)
                        |> clickArea 2
                        |> Event.simulate Event.click
                        |> Event.expect (Show 1 2)
            , test "enter on a thumbnail opens it" <|
                \_ ->
                    render (Array.fromList [ -1, -1 ]) (gallery 1 3)
                        |> clickArea 1
                        |> Event.simulate (keyDown 13)
                        |> Event.expect (Show 1 1)
            , test "space on a thumbnail opens it" <|
                \_ ->
                    render (Array.fromList [ -1, -1 ]) (gallery 1 3)
                        |> clickArea 0
                        |> Event.simulate (keyDown 32)
                        |> Event.expect (Show 1 0)
            ]
        , describe "closed lightbox"
            [ test "no modal while the slot is -1" <|
                \_ ->
                    render (Array.fromList [ -1 ]) (gallery 0 2)
                        |> Query.hasNot [ class "lia-modal" ]
            , test "no modal if the gallery has no slot" <|
                \_ ->
                    render Array.empty (gallery 0 2)
                        |> Query.hasNot [ class "lia-modal" ]
            , test "no modal if the slot points behind the last media" <|
                \_ ->
                    render (Array.fromList [ 2 ]) (gallery 0 2)
                        |> Query.hasNot [ class "lia-modal" ]
            , test "only the slot of the own gallery counts" <|
                \_ ->
                    render (Array.fromList [ 1, -1 ]) (gallery 1 2)
                        |> Query.hasNot [ class "lia-modal" ]
            ]
        , describe "open lightbox"
            [ test "shows a modal next to the gallery" <|
                \_ ->
                    render (Array.fromList [ 1 ]) (gallery 0 3)
                        |> Query.children []
                        |> Expect.all
                            [ Query.count (Expect.equal 2)
                            , Query.index 0 >> Query.has [ class "lia-modal" ]
                            , Query.index 1 >> Query.findAll [ class "lia-lightbox" ] >> Query.count (Expect.equal 3)
                            ]
            , test "the modal shows the selected media" <|
                \_ ->
                    render (Array.fromList [ 1 ]) (gallery 0 3)
                        |> Query.find [ class "lia-modal__content" ]
                        |> Query.has [ tag "img", attribute (Attr.src (url 1)) ]
            , test "next shows the following media" <|
                \_ ->
                    render (Array.fromList [ 1 ]) (gallery 0 3)
                        |> modalButton "lia-modal__ctrl-next"
                        |> Event.simulate Event.click
                        |> Event.expect (Show 0 2)
            , test "prev shows the preceding media" <|
                \_ ->
                    render (Array.fromList [ 1 ]) (gallery 0 3)
                        |> modalButton "lia-modal__ctrl-prev"
                        |> Event.simulate Event.click
                        |> Event.expect (Show 0 0)
            , test "next is disabled at the last media" <|
                \_ ->
                    render (Array.fromList [ 2 ]) (gallery 0 3)
                        |> modalButton "lia-modal__ctrl-next"
                        |> Query.has [ Selector.disabled True ]
            , test "prev is disabled at the first media" <|
                \_ ->
                    render (Array.fromList [ 0 ]) (gallery 0 3)
                        |> modalButton "lia-modal__ctrl-prev"
                        |> Query.has [ Selector.disabled True ]
            , test "next and prev are enabled in between" <|
                \_ ->
                    render (Array.fromList [ 1 ]) (gallery 0 3)
                        |> Query.find [ class "lia-modal__controls" ]
                        |> Query.findAll [ Selector.disabled True ]
                        |> Query.count (Expect.equal 0)
            , test "next and prev are translated" <|
                \_ ->
                    render (Array.fromList [ 1 ]) (gallery 0 3)
                        |> Query.find [ class "lia-modal__controls" ]
                        |> Expect.all
                            [ Query.find [ class "lia-modal__ctrl-next" ] >> Query.has [ attribute (Attr.title "next") ]
                            , Query.find [ class "lia-modal__ctrl-prev" ] >> Query.has [ attribute (Attr.title "previous") ]
                            ]
            , test "the close button closes the own gallery" <|
                \_ ->
                    render (Array.fromList [ -1, 0 ]) (gallery 1 2)
                        |> modalButton "lia-modal__close"
                        |> Query.find [ tag "button" ]
                        |> Event.simulate Event.click
                        |> Event.expect (Close 1)
            , test "clicking beside the modal closes it" <|
                \_ ->
                    render (Array.fromList [ 0 ]) (gallery 0 2)
                        |> modalButton "lia-modal__outer"
                        |> Event.simulate Event.click
                        |> Event.expect (Close 0)
            , test "escape closes it" <|
                \_ ->
                    render (Array.fromList [ 0 ]) (gallery 0 2)
                        |> Query.find [ class "lia-modal" ]
                        |> Event.simulate (keyDown 27)
                        |> Event.expect (Close 0)
            ]
        ]
