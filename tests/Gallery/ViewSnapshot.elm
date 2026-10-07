module Gallery.ViewSnapshot exposing (suite)

{-| Exact markup of a two-image gallery in every lightbox state, recorded
from the implementation before the refactoring.

These snapshots also contain the markup of `Lia.Markdown.Inline.View` (the
images) and of `Lia.Utils.modal`. If one of those is changed on purpose,
re-record the snapshots here; if only the gallery modules were touched, the
snapshots must not change.

-}

import Array
import Dict
import HtmlSnapshot
import I18n.Translations exposing (Lang(..))
import Lia.Markdown.Gallery.Types exposing (Gallery)
import Lia.Markdown.Gallery.View exposing (view)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Config as Config exposing (Config)
import Lia.Markdown.Inline.Types exposing (Inline(..), Reference(..))
import Lia.Settings.Types exposing (Mode(..))
import Test exposing (Test, describe, test)


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


{-| An image followed by an oEmbed media, so that the different oEmbed
settings of thumbnails and of the lightbox overlay become visible.
-}
embedGallery : Gallery
embedGallery =
    { media =
        [ Ref (Image [ Chars "alt0" [] ] (url 0) Nothing) []
        , Ref (Embed [ Chars "video" [] ] "https://www.youtube.com/watch?v=abc" Nothing) []
        ]
    , id = 0
    }


snapshot : String -> List Int -> Parameters -> String -> Test
snapshot name vector attr expected =
    test name <|
        \_ ->
            view config (Array.fromList vector) attr (gallery 0 2)
                |> HtmlSnapshot.expect expected


suite : Test
suite =
    describe "Lia.Markdown.Gallery.View snapshots"
        [ snapshot "lightbox closed" [ -1 ] [] closed
        , snapshot "first media open: prev disabled" [ 0 ] [] first
        , snapshot "last media open: next disabled" [ 1 ] [] last
        , snapshot "slot behind the last media renders like closed" [ 2 ] [] outOfRange
        , snapshot "annotations are added to the gallery div" [ -1 ] [ ( "class", "wide" ), ( "title", "my gallery" ) ] annotated
        , test "oEmbed media: small thumbnail, scaled overlay" <|
            \_ ->
                view config (Array.fromList [ 1 ]) [] embedGallery
                    |> HtmlSnapshot.expect embedOpen
        ]


closed : String
closed =
    """<div>
    
    <div class="lia-gallery">
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt0" loading="lazy" onClick="window.LIA.img.click("http://example.com/0.png")" onerror="window.LIA.fetchError('img','http://example.com/0.png')" onload="window.LIA.img.load('http://example.com/0.png',this.width,this.height)" src="http://example.com/0.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt1" loading="lazy" onClick="window.LIA.img.click("http://example.com/1.png")" onerror="window.LIA.fetchError('img','http://example.com/1.png')" onload="window.LIA.img.load('http://example.com/1.png',this.width,this.height)" src="http://example.com/1.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
    </div>
</div>"""


first : String
first =
    """<div>
    <div class="lia-modal" aria-modal="true" role="dialog">
        <div class="lia-modal__inner">
            <div class="lia-modal__close">
                <button class="lia-btn lia-btn--transparent" aria-hidden="false" id="lia-modal__close" tabIndex="0" title="close modal">
                    <i class="icon icon-close lia-btn__icon" aria-hidden="true">
                    </i>
                </button>
            </div>
            <div class="lia-modal__content">
                <figure class="lia-figure">
                    <div class="lia-figure__media  lia-figure__zoom" style="background-image:url('http://example.com/0.png');" data-media-image="image" onmousemove="window.LIA.img.zoom(event)">
                        <img alt="alt0" onerror="window.LIA.fetchError('img','http://example.com/0.png')" onload="window.LIA.img.load('http://example.com/0.png',this.width,this.height)" src="http://example.com/0.png">
                    </div>
                    
                </figure>
            </div>
            <div class="lia-modal__controls">
                <button class="lia-btn lia-modal__ctrl-next lia-btn--transparent" aria-hidden="false" tabIndex="0" title="next">
                    <i class="icon icon-arrow-right lia-btn__icon" aria-hidden="true">
                    </i>
                </button>
                <button class="lia-btn lia-modal__ctrl-prev lia-btn--transparent" aria-hidden="false" tabIndex="0" title="previous" disabled>
                    <i class="icon icon-arrow-left lia-btn__icon" aria-hidden="true">
                    </i>
                </button>
            </div>
        </div>
        <div class="lia-modal__outer">
        </div>
    </div>
    <div class="lia-gallery">
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt0" loading="lazy" onClick="window.LIA.img.click("http://example.com/0.png")" onerror="window.LIA.fetchError('img','http://example.com/0.png')" onload="window.LIA.img.load('http://example.com/0.png',this.width,this.height)" src="http://example.com/0.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt1" loading="lazy" onClick="window.LIA.img.click("http://example.com/1.png")" onerror="window.LIA.fetchError('img','http://example.com/1.png')" onload="window.LIA.img.load('http://example.com/1.png',this.width,this.height)" src="http://example.com/1.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
    </div>
</div>"""


last : String
last =
    """<div>
    <div class="lia-modal" aria-modal="true" role="dialog">
        <div class="lia-modal__inner">
            <div class="lia-modal__close">
                <button class="lia-btn lia-btn--transparent" aria-hidden="false" id="lia-modal__close" tabIndex="0" title="close modal">
                    <i class="icon icon-close lia-btn__icon" aria-hidden="true">
                    </i>
                </button>
            </div>
            <div class="lia-modal__content">
                <figure class="lia-figure">
                    <div class="lia-figure__media  lia-figure__zoom" style="background-image:url('http://example.com/1.png');" data-media-image="image" onmousemove="window.LIA.img.zoom(event)">
                        <img alt="alt1" onerror="window.LIA.fetchError('img','http://example.com/1.png')" onload="window.LIA.img.load('http://example.com/1.png',this.width,this.height)" src="http://example.com/1.png">
                    </div>
                    
                </figure>
            </div>
            <div class="lia-modal__controls">
                <button class="lia-btn lia-modal__ctrl-next lia-btn--transparent" aria-hidden="false" tabIndex="0" title="next" disabled>
                    <i class="icon icon-arrow-right lia-btn__icon" aria-hidden="true">
                    </i>
                </button>
                <button class="lia-btn lia-modal__ctrl-prev lia-btn--transparent" aria-hidden="false" tabIndex="0" title="previous">
                    <i class="icon icon-arrow-left lia-btn__icon" aria-hidden="true">
                    </i>
                </button>
            </div>
        </div>
        <div class="lia-modal__outer">
        </div>
    </div>
    <div class="lia-gallery">
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt0" loading="lazy" onClick="window.LIA.img.click("http://example.com/0.png")" onerror="window.LIA.fetchError('img','http://example.com/0.png')" onload="window.LIA.img.load('http://example.com/0.png',this.width,this.height)" src="http://example.com/0.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt1" loading="lazy" onClick="window.LIA.img.click("http://example.com/1.png")" onerror="window.LIA.fetchError('img','http://example.com/1.png')" onload="window.LIA.img.load('http://example.com/1.png',this.width,this.height)" src="http://example.com/1.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
    </div>
</div>"""


outOfRange : String
outOfRange =
    """<div>
    
    <div class="lia-gallery">
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt0" loading="lazy" onClick="window.LIA.img.click("http://example.com/0.png")" onerror="window.LIA.fetchError('img','http://example.com/0.png')" onload="window.LIA.img.load('http://example.com/0.png',this.width,this.height)" src="http://example.com/0.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt1" loading="lazy" onClick="window.LIA.img.click("http://example.com/1.png")" onerror="window.LIA.fetchError('img','http://example.com/1.png')" onload="window.LIA.img.load('http://example.com/1.png',this.width,this.height)" src="http://example.com/1.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
    </div>
</div>"""


annotated : String
annotated =
    """<div>
    
    <div class="lia-gallery wide" title="my gallery">
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt0" loading="lazy" onClick="window.LIA.img.click("http://example.com/0.png")" onerror="window.LIA.fetchError('img','http://example.com/0.png')" onload="window.LIA.img.load('http://example.com/0.png',this.width,this.height)" src="http://example.com/0.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt1" loading="lazy" onClick="window.LIA.img.click("http://example.com/1.png")" onerror="window.LIA.fetchError('img','http://example.com/1.png')" onload="window.LIA.img.load('http://example.com/1.png',this.width,this.height)" src="http://example.com/1.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
    </div>
</div>"""


embedOpen : String
embedOpen =
    """<div>
    <div class="lia-modal" aria-modal="true" role="dialog">
        <div class="lia-modal__inner">
            <div class="lia-modal__close">
                <button class="lia-btn lia-btn--transparent" aria-hidden="false" id="lia-modal__close" tabIndex="0" title="close modal">
                    <i class="icon icon-close lia-btn__icon" aria-hidden="true">
                    </i>
                </button>
            </div>
            <div class="lia-modal__content">
                <figure class="lia-figure" style="height:auto;width:100%;">
                    <div class="lia-figure__media">
                        <a class="lia-link lia-print-only" href="https://www.youtube.com/watch?v=abc">
                            video
                        </a>
                        <lia-embed style="display:inline-block;height:auto;max-height:100%;width:100%;" data-attributes="{}" scale="0.76" url="https://www.youtube.com/watch?v=abc">
                        </lia-embed>
                        <figcaption class="lia-figure__caption">
                            <a class="lia-link" href="https://www.youtube.com/watch?v=abc" target="blank_">
                                https://www.youtube.com/watch?v=abc
                            </a>
                        </figcaption>
                    </div>
                </figure>
            </div>
            <div class="lia-modal__controls">
                <button class="lia-btn lia-modal__ctrl-next lia-btn--transparent" aria-hidden="false" tabIndex="0" title="next" disabled>
                    <i class="icon icon-arrow-right lia-btn__icon" aria-hidden="true">
                    </i>
                </button>
                <button class="lia-btn lia-modal__ctrl-prev lia-btn--transparent" aria-hidden="false" tabIndex="0" title="previous">
                    <i class="icon icon-arrow-left lia-btn__icon" aria-hidden="true">
                    </i>
                </button>
            </div>
        </div>
        <div class="lia-modal__outer">
        </div>
    </div>
    <div class="lia-gallery">
        <div class="lia-lightbox">
            <figure class="lia-figure">
                <div class="lia-figure__media" data-media-type="image">
                    <img alt="alt0" loading="lazy" onClick="window.LIA.img.click("http://example.com/0.png")" onerror="window.LIA.fetchError('img','http://example.com/0.png')" onload="window.LIA.img.load('http://example.com/0.png',this.width,this.height)" src="http://example.com/0.png">
                </div>
                
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
        <div class="lia-lightbox">
            <figure class="lia-figure" style="height:auto;width:100%;">
                <div class="lia-figure__media">
                    <a class="lia-link lia-print-only" href="https://www.youtube.com/watch?v=abc">
                        video
                    </a>
                    <lia-embed style="display:inline-block;height:250px;max-height:100%;width:250px;" data-attributes="{}" scale="1" url="https://www.youtube.com/watch?v=abc" thumbnail>
                    </lia-embed>
                    <figcaption class="lia-figure__caption">
                        <a class="lia-link" href="https://www.youtube.com/watch?v=abc" target="blank_">
                            https://www.youtube.com/watch?v=abc
                        </a>
                    </figcaption>
                </div>
            </figure>
            <div class="lia-lightbox__clickarea" aria-label="zoom media" role="button" tabIndex="0">
                <i class="icon icon-zoom lia-lightbox__icon" aria-hidden="true">
                </i>
            </div>
        </div>
    </div>
</div>"""
