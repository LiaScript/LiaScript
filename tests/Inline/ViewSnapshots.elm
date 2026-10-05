module Inline.ViewSnapshots exposing (snapshots)

{-| Generated from the implementation before the refactoring, do not edit.
-}

import Dict exposing (Dict)


snapshots : Dict String String
snapshots =
    Dict.fromList
        [ ( "view chars"
          , "plain"
          )
        , ( "view chars with attr"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    plain\n</span>"
          )
        , ( "view bold"
          , "<strong class=\"lia-bold\">\n    b\n</strong>"
          )
        , ( "view bold attr"
          , "<strong class=\"lia-bold x\" style=\"color:red\">\n    b\n</strong>"
          )
        , ( "view bold nested"
          , "<strong class=\"lia-bold x\" style=\"color:red\">\n    <em class=\"lia-italic\">\n        bi\n    </em>\n</strong>"
          )
        , ( "view italic"
          , "<em class=\"lia-italic x\" style=\"color:red\">\n    i\n</em>"
          )
        , ( "view strike"
          , "<s class=\"lia-strike x\" style=\"color:red\">\n    s\n</s>"
          )
        , ( "view underline"
          , "<u class=\"lia-underline x\" style=\"color:red\">\n    u\n</u>"
          )
        , ( "view superscript"
          , "<sup class=\"lia-superscript x\" style=\"color:red\">\n    sup\n</sup>"
          )
        , ( "view superscript nested"
          , "<sup class=\"lia-superscript\">\n    <span style=\"left:initial;text-decoration:inherit;\">\n        a\n        <strong class=\"lia-bold\">\n            b\n        </strong>\n    </span>\n</sup>"
          )
        , ( "view verbatim"
          , "<code class=\"notranslate lia-code lia-code--inline\" translate=\"no\">\n    code\n</code>"
          )
        , ( "view verbatim attr"
          , "<code class=\"notranslate lia-code lia-code--inline x\" style=\"color:red\" translate=\"no\">\n    code\n</code>"
          )
        , ( "view formula inline"
          , "<lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"a^2\" translate=\"no\">\n</lia-formula>"
          )
        , ( "view formula block"
          , "<lia-formula class=\"notranslate\" displayMode=\"true\" formula=\"\\RR\" translate=\"no\">\n</lia-formula>"
          )
        , ( "view formula attr"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    <lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"x\" translate=\"no\">\n    </lia-formula>\n</span>"
          )
        , ( "view symbol"
          , "→"
          )
        , ( "view symbol attr"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    →\n</span>"
          )
        , ( "view footnote"
          , "<sup>\n    <button class=\"lia-btn lia-btn--transparent text-highlight\" style=\"padding:2px;\" aria-describedby=\"footnote-1\" id=\"footnote-key-1\" onclick=\"window.LIA.showFootnote(\"1\");\" tabIndex=\"0\">\n        [1]\n    </button>\n</sup>"
          )
        , ( "view footnote attr"
          , "<sup>\n    <button class=\"lia-btn lia-btn--transparent text-highlight\" style=\"padding:2px;\" aria-describedby=\"footnote-note\" class=\"x\" id=\"footnote-key-note\" onclick=\"window.LIA.showFootnote(\"note\");\" style=\"color:red\" tabIndex=\"0\">\n        [note]\n    </button>\n</sup>"
          )
        , ( "view container"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    a\n    <em class=\"lia-italic\">\n        b\n    </em>\n    c\n</span>"
          )
        , ( "view container empty"
          , "<span style=\"left:initial;text-decoration:inherit;\">\n</span>"
          )
        , ( "view html node"
          , "<span id=\"n\">\n    in\n    <strong class=\"lia-bold\">\n        b\n    </strong>\n</span>"
          )
        , ( "view html node attr"
          , "<kbd class=\"x\" style=\"color:red\">\n    k\n</kbd>"
          )
        , ( "view html inner"
          , "<span innerHTML=\"<br>\">\n</span>"
          )
        , ( "view effect"
          , "<span aria-live=\"polite\" class=\"lia-effect--inline x\" role=\"alert\" style=\"color:red\">\n    <span class=\"lia-effect__circle lia-effect__circle--inline\">\n        \u{200A}1\u{200A}\n    </span>\n     \n    e\n    <strong class=\"lia-bold\">\n        f\n    </strong>\n</span>"
          )
        , ( "view effect range"
          , "<span aria-live=\"polite\" class=\"lia-effect--inline\" role=\"alert\">\n    <span class=\"lia-effect__circle lia-effect__circle--inline\">\n        \u{200A}2\u{200A}\n    </span>\n    <label>\n        <button class=\"lia-btn lia-btn--transparent\" style=\"margin:0 5px 0 5px;padding:0;\" onclick=\"window.LIA.playback({\"reply\":true,\"track\":[[\"effect\",0],[\"playback\",3]],\"service\":\"tts\",\"message\":{\"cmd\":\"playback\",\"param\":{\"voice\":\"Deutsch Female\",\"lang\":\"de\",\"text\":this.labels[0]}}})\" tabIndex=\"0\" title=\"Play\">\n            <span class=\"lia-btn__icon icon icon-play-circle\">\n            </span>\n        </button>\n        e\n    </label>\n</span>"
          )
        , ( "view script missing"
          , ""
          )
        , ( "view link"
          , "<a class=\"lia-link\" href=\"https://a.org\" target=\"_blank\">\n    alt\n</a>"
          )
        , ( "view link title attr"
          , "<a class=\"lia-link x\" href=\"https://a.org\" style=\"color:red\" target=\"_blank\" title=\"title\">\n    <strong class=\"lia-bold\">\n        alt\n    </strong>\n</a>"
          )
        , ( "view link blank title"
          , "<a class=\"lia-link\" href=\"https://a.org\" target=\"_blank\">\n    alt\n</a>"
          )
        , ( "view link anchor"
          , "<a class=\"lia-link\" href=\"#3\" target=\"\">\n    sec\n</a>"
          )
        , ( "view mail"
          , "<a class=\"lia-link\" href=\"mailto:a@b.de\" target=\"_blank\" title=\"t\">\n    me\n</a>"
          )
        , ( "view image"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <img alt=\"alt\" loading=\"lazy\" onClick=\"window.LIA.img.click(\"img.png\")\" onerror=\"window.LIA.fetchError('img','img.png')\" onload=\"window.LIA.img.load('img.png',this.width,this.height)\" src=\"img.png\">\n    </div>\n    \n</figure>"
          )
        , ( "view image no alt"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <img alt=\"\" loading=\"lazy\" onClick=\"window.LIA.img.click(\"other.png\")\" onerror=\"window.LIA.fetchError('img','other.png')\" onload=\"window.LIA.img.load('other.png',this.width,this.height)\" src=\"other.png\">\n    </div>\n    \n</figure>"
          )
        , ( "view image title attr"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <img alt=\"alt\" class=\"x\" loading=\"lazy\" onerror=\"window.LIA.fetchError('img','other.png')\" onload=\"window.LIA.img.load('other.png',this.width,this.height)\" src=\"other.png\" style=\"color:red\" title=\"cap\">\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        cap\n    </figcaption>\n</figure>"
          )
        , ( "view audio"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"audio\">\n        <div>\n            <a class=\"lia-link lia-print-only\" href=\"a.mp3\" title=\"t\">\n                a\n            </a>\n            <span>\n                <audio alt=\"a\" class=\"x\" preload=\"none\" style=\"color:red\" title=\"t\" controls>\n                    <source onerror=\"window.LIA.fetchError('audio','a.mp3')\" src=\"a.mp3\">\n                </audio>\n            </span>\n        </div>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        t\n    </figcaption>\n</figure>"
          )
        , ( "view audio tube"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"audio\">\n        <div>\n            <a class=\"lia-link lia-print-only\" href=\"https://deezer/x\">\n                a\n            </a>\n            <iframe style=\"width:100%;\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"a\" class=\"lia-audio x\" loading=\"lazy\" src=\"https://deezer/x\" style=\"color:red\">\n            </iframe>\n        </div>\n    </div>\n    \n</figure>"
          )
        , ( "view movie"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"movie\">\n        <div>\n            <a class=\"lia-link lia-print-only\" href=\"m.mp4\" title=\"t\">\n                m\n            </a>\n            <div class=\"lia-video-wrapper\">\n                <video alt=\"m\" class=\"x\" preload=\"none\" style=\"color:red\" title=\"t\" controls>\n                    <source onerror=\"window.LIA.fetchError('video','m.mp4')\" src=\"m.mp4\">\n                </video>\n            </div>\n        </div>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        t\n    </figcaption>\n</figure>"
          )
        , ( "view movie tube youtube"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n        <div class=\"lia-iframe-wrapper\">\n            <a class=\"lia-link lia-print-only\" href=\"https://www.youtube-nocookie.com/embed/abc\">\n                m\n            </a>\n            <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" loading=\"lazy\" src=\"https://www.youtube-nocookie.com/embed/abc?hl=English\">\n                m\n            </iframe>\n        </div>\n    </div>\n    \n</figure>"
          )
        , ( "view movie tube youtube query"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n        <div class=\"lia-iframe-wrapper\">\n            <a class=\"lia-link lia-print-only\" href=\"https://www.youtube-nocookie.com/embed/abc?start=3\" title=\"t\">\n                m\n            </a>\n            <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" class=\"x\" loading=\"lazy\" src=\"https://www.youtube-nocookie.com/embed/abc?start=3&hl=English\" style=\"color:red\" title=\"t\">\n                m\n            </iframe>\n        </div>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        t\n    </figcaption>\n</figure>"
          )
        , ( "view movie tube other"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n        <div class=\"lia-iframe-wrapper\">\n            <a class=\"lia-link lia-print-only\" href=\"https://player.vimeo.com/video/1\">\n                m\n            </a>\n            <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" loading=\"lazy\" src=\"https://player.vimeo.com/video/1\">\n                m\n            </iframe>\n        </div>\n    </div>\n    \n</figure>"
          )
        , ( "view embed"
          , "<figure class=\"lia-figure\" style=\"height:auto;width:100%;\">\n    <div class=\"lia-figure__media\">\n        <a class=\"lia-link lia-print-only\" href=\"https://e.org/x\">\n            e\n        </a>\n        <lia-embed class=\"\" style=\"display:inline-block;height:auto;max-height:100%;width:100%;\" data-attributes=\"{}\" url=\"https://e.org/x\">\n        </lia-embed>\n        <figcaption class=\"lia-figure__caption\">\n            <a class=\"lia-link\" href=\"https://e.org/x\" target=\"blank_\">\n                https://e.org/x\n            </a>\n        </figcaption>\n    </div>\n</figure>"
          )
        , ( "view embed title attr"
          , "<figure class=\"lia-figure\" style=\"height:auto;width:100%;\">\n    <div class=\"lia-figure__media\">\n        <a class=\"lia-link lia-print-only\" href=\"https://e.org/x\" title=\"cap\">\n            e\n        </a>\n        <lia-embed class=\"\" style=\"display:inline-block;height:auto;max-height:100%;width:100%;\" data-attributes=\"{\"class\":\"x\",\"style\":\"color:red\"}\" url=\"https://e.org/x\">\n        </lia-embed>\n        <figcaption class=\"lia-figure__caption\">\n            cap\n        </figcaption>\n    </div>\n</figure>"
          )
        , ( "view preview lia"
          , "<preview-lia class=\"x\" src=\"https://c.org/README.md\" style=\"color:red\">\n</preview-lia>"
          )
        , ( "view preview link"
          , "<preview-link class=\"\" src=\"https://c.org\">\n</preview-link>"
          )
        , ( "view qr"
          , "<figure class=\"lia-figure\" width=\"300\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <a style=\"background-color:white;display:inline-block;width:300px;\" class=\"lia-link\" href=\"https://q.org\">\n            <svg aria-label=\"QR code for website: https://q.org\" shape-rendering=\"crispEdges\" stroke=\"#000\" stroke-width=\"5px\" viewBox=\"0 0 165 165\">\n                <path d=\"M0 0h35m15 0h5m20 0h10m5 0h35M0 5h5m25 0h5m10 0h30m5 0h5m5 0h5m25 0h5M0 10h5m5 0h15m5 0h5m35 0h15m5 0h5m5 0h15m5 0h5M0 15h5m5 0h15m5 0h5m5 0h10m5 0h5m10 0h5m15 0h5m5 0h15m5 0h5M0 20h5m5 0h15m5 0h5m10 0h5m15 0h15m10 0h5m5 0h15m5 0h5M0 25h5m25 0h5m5 0h5m10 0h5m15 0h5m10 0h5m25 0h5M0 30h35m5 0h5m5 0h5m5 0h5m5 0h5m5 0h5m5 0h35M0 35m40 0h25m5 0h15M0 40m5 0h10m15 0h5m10 0h15m5 0h10m15 0h10m5 0h5M0 45h5m5 0h5m5 0h10m20 0h25m15 0h5m10 0h5m5 0h10M0 50h25m5 0h10m10 0h5m5 0h5m10 0h5m20 0h15m5 0h5M0 55h5m10 0h15m35 0h5m20 0h5m10 0h5M0 60m10 0h15m5 0h5m25 0h10m5 0h10m5 0h5m25 0h5M0 65m5 0h15m5 0h5m5 0h5m20 0h5m15 0h5m5 0h10m15 0h10M0 70m10 0h15m5 0h20m15 0h5m10 0h5m20 0h10m5 0h5M0 75m15 0h5m25 0h5m5 0h5m10 0h40M0 80m25 0h15m5 0h5m5 0h10m5 0h5m5 0h25m10 0h5M0 85m40 0h10m5 0h15m10 0h5m15 0h5m15 0h5M0 90h35m10 0h5m5 0h10m10 0h10m5 0h5m5 0h5m15 0h5M0 95h5m25 0h5m10 0h10m5 0h5m5 0h5m5 0h5m15 0h5m10 0h5M0 100h5m5 0h15m5 0h5m10 0h5m5 0h5m10 0h35M0 105h5m5 0h15m5 0h5m10 0h10m20 0h15m10 0h5m5 0h5M0 110h5m5 0h15m5 0h5m5 0h5m5 0h5m10 0h10m5 0h5m10 0h15m5 0h10M0 115h5m25 0h5m5 0h10m5 0h10m15 0h5m10 0h10M0 120h35m15 0h5m15 0h5m5 0h10m15 0h5m10 0h5\" stroke-width=\"5px\" transform=\"translate(20, 22.5)\">\n                </path>\n            </svg>\n        </a>\n    </div>\n    \n</figure>"
          )
        , ( "view qr title attr"
          , "<figure class=\"lia-figure\" width=\"300\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <a style=\"background-color:white;display:inline-block;width:300px;\" class=\"lia-link x\" href=\"https://q.org\" style=\"color:red\" title=\"scan\">\n            <svg aria-label=\"QR code for website: https://q.org\" shape-rendering=\"crispEdges\" stroke=\"#000\" stroke-width=\"5px\" viewBox=\"0 0 165 165\">\n                <path d=\"M0 0h35m15 0h5m20 0h10m5 0h35M0 5h5m25 0h5m10 0h30m5 0h5m5 0h5m25 0h5M0 10h5m5 0h15m5 0h5m35 0h15m5 0h5m5 0h15m5 0h5M0 15h5m5 0h15m5 0h5m5 0h10m5 0h5m10 0h5m15 0h5m5 0h15m5 0h5M0 20h5m5 0h15m5 0h5m10 0h5m15 0h15m10 0h5m5 0h15m5 0h5M0 25h5m25 0h5m5 0h5m10 0h5m15 0h5m10 0h5m25 0h5M0 30h35m5 0h5m5 0h5m5 0h5m5 0h5m5 0h5m5 0h35M0 35m40 0h25m5 0h15M0 40m5 0h10m15 0h5m10 0h15m5 0h10m15 0h10m5 0h5M0 45h5m5 0h5m5 0h10m20 0h25m15 0h5m10 0h5m5 0h10M0 50h25m5 0h10m10 0h5m5 0h5m10 0h5m20 0h15m5 0h5M0 55h5m10 0h15m35 0h5m20 0h5m10 0h5M0 60m10 0h15m5 0h5m25 0h10m5 0h10m5 0h5m25 0h5M0 65m5 0h15m5 0h5m5 0h5m20 0h5m15 0h5m5 0h10m15 0h10M0 70m10 0h15m5 0h20m15 0h5m10 0h5m20 0h10m5 0h5M0 75m15 0h5m25 0h5m5 0h5m10 0h40M0 80m25 0h15m5 0h5m5 0h10m5 0h5m5 0h25m10 0h5M0 85m40 0h10m5 0h15m10 0h5m15 0h5m15 0h5M0 90h35m10 0h5m5 0h10m10 0h10m5 0h5m5 0h5m15 0h5M0 95h5m25 0h5m10 0h10m5 0h5m5 0h5m5 0h5m15 0h5m10 0h5M0 100h5m5 0h15m5 0h5m10 0h5m5 0h5m10 0h35M0 105h5m5 0h15m5 0h5m10 0h10m20 0h15m10 0h5m5 0h5M0 110h5m5 0h15m5 0h5m5 0h5m5 0h5m10 0h10m5 0h5m10 0h15m5 0h10M0 115h5m25 0h5m5 0h10m5 0h10m15 0h5m10 0h10M0 120h35m15 0h5m15 0h5m5 0h10m15 0h5m10 0h5\" stroke-width=\"5px\" transform=\"translate(20, 22.5)\">\n                </path>\n            </svg>\n        </a>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        scan\n    </figcaption>\n</figure>"
          )
        , ( "presentation chars"
          , "plain"
          )
        , ( "presentation chars with attr"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    plain\n</span>"
          )
        , ( "presentation bold"
          , "<strong class=\"lia-bold\">\n    b\n</strong>"
          )
        , ( "presentation bold attr"
          , "<strong class=\"lia-bold x\" style=\"color:red\">\n    b\n</strong>"
          )
        , ( "presentation bold nested"
          , "<strong class=\"lia-bold x\" style=\"color:red\">\n    <em class=\"lia-italic\">\n        bi\n    </em>\n</strong>"
          )
        , ( "presentation italic"
          , "<em class=\"lia-italic x\" style=\"color:red\">\n    i\n</em>"
          )
        , ( "presentation strike"
          , "<s class=\"lia-strike x\" style=\"color:red\">\n    s\n</s>"
          )
        , ( "presentation underline"
          , "<u class=\"lia-underline x\" style=\"color:red\">\n    u\n</u>"
          )
        , ( "presentation superscript"
          , "<sup class=\"lia-superscript x\" style=\"color:red\">\n    sup\n</sup>"
          )
        , ( "presentation superscript nested"
          , "<sup class=\"lia-superscript\">\n    <span style=\"left:initial;text-decoration:inherit;\">\n        a\n        <strong class=\"lia-bold\">\n            b\n        </strong>\n    </span>\n</sup>"
          )
        , ( "presentation verbatim"
          , "<code class=\"notranslate lia-code lia-code--inline\" translate=\"no\">\n    code\n</code>"
          )
        , ( "presentation verbatim attr"
          , "<code class=\"notranslate lia-code lia-code--inline x\" style=\"color:red\" translate=\"no\">\n    code\n</code>"
          )
        , ( "presentation formula inline"
          , "<lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"a^2\" translate=\"no\">\n</lia-formula>"
          )
        , ( "presentation formula block"
          , "<lia-formula class=\"notranslate\" displayMode=\"true\" formula=\"\\RR\" translate=\"no\">\n</lia-formula>"
          )
        , ( "presentation formula attr"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    <lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"x\" translate=\"no\">\n    </lia-formula>\n</span>"
          )
        , ( "presentation symbol"
          , "→"
          )
        , ( "presentation symbol attr"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    →\n</span>"
          )
        , ( "presentation footnote"
          , "<sup>\n    <button class=\"lia-btn lia-btn--transparent text-highlight\" style=\"padding:2px;\" aria-describedby=\"footnote-1\" id=\"footnote-key-1\" onclick=\"window.LIA.showFootnote(\"1\");\" tabIndex=\"0\">\n        [1]\n    </button>\n</sup>"
          )
        , ( "presentation footnote attr"
          , "<sup>\n    <button class=\"lia-btn lia-btn--transparent text-highlight\" style=\"padding:2px;\" aria-describedby=\"footnote-note\" class=\"x\" id=\"footnote-key-note\" onclick=\"window.LIA.showFootnote(\"note\");\" style=\"color:red\" tabIndex=\"0\">\n        [note]\n    </button>\n</sup>"
          )
        , ( "presentation container"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    a\n    <em class=\"lia-italic\">\n        b\n    </em>\n    c\n</span>"
          )
        , ( "presentation container empty"
          , "<span style=\"left:initial;text-decoration:inherit;\">\n</span>"
          )
        , ( "presentation html node"
          , "<span id=\"n\">\n    in\n    <strong class=\"lia-bold\">\n        b\n    </strong>\n</span>"
          )
        , ( "presentation html node attr"
          , "<kbd class=\"x\" style=\"color:red\">\n    k\n</kbd>"
          )
        , ( "presentation html inner"
          , "<span innerHTML=\"<br>\">\n</span>"
          )
        , ( "presentation effect"
          , "<span aria-live=\"polite\" class=\"lia-effect--inline x\" role=\"alert\" style=\"color:red\">\n    <span class=\"lia-effect__circle lia-effect__circle--inline\">\n        \u{200A}1\u{200A}\n    </span>\n     \n    e\n    <strong class=\"lia-bold\">\n        f\n    </strong>\n</span>"
          )
        , ( "presentation effect range"
          , "<span class=\"lia-effect--inline hide\">\n    <span class=\"lia-effect__circle lia-effect__circle--inline\">\n        \u{200A}2\u{200A}\n    </span>\n    <label>\n        <button class=\"lia-btn lia-btn--transparent\" style=\"margin:0 5px 0 5px;padding:0;\" onclick=\"window.LIA.playback({\"reply\":true,\"track\":[[\"effect\",0],[\"playback\",3]],\"service\":\"tts\",\"message\":{\"cmd\":\"playback\",\"param\":{\"voice\":\"Deutsch Female\",\"lang\":\"de\",\"text\":this.labels[0]}}})\" tabIndex=\"0\" title=\"Play\">\n            <span class=\"lia-btn__icon icon icon-play-circle\">\n            </span>\n        </button>\n        e\n    </label>\n</span>"
          )
        , ( "presentation script missing"
          , ""
          )
        , ( "presentation link"
          , "<span>\n    <preview-link src=\"https://a.org\">\n        <a class=\"lia-link\" href=\"https://a.org\" target=\"_blank\">\n            alt\n        </a>\n    </preview-link>\n</span>"
          )
        , ( "presentation link title attr"
          , "<span>\n    <preview-link src=\"https://a.org\">\n        <a class=\"lia-link x\" href=\"https://a.org\" style=\"color:red\" target=\"_blank\" title=\"title\">\n            <strong class=\"lia-bold\">\n                alt\n            </strong>\n        </a>\n    </preview-link>\n</span>"
          )
        , ( "presentation link blank title"
          , "<span>\n    <preview-link src=\"https://a.org\">\n        <a class=\"lia-link\" href=\"https://a.org\" target=\"_blank\">\n            alt\n        </a>\n    </preview-link>\n</span>"
          )
        , ( "presentation link anchor"
          , "<a class=\"lia-link\" href=\"#3\" target=\"\">\n    sec\n</a>"
          )
        , ( "presentation mail"
          , "<span>\n    <preview-link src=\"mailto:a@b.de\">\n        <a class=\"lia-link\" href=\"mailto:a@b.de\" target=\"_blank\" title=\"t\">\n            me\n        </a>\n    </preview-link>\n</span>"
          )
        , ( "presentation image"
          , "<figure class=\"lia-figure\" width=\"320\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <img alt=\"alt\" onClick=\"window.LIA.img.click(\"img.png\")\" onerror=\"window.LIA.fetchError('img','img.png')\" src=\"img.png\">\n    </div>\n    \n</figure>"
          )
        , ( "presentation image no alt"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <img alt=\"\" onClick=\"window.LIA.img.click(\"other.png\")\" onerror=\"window.LIA.fetchError('img','other.png')\" onload=\"window.LIA.img.load('other.png',this.width,this.height)\" src=\"other.png\">\n    </div>\n    \n</figure>"
          )
        , ( "presentation image title attr"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <img alt=\"alt\" class=\"x\" onerror=\"window.LIA.fetchError('img','other.png')\" onload=\"window.LIA.img.load('other.png',this.width,this.height)\" src=\"other.png\" style=\"color:red\" title=\"cap\">\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        cap\n    </figcaption>\n</figure>"
          )
        , ( "presentation audio"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"audio\">\n        <div>\n            <a class=\"lia-link lia-print-only\" href=\"a.mp3\" title=\"t\">\n                a\n            </a>\n            <span>\n                <audio alt=\"a\" class=\"x\" preload=\"none\" style=\"color:red\" title=\"t\" controls>\n                    <source onerror=\"window.LIA.fetchError('audio','a.mp3')\" src=\"a.mp3\">\n                </audio>\n            </span>\n        </div>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        t\n    </figcaption>\n</figure>"
          )
        , ( "presentation audio tube"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"audio\">\n        <div>\n            <a class=\"lia-link lia-print-only\" href=\"https://deezer/x\">\n                a\n            </a>\n            <iframe style=\"width:100%;\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"a\" class=\"lia-audio x\" src=\"https://deezer/x\" style=\"color:red\">\n            </iframe>\n        </div>\n    </div>\n    \n</figure>"
          )
        , ( "presentation movie"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"movie\">\n        <div>\n            <a class=\"lia-link lia-print-only\" href=\"m.mp4\" title=\"t\">\n                m\n            </a>\n            <div class=\"lia-video-wrapper\">\n                <video alt=\"m\" class=\"x\" preload=\"none\" style=\"color:red\" title=\"t\" controls>\n                    <source onerror=\"window.LIA.fetchError('video','m.mp4')\" src=\"m.mp4\">\n                </video>\n            </div>\n        </div>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        t\n    </figcaption>\n</figure>"
          )
        , ( "presentation movie tube youtube"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n        <div class=\"lia-iframe-wrapper\">\n            <a class=\"lia-link lia-print-only\" href=\"https://www.youtube-nocookie.com/embed/abc\">\n                m\n            </a>\n            <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" src=\"https://www.youtube-nocookie.com/embed/abc?hl=fr\">\n                m\n            </iframe>\n        </div>\n    </div>\n    \n</figure>"
          )
        , ( "presentation movie tube youtube query"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n        <div class=\"lia-iframe-wrapper\">\n            <a class=\"lia-link lia-print-only\" href=\"https://www.youtube-nocookie.com/embed/abc?start=3\" title=\"t\">\n                m\n            </a>\n            <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" class=\"x\" src=\"https://www.youtube-nocookie.com/embed/abc?start=3&hl=fr\" style=\"color:red\" title=\"t\">\n                m\n            </iframe>\n        </div>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        t\n    </figcaption>\n</figure>"
          )
        , ( "presentation movie tube other"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n        <div class=\"lia-iframe-wrapper\">\n            <a class=\"lia-link lia-print-only\" href=\"https://player.vimeo.com/video/1\">\n                m\n            </a>\n            <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" src=\"https://player.vimeo.com/video/1\">\n                m\n            </iframe>\n        </div>\n    </div>\n    \n</figure>"
          )
        , ( "presentation embed"
          , "<figure class=\"lia-figure\" style=\"height:auto;width:100%;\">\n    <div class=\"lia-figure__media\">\n        <a class=\"lia-link lia-print-only\" href=\"https://e.org/x\">\n            e\n        </a>\n        <lia-embed class=\"\" style=\"display:inline-block;height:auto;max-height:100%;width:100%;\" data-attributes=\"{}\" url=\"https://e.org/x\">\n        </lia-embed>\n        <figcaption class=\"lia-figure__caption\">\n            <a class=\"lia-link\" href=\"https://e.org/x\" target=\"blank_\">\n                https://e.org/x\n            </a>\n        </figcaption>\n    </div>\n</figure>"
          )
        , ( "presentation embed title attr"
          , "<figure class=\"lia-figure\" style=\"height:auto;width:100%;\">\n    <div class=\"lia-figure__media\">\n        <a class=\"lia-link lia-print-only\" href=\"https://e.org/x\" title=\"cap\">\n            e\n        </a>\n        <lia-embed class=\"\" style=\"display:inline-block;height:auto;max-height:100%;width:100%;\" data-attributes=\"{\"class\":\"x\",\"style\":\"color:red\"}\" url=\"https://e.org/x\">\n        </lia-embed>\n        <figcaption class=\"lia-figure__caption\">\n            cap\n        </figcaption>\n    </div>\n</figure>"
          )
        , ( "presentation preview lia"
          , "<preview-lia class=\"x\" src=\"https://c.org/README.md\" style=\"color:red\">\n</preview-lia>"
          )
        , ( "presentation preview link"
          , "<preview-link class=\"\" src=\"https://c.org\">\n</preview-link>"
          )
        , ( "presentation qr"
          , "<figure class=\"lia-figure\" width=\"300\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <a style=\"background-color:white;display:inline-block;width:300px;\" class=\"lia-link\" href=\"https://q.org\">\n            <svg aria-label=\"QR-Code für Webseite: https://q.org\" shape-rendering=\"crispEdges\" stroke=\"#000\" stroke-width=\"5px\" viewBox=\"0 0 165 165\">\n                <path d=\"M0 0h35m15 0h5m20 0h10m5 0h35M0 5h5m25 0h5m10 0h30m5 0h5m5 0h5m25 0h5M0 10h5m5 0h15m5 0h5m35 0h15m5 0h5m5 0h15m5 0h5M0 15h5m5 0h15m5 0h5m5 0h10m5 0h5m10 0h5m15 0h5m5 0h15m5 0h5M0 20h5m5 0h15m5 0h5m10 0h5m15 0h15m10 0h5m5 0h15m5 0h5M0 25h5m25 0h5m5 0h5m10 0h5m15 0h5m10 0h5m25 0h5M0 30h35m5 0h5m5 0h5m5 0h5m5 0h5m5 0h5m5 0h35M0 35m40 0h25m5 0h15M0 40m5 0h10m15 0h5m10 0h15m5 0h10m15 0h10m5 0h5M0 45h5m5 0h5m5 0h10m20 0h25m15 0h5m10 0h5m5 0h10M0 50h25m5 0h10m10 0h5m5 0h5m10 0h5m20 0h15m5 0h5M0 55h5m10 0h15m35 0h5m20 0h5m10 0h5M0 60m10 0h15m5 0h5m25 0h10m5 0h10m5 0h5m25 0h5M0 65m5 0h15m5 0h5m5 0h5m20 0h5m15 0h5m5 0h10m15 0h10M0 70m10 0h15m5 0h20m15 0h5m10 0h5m20 0h10m5 0h5M0 75m15 0h5m25 0h5m5 0h5m10 0h40M0 80m25 0h15m5 0h5m5 0h10m5 0h5m5 0h25m10 0h5M0 85m40 0h10m5 0h15m10 0h5m15 0h5m15 0h5M0 90h35m10 0h5m5 0h10m10 0h10m5 0h5m5 0h5m15 0h5M0 95h5m25 0h5m10 0h10m5 0h5m5 0h5m5 0h5m15 0h5m10 0h5M0 100h5m5 0h15m5 0h5m10 0h5m5 0h5m10 0h35M0 105h5m5 0h15m5 0h5m10 0h10m20 0h15m10 0h5m5 0h5M0 110h5m5 0h15m5 0h5m5 0h5m5 0h5m10 0h10m5 0h5m10 0h15m5 0h10M0 115h5m25 0h5m5 0h10m5 0h10m15 0h5m10 0h10M0 120h35m15 0h5m15 0h5m5 0h10m15 0h5m10 0h5\" stroke-width=\"5px\" transform=\"translate(20, 22.5)\">\n                </path>\n            </svg>\n        </a>\n    </div>\n    \n</figure>"
          )
        , ( "presentation qr title attr"
          , "<figure class=\"lia-figure\" width=\"300\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <a style=\"background-color:white;display:inline-block;width:300px;\" class=\"lia-link x\" href=\"https://q.org\" style=\"color:red\" title=\"scan\">\n            <svg aria-label=\"QR-Code für Webseite: https://q.org\" shape-rendering=\"crispEdges\" stroke=\"#000\" stroke-width=\"5px\" viewBox=\"0 0 165 165\">\n                <path d=\"M0 0h35m15 0h5m20 0h10m5 0h35M0 5h5m25 0h5m10 0h30m5 0h5m5 0h5m25 0h5M0 10h5m5 0h15m5 0h5m35 0h15m5 0h5m5 0h15m5 0h5M0 15h5m5 0h15m5 0h5m5 0h10m5 0h5m10 0h5m15 0h5m5 0h15m5 0h5M0 20h5m5 0h15m5 0h5m10 0h5m15 0h15m10 0h5m5 0h15m5 0h5M0 25h5m25 0h5m5 0h5m10 0h5m15 0h5m10 0h5m25 0h5M0 30h35m5 0h5m5 0h5m5 0h5m5 0h5m5 0h5m5 0h35M0 35m40 0h25m5 0h15M0 40m5 0h10m15 0h5m10 0h15m5 0h10m15 0h10m5 0h5M0 45h5m5 0h5m5 0h10m20 0h25m15 0h5m10 0h5m5 0h10M0 50h25m5 0h10m10 0h5m5 0h5m10 0h5m20 0h15m5 0h5M0 55h5m10 0h15m35 0h5m20 0h5m10 0h5M0 60m10 0h15m5 0h5m25 0h10m5 0h10m5 0h5m25 0h5M0 65m5 0h15m5 0h5m5 0h5m20 0h5m15 0h5m5 0h10m15 0h10M0 70m10 0h15m5 0h20m15 0h5m10 0h5m20 0h10m5 0h5M0 75m15 0h5m25 0h5m5 0h5m10 0h40M0 80m25 0h15m5 0h5m5 0h10m5 0h5m5 0h25m10 0h5M0 85m40 0h10m5 0h15m10 0h5m15 0h5m15 0h5M0 90h35m10 0h5m5 0h10m10 0h10m5 0h5m5 0h5m15 0h5M0 95h5m25 0h5m10 0h10m5 0h5m5 0h5m5 0h5m15 0h5m10 0h5M0 100h5m5 0h15m5 0h5m10 0h5m5 0h5m10 0h35M0 105h5m5 0h15m5 0h5m10 0h10m20 0h15m10 0h5m5 0h5M0 110h5m5 0h15m5 0h5m5 0h5m5 0h5m10 0h10m5 0h5m10 0h15m5 0h10M0 115h5m25 0h5m5 0h10m5 0h10m15 0h5m10 0h10M0 120h35m15 0h5m15 0h5m5 0h10m15 0h5m10 0h5\" stroke-width=\"5px\" transform=\"translate(20, 22.5)\">\n                </path>\n            </svg>\n        </a>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        scan\n    </figcaption>\n</figure>"
          )
        , ( "quiz text active"
          , "<input class=\"lia-input lia-quiz__input \" style=\"font-style:inherit;font-weight:inherit;padding:0.2rem 0.5rem;text-align:center;text-decoration:inherit;vertical-align:middle;width:5rem;\" aria-label=\"quiz answer\" class=\"x\" oninput=\"on(input,0,this.value)\" placeholder=\"?\" style=\"color:red\" type=\"text\" value=\"abc\">"
          )
        , ( "quiz text inactive"
          , "<input class=\"lia-input lia-quiz__input lia-input--disabled is-disabled\" style=\"font-style:inherit;font-weight:inherit;padding:0.2rem 0.5rem;text-align:center;text-decoration:inherit;vertical-align:middle;width:5rem;\" aria-label=\"quiz answer\" class=\"x\" placeholder=\"?\" style=\"color:red\" type=\"text\" value=\"abc\" disabled>"
          )
        , ( "quiz text correct"
          , "<input class=\"lia-input lia-quiz__input  is-success\" style=\"font-style:inherit;font-weight:inherit;padding:0.2rem 0.5rem;text-align:center;text-decoration:inherit;vertical-align:middle;width:5rem;\" aria-invalid=\"false\" aria-label=\"quiz answer\" class=\"x\" oninput=\"on(input,0,this.value)\" placeholder=\"?\" style=\"color:red\" type=\"text\" value=\"abc\">"
          )
        , ( "quiz text wrong"
          , "<input class=\"lia-input lia-quiz__input  is-failure\" style=\"font-style:inherit;font-weight:inherit;padding:0.2rem 0.5rem;text-align:center;text-decoration:inherit;vertical-align:middle;width:5rem;\" aria-invalid=\"true\" aria-label=\"quiz answer\" class=\"x\" oninput=\"on(input,0,this.value)\" placeholder=\"?\" style=\"color:red\" type=\"text\" value=\"abc\">"
          )
        , ( "quiz text resolved hides highlight"
          , "<input class=\"lia-input lia-quiz__input lia-input--disabled is-disabled\" style=\"font-style:inherit;font-weight:inherit;padding:0.2rem 0.5rem;text-align:center;text-decoration:inherit;vertical-align:middle;width:5rem;\" aria-label=\"quiz answer\" class=\"x\" placeholder=\"?\" style=\"color:red\" type=\"text\" value=\"abc\" disabled>"
          )
        , ( "quiz select closed"
          , "<span class=\"lia-dropdown\" style=\"padding:0 0.5rem;vertical-align:middle;\" class=\"x\" onClick=\"on(toggle,0,true)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(toggle,0,true)\" style=\"color:red\" tabIndex=\"0\">\n    <span class=\"lia-dropdown__selected\" style=\"font-style:inherit;font-weight:inherit;text-decoration:inherit;\" aria-expanded=\"false\" aria-hidden=\"false\" role=\"button\">\n        <span>\n            <strong class=\"lia-bold\">\n                opt1\n            </strong>\n        </span>\n        <i class=\"icon icon-chevron-down\" role=\"button\">\n        </i>\n    </span>\n    <div class=\"lia-dropdown__options is-hidden\" tabIndex=\"-1\">\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,0)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,0)\" role=\"listitem\" tabIndex=\"-1\">\n            <div>\n                opt0\n            </div>\n        </div>\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,1)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,1)\" role=\"listitem\" tabIndex=\"-1\">\n            <div>\n                <strong class=\"lia-bold\">\n                    opt1\n                </strong>\n            </div>\n        </div>\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,2)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,2)\" role=\"listitem\" tabIndex=\"-1\">\n            <div>\n                opt2\n            </div>\n        </div>\n    </div>\n</span>"
          )
        , ( "quiz select open"
          , "<span class=\"lia-dropdown\" style=\"padding:0 0.5rem;vertical-align:text-top;\" class=\"x\" onClick=\"on(toggle,0,true)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(toggle,0,true)\" style=\"color:red\" tabIndex=\"0\">\n    <span class=\"lia-dropdown__selected\" style=\"font-style:inherit;font-weight:inherit;text-decoration:inherit;\" aria-expanded=\"true\" aria-hidden=\"false\" role=\"button\">\n        <span>\n            selection\n        </span>\n        <i class=\"icon icon-chevron-up\" role=\"button\">\n        </i>\n    </span>\n    <div class=\"lia-dropdown__options is-visible\" tabIndex=\"-1\">\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,0)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,0)\" role=\"listitem\" tabIndex=\"0\">\n            <div>\n                opt0\n            </div>\n        </div>\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,1)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,1)\" role=\"listitem\" tabIndex=\"0\">\n            <div>\n                <strong class=\"lia-bold\">\n                    opt1\n                </strong>\n            </div>\n        </div>\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,2)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,2)\" role=\"listitem\" tabIndex=\"0\">\n            <div>\n                opt2\n            </div>\n        </div>\n    </div>\n</span>"
          )
        , ( "quiz select out of range"
          , "<span class=\"is-success lia-dropdown\" style=\"padding:0 0.5rem;vertical-align:middle;\" aria-invalid=\"false\" class=\"x\" onClick=\"on(toggle,0,true)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(toggle,0,true)\" style=\"color:red\" tabIndex=\"0\">\n    <span class=\"lia-dropdown__selected\" style=\"font-style:inherit;font-weight:inherit;text-decoration:inherit;\" aria-expanded=\"false\" aria-hidden=\"false\" role=\"button\">\n        <span>\n            selection\n        </span>\n        <i class=\"icon icon-chevron-down\" role=\"button\">\n        </i>\n    </span>\n    <div class=\"lia-dropdown__options is-hidden\" tabIndex=\"-1\">\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,0)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,0)\" role=\"listitem\" tabIndex=\"-1\">\n            <div>\n                opt0\n            </div>\n        </div>\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,1)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,1)\" role=\"listitem\" tabIndex=\"-1\">\n            <div>\n                <strong class=\"lia-bold\">\n                    opt1\n                </strong>\n            </div>\n        </div>\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,2)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,2)\" role=\"listitem\" tabIndex=\"-1\">\n            <div>\n                opt2\n            </div>\n        </div>\n    </div>\n</span>"
          )
        , ( "quiz select inactive"
          , "<span class=\"is-disabled lia-dropdown\" style=\"padding:0 0.5rem;vertical-align:text-top;\" class=\"x\" style=\"color:red\" tabIndex=\"0\" disabled>\n    <span class=\"lia-dropdown__selected\" style=\"font-style:inherit;font-weight:inherit;text-decoration:inherit;\" aria-expanded=\"true\" aria-hidden=\"false\" role=\"button\">\n        <span>\n            opt0\n        </span>\n        <i class=\"icon icon-chevron-up\" role=\"button\">\n        </i>\n    </span>\n    <div class=\"lia-dropdown__options is-visible\" tabIndex=\"-1\">\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,0)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,0)\" role=\"listitem\" tabIndex=\"0\">\n            <div>\n                opt0\n            </div>\n        </div>\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,1)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,1)\" role=\"listitem\" tabIndex=\"0\">\n            <div>\n                <strong class=\"lia-bold\">\n                    opt1\n                </strong>\n            </div>\n        </div>\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,2)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,2)\" role=\"listitem\" tabIndex=\"0\">\n            <div>\n                opt2\n            </div>\n        </div>\n    </div>\n</span>"
          )
        , ( "quiz select randomized"
          , "<span class=\"lia-dropdown\" style=\"padding:0 0.5rem;vertical-align:text-top;\" class=\"x\" onClick=\"on(toggle,0,true)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(toggle,0,true)\" style=\"color:red\" tabIndex=\"0\">\n    <span class=\"lia-dropdown__selected\" style=\"font-style:inherit;font-weight:inherit;text-decoration:inherit;\" aria-expanded=\"true\" aria-hidden=\"false\" role=\"button\">\n        <span>\n            opt0\n        </span>\n        <i class=\"icon icon-chevron-up\" role=\"button\">\n        </i>\n    </span>\n    <div class=\"lia-dropdown__options is-visible\" tabIndex=\"-1\">\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,1)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,1)\" role=\"listitem\" tabIndex=\"0\">\n            <div>\n                <strong class=\"lia-bold\">\n                    opt1\n                </strong>\n            </div>\n        </div>\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,2)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,2)\" role=\"listitem\" tabIndex=\"0\">\n            <div>\n                opt2\n            </div>\n        </div>\n        <div class=\"lia-dropdown__option\" onclick=\"on(choose,0,0)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(choose,0,0)\" role=\"listitem\" tabIndex=\"0\">\n            <div>\n                opt0\n            </div>\n        </div>\n    </div>\n</span>"
          )
        , ( "quiz select multiple"
          , "todo"
          )
        , ( "quiz drop single"
          , "<span style=\"border:3px dotted #888;border-radius:5px;display:inline-block;margin:0.25rem;padding:1rem;position:relative;vertical-align:middle;\" class=\"x\" style=\"color:red\">\n    <span>\n        <strong class=\"lia-bold\">\n            opt1\n        </strong>\n    </span>\n</span>"
          )
        , ( "quiz drop single empty"
          , "<span class=\"is-success\" style=\"border:3px dotted green;border-radius:5px;display:inline-block;margin:0.25rem;padding:1rem;position:relative;vertical-align:middle;\" aria-invalid=\"false\" class=\"x\" style=\"color:red\">\n    <div style=\"align-items:center;color:#888;display:flex;justify-content:center;line-height:1;min-width:3rem;\">\n        ✛\n    </div>\n</span>"
          )
        , ( "quiz drop single wrong"
          , "<span class=\"is-failure\" style=\"border:3px dotted red;border-radius:5px;display:inline-block;margin:0.25rem;padding:1rem;position:relative;vertical-align:middle;\" aria-invalid=\"true\" class=\"x\" style=\"color:red\">\n    <span>\n        opt0\n    </span>\n</span>"
          )
        , ( "quiz drop empty"
          , "<span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;display:inline-block;margin:0.25rem;padding:1rem;position:relative;vertical-align:middle;\" class=\"x\" onclick=\"on(dragtarget,0,null)\" ondragleave=\"setTimeout(()=>on(dragenter,0,false), 100)\" ondragover=\"on(dragenter,0,true)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(dragtarget,0,null)\" role=\"button\" style=\"color:red\" tabIndex=\"0\">\n    <div style=\"align-items:center;color:#888;display:flex;justify-content:center;line-height:1;min-width:3rem;\">\n        ✛\n    </div>\n</span>"
          )
        , ( "quiz drop pair"
          , "<span style=\"background-color:#88888822;border:5px dotted green;border-radius:4px;display:inline-block;margin:0.25rem;padding:1rem;position:relative;vertical-align:middle;\" class=\"x\" onclick=\"on(dragtarget,0,null)\" ondragleave=\"setTimeout(()=>on(dragenter,0,false), 100)\" ondragover=\"on(dragenter,0,true)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(dragtarget,0,null)\" role=\"button\" style=\"color:red\" tabIndex=\"0\">\n    <span style=\"cursor:pointer;\" draggable=\"true\" ondragend=\"on(dragend,0,[0,2])\">\n        opt2\n    </span>\n</span>"
          )
        , ( "quiz drop pair wrong"
          , "<span style=\"background-color:#88888822;border:3px dotted red;border-radius:4px;display:inline-block;margin:0.25rem;padding:1rem;position:relative;vertical-align:middle;\" class=\"x\" onclick=\"on(dragtarget,0,null)\" ondragleave=\"setTimeout(()=>on(dragenter,0,false), 100)\" ondragover=\"on(dragenter,0,true)\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(dragtarget,0,null)\" role=\"button\" style=\"color:red\" tabIndex=\"0\">\n    <span style=\"cursor:pointer;\" draggable=\"true\" ondragend=\"on(dragend,0,[0,1])\">\n        <strong class=\"lia-bold\">\n            opt1\n        </strong>\n    </span>\n</span>"
          )
        , ( "quiz missing state"
          , "todo"
          )
        , ( "reduce chars"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bplain.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce chars with attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bplain.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce bold"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bb.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce bold attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bb.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce bold nested"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bbi.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce italic"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bi.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce strike"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bs.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce underline"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bu.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce superscript"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bsup.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce superscript nested"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <span>\n        <div>\n            <p>\n                a.\n            </p>\n        </div>\n        <div>\n            <p>\n                b.\n            </p>\n        </div>\n    </span>\n</div>"
          )
        , ( "reduce verbatim"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <span class=\"notranslate\" translate=\"no\">\n        code\n    </span>\n</div>"
          )
        , ( "reduce verbatim attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <span class=\"notranslate x\" style=\"color:red\" translate=\"no\">\n        code\n    </span>\n</div>"
          )
        , ( "reduce formula inline"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"a^2\" translate=\"no\">\n    </lia-formula>\n</div>"
          )
        , ( "reduce formula block"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <lia-formula class=\"notranslate\" displayMode=\"true\" formula=\"\\RR\" translate=\"no\">\n    </lia-formula>\n</div>"
          )
        , ( "reduce formula attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"x\" translate=\"no\">\n    </lia-formula>\n</div>"
          )
        , ( "reduce symbol"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    →\n</div>"
          )
        , ( "reduce symbol attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    →\n</div>"
          )
        , ( "reduce footnote"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b[1].\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce footnote attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b[note].\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce container"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <span>\n        <div>\n            <p>\n                a.\n            </p>\n        </div>\n        <div>\n            <p>\n                b.\n            </p>\n        </div>\n        <div>\n            <p>\n                c.\n            </p>\n        </div>\n    </span>\n</div>"
          )
        , ( "reduce container empty"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <span>\n    </span>\n</div>"
          )
        , ( "reduce html node"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <span id=\"n\">\n        <div>\n            <p>\n                in.\n            </p>\n        </div>\n        \n    </span>\n</div>"
          )
        , ( "reduce html node attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <kbd class=\"x\" style=\"color:red\">\n        <div>\n            <p>\n                k.\n            </p>\n        </div>\n    </kbd>\n</div>"
          )
        , ( "reduce html inner"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <span innerHTML=\"<br>\">\n    </span>\n</div>"
          )
        , ( "reduce effect"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <span aria-live=\"polite\" class=\"lia-effect--inline\" role=\"alert\">\n        <span class=\"lia-effect__circle lia-effect__circle--inline\">\n            \u{200A}1\u{200A}\n        </span>\n         \n        <div>\n            <p>\n                e.\n            </p>\n        </div>\n        \n    </span>\n</div>"
          )
        , ( "reduce effect range"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <span aria-live=\"polite\" class=\"lia-effect--inline\" role=\"alert\">\n        <span class=\"lia-effect__circle lia-effect__circle--inline\">\n            \u{200A}2\u{200A}\n        </span>\n        <label>\n            <button class=\"lia-btn lia-btn--transparent\" style=\"margin:0 5px 0 5px;padding:0;\" onclick=\"window.LIA.playback({\"reply\":true,\"track\":[[\"effect\",0],[\"playback\",3]],\"service\":\"tts\",\"message\":{\"cmd\":\"playback\",\"param\":{\"voice\":\"Deutsch Female\",\"lang\":\"de\",\"text\":this.labels[0]}}})\" tabIndex=\"0\" title=\"Play\">\n                <span class=\"lia-btn__icon icon icon-play-circle\">\n                </span>\n            </button>\n            <div>\n                <p>\n                    e.\n                </p>\n            </div>\n        </label>\n    </span>\n</div>"
          )
        , ( "reduce script missing"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    \n</div>"
          )
        , ( "reduce link"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            balt.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce link title attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            balt.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce link blank title"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            balt.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce link anchor"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bsec.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce mail"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bme.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce image"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            balt.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce image no alt"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            b.\n        </p>\n    </div>\n    <span>\n    </span>\n</div>"
          )
        , ( "reduce image title attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            balt.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce audio"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            ba.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce audio tube"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            ba.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce movie"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bm.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce movie tube youtube"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bm.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce movie tube youtube query"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bm.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce movie tube other"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bm.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce embed"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            be.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce embed title attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            be.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce preview lia"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bpreview-lia.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce preview link"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bpreview-link.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce qr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bqrcode.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce qr title attr"
          , "<div>\n    <div>\n        <p>\n            a.\n        </p>\n        <p>\n            bqrcode.\n        </p>\n    </div>\n</div>"
          )
        , ( "reduce all"
          , "<div>\n    <div>\n        <p>\n            plainplainbbbiisusup.\n        </p>\n    </div>\n    <span>\n        <div>\n            <p>\n                a.\n            </p>\n        </div>\n        <div>\n            <p>\n                b.\n            </p>\n        </div>\n    </span>\n    <span class=\"notranslate\" translate=\"no\">\n        code\n    </span>\n    <span class=\"notranslate x\" style=\"color:red\" translate=\"no\">\n        code\n    </span>\n    <lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"a^2\" translate=\"no\">\n    </lia-formula>\n    <lia-formula class=\"notranslate\" displayMode=\"true\" formula=\"\\RR\" translate=\"no\">\n    </lia-formula>\n    <lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"x\" translate=\"no\">\n    </lia-formula>\n    →\n    →\n    <div>\n        <p>\n            [1][note].\n        </p>\n    </div>\n    <span>\n        <div>\n            <p>\n                a.\n            </p>\n        </div>\n        <div>\n            <p>\n                b.\n            </p>\n        </div>\n        <div>\n            <p>\n                c.\n            </p>\n        </div>\n    </span>\n    <span>\n    </span>\n    <span id=\"n\">\n        <div>\n            <p>\n                in.\n            </p>\n        </div>\n        \n    </span>\n    <kbd class=\"x\" style=\"color:red\">\n        <div>\n            <p>\n                k.\n            </p>\n        </div>\n    </kbd>\n    <span innerHTML=\"<br>\">\n    </span>\n    <span aria-live=\"polite\" class=\"lia-effect--inline\" role=\"alert\">\n        <span class=\"lia-effect__circle lia-effect__circle--inline\">\n            \u{200A}1\u{200A}\n        </span>\n         \n        <div>\n            <p>\n                e.\n            </p>\n        </div>\n        \n    </span>\n    <span aria-live=\"polite\" class=\"lia-effect--inline\" role=\"alert\">\n        <span class=\"lia-effect__circle lia-effect__circle--inline\">\n            \u{200A}2\u{200A}\n        </span>\n        <label>\n            <button class=\"lia-btn lia-btn--transparent\" style=\"margin:0 5px 0 5px;padding:0;\" onclick=\"window.LIA.playback({\"reply\":true,\"track\":[[\"effect\",0],[\"playback\",3]],\"service\":\"tts\",\"message\":{\"cmd\":\"playback\",\"param\":{\"voice\":\"Deutsch Female\",\"lang\":\"de\",\"text\":this.labels[0]}}})\" tabIndex=\"0\" title=\"Play\">\n                <span class=\"lia-btn__icon icon icon-play-circle\">\n                </span>\n            </button>\n            <div>\n                <p>\n                    e.\n                </p>\n            </div>\n        </label>\n    </span>\n    \n    <div>\n        <p>\n            altaltaltsecmealt.\n        </p>\n    </div>\n    <span>\n    </span>\n    <div>\n        <p>\n            altaammmmeepreview-liapreview-linkqrcodeqrcode.\n        </p>\n    </div>\n</div>"
          )
        , ( "viewer"
          , "<div>\n    plain\n    <span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n        plain\n    </span>\n    <strong class=\"lia-bold\">\n        b\n    </strong>\n    <strong class=\"lia-bold x\" style=\"color:red\">\n        b\n    </strong>\n    <strong class=\"lia-bold x\" style=\"color:red\">\n        <em class=\"lia-italic\">\n            bi\n        </em>\n    </strong>\n    <em class=\"lia-italic x\" style=\"color:red\">\n        i\n    </em>\n    <s class=\"lia-strike x\" style=\"color:red\">\n        s\n    </s>\n    <u class=\"lia-underline x\" style=\"color:red\">\n        u\n    </u>\n    <sup class=\"lia-superscript x\" style=\"color:red\">\n        sup\n    </sup>\n    <sup class=\"lia-superscript\">\n        <span style=\"left:initial;text-decoration:inherit;\">\n            a\n            <strong class=\"lia-bold\">\n                b\n            </strong>\n        </span>\n    </sup>\n    <code class=\"notranslate lia-code lia-code--inline\" translate=\"no\">\n        code\n    </code>\n    <code class=\"notranslate lia-code lia-code--inline x\" style=\"color:red\" translate=\"no\">\n        code\n    </code>\n    <lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"a^2\" translate=\"no\">\n    </lia-formula>\n    <lia-formula class=\"notranslate\" displayMode=\"true\" formula=\"\\RR\" translate=\"no\">\n    </lia-formula>\n    <span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n        <lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"x\" translate=\"no\">\n        </lia-formula>\n    </span>\n    →\n    <span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n        →\n    </span>\n    <sup>\n        <button class=\"lia-btn lia-btn--transparent text-highlight\" style=\"padding:2px;\" aria-describedby=\"footnote-1\" id=\"footnote-key-1\" onclick=\"window.LIA.showFootnote(\"1\");\" tabIndex=\"0\">\n            [1]\n        </button>\n    </sup>\n    <sup>\n        <button class=\"lia-btn lia-btn--transparent text-highlight\" style=\"padding:2px;\" aria-describedby=\"footnote-note\" class=\"x\" id=\"footnote-key-note\" onclick=\"window.LIA.showFootnote(\"note\");\" style=\"color:red\" tabIndex=\"0\">\n            [note]\n        </button>\n    </sup>\n    <span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n        a\n        <em class=\"lia-italic\">\n            b\n        </em>\n        c\n    </span>\n    <span style=\"left:initial;text-decoration:inherit;\">\n    </span>\n    <span id=\"n\">\n        in\n        <strong class=\"lia-bold\">\n            b\n        </strong>\n    </span>\n    <kbd class=\"x\" style=\"color:red\">\n        k\n    </kbd>\n    <span innerHTML=\"<br>\">\n    </span>\n    <span aria-live=\"polite\" class=\"lia-effect--inline x\" role=\"alert\" style=\"color:red\">\n        <span class=\"lia-effect__circle lia-effect__circle--inline\">\n            \u{200A}1\u{200A}\n        </span>\n         \n        e\n        <strong class=\"lia-bold\">\n            f\n        </strong>\n    </span>\n    <span aria-live=\"polite\" class=\"lia-effect--inline\" role=\"alert\">\n        <span class=\"lia-effect__circle lia-effect__circle--inline\">\n            \u{200A}2\u{200A}\n        </span>\n        <label>\n            <button class=\"lia-btn lia-btn--transparent\" style=\"margin:0 5px 0 5px;padding:0;\" onclick=\"window.LIA.playback({\"reply\":true,\"track\":[[\"effect\",0],[\"playback\",3]],\"service\":\"tts\",\"message\":{\"cmd\":\"playback\",\"param\":{\"voice\":\"Deutsch Female\",\"lang\":\"de\",\"text\":this.labels[0]}}})\" tabIndex=\"0\" title=\"Play\">\n                <span class=\"lia-btn__icon icon icon-play-circle\">\n                </span>\n            </button>\n            e\n        </label>\n    </span>\n    \n    <a class=\"lia-link\" href=\"https://a.org\" target=\"_blank\">\n        alt\n    </a>\n    <a class=\"lia-link x\" href=\"https://a.org\" style=\"color:red\" target=\"_blank\" title=\"title\">\n        <strong class=\"lia-bold\">\n            alt\n        </strong>\n    </a>\n    <a class=\"lia-link\" href=\"https://a.org\" target=\"_blank\">\n        alt\n    </a>\n    <a class=\"lia-link\" href=\"#3\" target=\"\">\n        sec\n    </a>\n    <a class=\"lia-link\" href=\"mailto:a@b.de\" target=\"_blank\" title=\"t\">\n        me\n    </a>\n    <figure class=\"lia-figure\">\n        <div class=\"lia-figure__media\" data-media-type=\"image\">\n            <img alt=\"alt\" loading=\"lazy\" onClick=\"window.LIA.img.click(\"img.png\")\" onerror=\"window.LIA.fetchError('img','img.png')\" onload=\"window.LIA.img.load('img.png',this.width,this.height)\" src=\"img.png\">\n        </div>\n        \n    </figure>\n    <figure class=\"lia-figure\">\n        <div class=\"lia-figure__media\" data-media-type=\"image\">\n            <img alt=\"\" loading=\"lazy\" onClick=\"window.LIA.img.click(\"other.png\")\" onerror=\"window.LIA.fetchError('img','other.png')\" onload=\"window.LIA.img.load('other.png',this.width,this.height)\" src=\"other.png\">\n        </div>\n        \n    </figure>\n    <figure class=\"lia-figure\">\n        <div class=\"lia-figure__media\" data-media-type=\"image\">\n            <img alt=\"alt\" class=\"x\" loading=\"lazy\" onerror=\"window.LIA.fetchError('img','other.png')\" onload=\"window.LIA.img.load('other.png',this.width,this.height)\" src=\"other.png\" style=\"color:red\" title=\"cap\">\n        </div>\n        <figcaption class=\"lia-figure__caption\">\n            cap\n        </figcaption>\n    </figure>\n    <figure class=\"lia-figure\">\n        <div class=\"lia-figure__media\" data-media-type=\"audio\">\n            <div>\n                <a class=\"lia-link lia-print-only\" href=\"a.mp3\" title=\"t\">\n                    a\n                </a>\n                <span>\n                    <audio alt=\"a\" class=\"x\" preload=\"none\" style=\"color:red\" title=\"t\" controls>\n                        <source onerror=\"window.LIA.fetchError('audio','a.mp3')\" src=\"a.mp3\">\n                    </audio>\n                </span>\n            </div>\n        </div>\n        <figcaption class=\"lia-figure__caption\">\n            t\n        </figcaption>\n    </figure>\n    <figure class=\"lia-figure\">\n        <div class=\"lia-figure__media\" data-media-type=\"audio\">\n            <div>\n                <a class=\"lia-link lia-print-only\" href=\"https://deezer/x\">\n                    a\n                </a>\n                <iframe style=\"width:100%;\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"a\" class=\"lia-audio x\" loading=\"lazy\" src=\"https://deezer/x\" style=\"color:red\">\n                </iframe>\n            </div>\n        </div>\n        \n    </figure>\n    <figure class=\"lia-figure\">\n        <div class=\"lia-figure__media\" data-media-type=\"movie\">\n            <div>\n                <a class=\"lia-link lia-print-only\" href=\"m.mp4\" title=\"t\">\n                    m\n                </a>\n                <div class=\"lia-video-wrapper\">\n                    <video alt=\"m\" class=\"x\" preload=\"none\" style=\"color:red\" title=\"t\" controls>\n                        <source onerror=\"window.LIA.fetchError('video','m.mp4')\" src=\"m.mp4\">\n                    </video>\n                </div>\n            </div>\n        </div>\n        <figcaption class=\"lia-figure__caption\">\n            t\n        </figcaption>\n    </figure>\n    <figure class=\"lia-figure\">\n        <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n            <div class=\"lia-iframe-wrapper\">\n                <a class=\"lia-link lia-print-only\" href=\"https://www.youtube-nocookie.com/embed/abc\">\n                    m\n                </a>\n                <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" loading=\"lazy\" src=\"https://www.youtube-nocookie.com/embed/abc?hl=English\">\n                    m\n                </iframe>\n            </div>\n        </div>\n        \n    </figure>\n    <figure class=\"lia-figure\">\n        <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n            <div class=\"lia-iframe-wrapper\">\n                <a class=\"lia-link lia-print-only\" href=\"https://www.youtube-nocookie.com/embed/abc?start=3\" title=\"t\">\n                    m\n                </a>\n                <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" class=\"x\" loading=\"lazy\" src=\"https://www.youtube-nocookie.com/embed/abc?start=3&hl=English\" style=\"color:red\" title=\"t\">\n                    m\n                </iframe>\n            </div>\n        </div>\n        <figcaption class=\"lia-figure__caption\">\n            t\n        </figcaption>\n    </figure>\n    <figure class=\"lia-figure\">\n        <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n            <div class=\"lia-iframe-wrapper\">\n                <a class=\"lia-link lia-print-only\" href=\"https://player.vimeo.com/video/1\">\n                    m\n                </a>\n                <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" loading=\"lazy\" src=\"https://player.vimeo.com/video/1\">\n                    m\n                </iframe>\n            </div>\n        </div>\n        \n    </figure>\n    <figure class=\"lia-figure\" style=\"height:auto;width:100%;\">\n        <div class=\"lia-figure__media\">\n            <a class=\"lia-link lia-print-only\" href=\"https://e.org/x\">\n                e\n            </a>\n            <lia-embed class=\"\" style=\"display:inline-block;height:auto;max-height:100%;width:100%;\" data-attributes=\"{}\" url=\"https://e.org/x\">\n            </lia-embed>\n            <figcaption class=\"lia-figure__caption\">\n                <a class=\"lia-link\" href=\"https://e.org/x\" target=\"blank_\">\n                    https://e.org/x\n                </a>\n            </figcaption>\n        </div>\n    </figure>\n    <figure class=\"lia-figure\" style=\"height:auto;width:100%;\">\n        <div class=\"lia-figure__media\">\n            <a class=\"lia-link lia-print-only\" href=\"https://e.org/x\" title=\"cap\">\n                e\n            </a>\n            <lia-embed class=\"\" style=\"display:inline-block;height:auto;max-height:100%;width:100%;\" data-attributes=\"{\"class\":\"x\",\"style\":\"color:red\"}\" url=\"https://e.org/x\">\n            </lia-embed>\n            <figcaption class=\"lia-figure__caption\">\n                cap\n            </figcaption>\n        </div>\n    </figure>\n    <preview-lia class=\"x\" src=\"https://c.org/README.md\" style=\"color:red\">\n    </preview-lia>\n    <preview-link class=\"\" src=\"https://c.org\">\n    </preview-link>\n    <figure class=\"lia-figure\" width=\"300\">\n        <div class=\"lia-figure__media\" data-media-type=\"image\">\n            <a style=\"background-color:white;display:inline-block;width:300px;\" class=\"lia-link\" href=\"https://q.org\">\n                <svg aria-label=\"QR code for website: https://q.org\" shape-rendering=\"crispEdges\" stroke=\"#000\" stroke-width=\"5px\" viewBox=\"0 0 165 165\">\n                    <path d=\"M0 0h35m15 0h5m20 0h10m5 0h35M0 5h5m25 0h5m10 0h30m5 0h5m5 0h5m25 0h5M0 10h5m5 0h15m5 0h5m35 0h15m5 0h5m5 0h15m5 0h5M0 15h5m5 0h15m5 0h5m5 0h10m5 0h5m10 0h5m15 0h5m5 0h15m5 0h5M0 20h5m5 0h15m5 0h5m10 0h5m15 0h15m10 0h5m5 0h15m5 0h5M0 25h5m25 0h5m5 0h5m10 0h5m15 0h5m10 0h5m25 0h5M0 30h35m5 0h5m5 0h5m5 0h5m5 0h5m5 0h5m5 0h35M0 35m40 0h25m5 0h15M0 40m5 0h10m15 0h5m10 0h15m5 0h10m15 0h10m5 0h5M0 45h5m5 0h5m5 0h10m20 0h25m15 0h5m10 0h5m5 0h10M0 50h25m5 0h10m10 0h5m5 0h5m10 0h5m20 0h15m5 0h5M0 55h5m10 0h15m35 0h5m20 0h5m10 0h5M0 60m10 0h15m5 0h5m25 0h10m5 0h10m5 0h5m25 0h5M0 65m5 0h15m5 0h5m5 0h5m20 0h5m15 0h5m5 0h10m15 0h10M0 70m10 0h15m5 0h20m15 0h5m10 0h5m20 0h10m5 0h5M0 75m15 0h5m25 0h5m5 0h5m10 0h40M0 80m25 0h15m5 0h5m5 0h10m5 0h5m5 0h25m10 0h5M0 85m40 0h10m5 0h15m10 0h5m15 0h5m15 0h5M0 90h35m10 0h5m5 0h10m10 0h10m5 0h5m5 0h5m15 0h5M0 95h5m25 0h5m10 0h10m5 0h5m5 0h5m5 0h5m15 0h5m10 0h5M0 100h5m5 0h15m5 0h5m10 0h5m5 0h5m10 0h35M0 105h5m5 0h15m5 0h5m10 0h10m20 0h15m10 0h5m5 0h5M0 110h5m5 0h15m5 0h5m5 0h5m5 0h5m10 0h10m5 0h5m10 0h15m5 0h10M0 115h5m25 0h5m5 0h10m5 0h10m15 0h5m10 0h10M0 120h35m15 0h5m15 0h5m5 0h10m15 0h5m10 0h5\" stroke-width=\"5px\" transform=\"translate(20, 22.5)\">\n                    </path>\n                </svg>\n            </a>\n        </div>\n        \n    </figure>\n    <figure class=\"lia-figure\" width=\"300\">\n        <div class=\"lia-figure__media\" data-media-type=\"image\">\n            <a style=\"background-color:white;display:inline-block;width:300px;\" class=\"lia-link x\" href=\"https://q.org\" style=\"color:red\" title=\"scan\">\n                <svg aria-label=\"QR code for website: https://q.org\" shape-rendering=\"crispEdges\" stroke=\"#000\" stroke-width=\"5px\" viewBox=\"0 0 165 165\">\n                    <path d=\"M0 0h35m15 0h5m20 0h10m5 0h35M0 5h5m25 0h5m10 0h30m5 0h5m5 0h5m25 0h5M0 10h5m5 0h15m5 0h5m35 0h15m5 0h5m5 0h15m5 0h5M0 15h5m5 0h15m5 0h5m5 0h10m5 0h5m10 0h5m15 0h5m5 0h15m5 0h5M0 20h5m5 0h15m5 0h5m10 0h5m15 0h15m10 0h5m5 0h15m5 0h5M0 25h5m25 0h5m5 0h5m10 0h5m15 0h5m10 0h5m25 0h5M0 30h35m5 0h5m5 0h5m5 0h5m5 0h5m5 0h5m5 0h35M0 35m40 0h25m5 0h15M0 40m5 0h10m15 0h5m10 0h15m5 0h10m15 0h10m5 0h5M0 45h5m5 0h5m5 0h10m20 0h25m15 0h5m10 0h5m5 0h10M0 50h25m5 0h10m10 0h5m5 0h5m10 0h5m20 0h15m5 0h5M0 55h5m10 0h15m35 0h5m20 0h5m10 0h5M0 60m10 0h15m5 0h5m25 0h10m5 0h10m5 0h5m25 0h5M0 65m5 0h15m5 0h5m5 0h5m20 0h5m15 0h5m5 0h10m15 0h10M0 70m10 0h15m5 0h20m15 0h5m10 0h5m20 0h10m5 0h5M0 75m15 0h5m25 0h5m5 0h5m10 0h40M0 80m25 0h15m5 0h5m5 0h10m5 0h5m5 0h25m10 0h5M0 85m40 0h10m5 0h15m10 0h5m15 0h5m15 0h5M0 90h35m10 0h5m5 0h10m10 0h10m5 0h5m5 0h5m15 0h5M0 95h5m25 0h5m10 0h10m5 0h5m5 0h5m5 0h5m15 0h5m10 0h5M0 100h5m5 0h15m5 0h5m10 0h5m5 0h5m10 0h35M0 105h5m5 0h15m5 0h5m10 0h10m20 0h15m10 0h5m5 0h5M0 110h5m5 0h15m5 0h5m5 0h5m5 0h5m10 0h10m5 0h5m10 0h15m5 0h10M0 115h5m25 0h5m5 0h10m5 0h10m15 0h5m10 0h10M0 120h35m15 0h5m15 0h5m5 0h10m15 0h5m10 0h5\" stroke-width=\"5px\" transform=\"translate(20, 22.5)\">\n                    </path>\n                </svg>\n            </a>\n        </div>\n        <figcaption class=\"lia-figure__caption\">\n            scan\n        </figcaption>\n    </figure>\n</div>"
          )
        , ( "media chars"
          , "plain"
          )
        , ( "media chars with attr"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    plain\n</span>"
          )
        , ( "media bold"
          , "<strong class=\"lia-bold\">\n    b\n</strong>"
          )
        , ( "media bold attr"
          , "<strong class=\"lia-bold x\" style=\"color:red\">\n    b\n</strong>"
          )
        , ( "media bold nested"
          , "<strong class=\"lia-bold x\" style=\"color:red\">\n    <em class=\"lia-italic\">\n        bi\n    </em>\n</strong>"
          )
        , ( "media italic"
          , "<em class=\"lia-italic x\" style=\"color:red\">\n    i\n</em>"
          )
        , ( "media strike"
          , "<s class=\"lia-strike x\" style=\"color:red\">\n    s\n</s>"
          )
        , ( "media underline"
          , "<u class=\"lia-underline x\" style=\"color:red\">\n    u\n</u>"
          )
        , ( "media superscript"
          , "<sup class=\"lia-superscript x\" style=\"color:red\">\n    sup\n</sup>"
          )
        , ( "media superscript nested"
          , "<sup class=\"lia-superscript\">\n    <span style=\"left:initial;text-decoration:inherit;\">\n        a\n        <strong class=\"lia-bold\">\n            b\n        </strong>\n    </span>\n</sup>"
          )
        , ( "media verbatim"
          , "<code class=\"notranslate lia-code lia-code--inline\" translate=\"no\">\n    code\n</code>"
          )
        , ( "media verbatim attr"
          , "<code class=\"notranslate lia-code lia-code--inline x\" style=\"color:red\" translate=\"no\">\n    code\n</code>"
          )
        , ( "media formula inline"
          , "<lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"a^2\" translate=\"no\">\n</lia-formula>"
          )
        , ( "media formula block"
          , "<lia-formula class=\"notranslate\" displayMode=\"true\" formula=\"\\RR\" translate=\"no\">\n</lia-formula>"
          )
        , ( "media formula attr"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    <lia-formula class=\"notranslate\" displayMode=\"false\" formula=\"x\" translate=\"no\">\n    </lia-formula>\n</span>"
          )
        , ( "media symbol"
          , "→"
          )
        , ( "media symbol attr"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    →\n</span>"
          )
        , ( "media footnote"
          , "<sup>\n    <button class=\"lia-btn lia-btn--transparent text-highlight\" style=\"padding:2px;\" aria-describedby=\"footnote-1\" id=\"footnote-key-1\" onclick=\"window.LIA.showFootnote(\"1\");\" tabIndex=\"0\">\n        [1]\n    </button>\n</sup>"
          )
        , ( "media footnote attr"
          , "<sup>\n    <button class=\"lia-btn lia-btn--transparent text-highlight\" style=\"padding:2px;\" aria-describedby=\"footnote-note\" class=\"x\" id=\"footnote-key-note\" onclick=\"window.LIA.showFootnote(\"note\");\" style=\"color:red\" tabIndex=\"0\">\n        [note]\n    </button>\n</sup>"
          )
        , ( "media container"
          , "<span style=\"left:initial;text-decoration:inherit;\" class=\"x\" style=\"color:red\">\n    a\n    <em class=\"lia-italic\">\n        b\n    </em>\n    c\n</span>"
          )
        , ( "media container empty"
          , "<span style=\"left:initial;text-decoration:inherit;\">\n</span>"
          )
        , ( "media html node"
          , "<span id=\"n\">\n    in\n    <strong class=\"lia-bold\">\n        b\n    </strong>\n</span>"
          )
        , ( "media html node attr"
          , "<kbd class=\"x\" style=\"color:red\">\n    k\n</kbd>"
          )
        , ( "media html inner"
          , "<span innerHTML=\"<br>\">\n</span>"
          )
        , ( "media effect"
          , "<span aria-live=\"polite\" class=\"lia-effect--inline x\" role=\"alert\" style=\"color:red\">\n    <span class=\"lia-effect__circle lia-effect__circle--inline\">\n        \u{200A}1\u{200A}\n    </span>\n     \n    e\n    <strong class=\"lia-bold\">\n        f\n    </strong>\n</span>"
          )
        , ( "media effect range"
          , "<span class=\"lia-effect--inline hide\">\n    <span class=\"lia-effect__circle lia-effect__circle--inline\">\n        \u{200A}2\u{200A}\n    </span>\n    <label>\n        <button class=\"lia-btn lia-btn--transparent\" style=\"margin:0 5px 0 5px;padding:0;\" onclick=\"window.LIA.playback({\"reply\":true,\"track\":[[\"effect\",0],[\"playback\",3]],\"service\":\"tts\",\"message\":{\"cmd\":\"playback\",\"param\":{\"voice\":\"Deutsch Female\",\"lang\":\"de\",\"text\":this.labels[0]}}})\" tabIndex=\"0\" title=\"Play\">\n            <span class=\"lia-btn__icon icon icon-play-circle\">\n            </span>\n        </button>\n        e\n    </label>\n</span>"
          )
        , ( "media script missing"
          , ""
          )
        , ( "media link"
          , "<span>\n    <preview-link src=\"https://a.org\">\n        <a class=\"lia-link\" href=\"https://a.org\" target=\"_blank\">\n            alt\n        </a>\n    </preview-link>\n</span>"
          )
        , ( "media link title attr"
          , "<span>\n    <preview-link src=\"https://a.org\">\n        <a class=\"lia-link x\" href=\"https://a.org\" style=\"color:red\" target=\"_blank\" title=\"title\">\n            <strong class=\"lia-bold\">\n                alt\n            </strong>\n        </a>\n    </preview-link>\n</span>"
          )
        , ( "media link blank title"
          , "<span>\n    <preview-link src=\"https://a.org\">\n        <a class=\"lia-link\" href=\"https://a.org\" target=\"_blank\">\n            alt\n        </a>\n    </preview-link>\n</span>"
          )
        , ( "media link anchor"
          , "<a class=\"lia-link\" href=\"#3\" target=\"\">\n    sec\n</a>"
          )
        , ( "media mail"
          , "<span>\n    <preview-link src=\"mailto:a@b.de\">\n        <a class=\"lia-link\" href=\"mailto:a@b.de\" target=\"_blank\" title=\"t\">\n            me\n        </a>\n    </preview-link>\n</span>"
          )
        , ( "media image"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media lia-figure__zoom\" style=\"background-image:url('img.png');\" data-media-image=\"image\" onmousemove=\"window.LIA.img.zoom(event)\" width=\"320\">\n        <img alt=\"alt\" onerror=\"window.LIA.fetchError('img','img.png')\" src=\"img.png\">\n    </div>\n    \n</figure>"
          )
        , ( "media image no alt"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media  lia-figure__zoom\" style=\"background-image:url('other.png');\" data-media-image=\"image\" onmousemove=\"window.LIA.img.zoom(event)\">\n        <img alt=\"\" onerror=\"window.LIA.fetchError('img','other.png')\" onload=\"window.LIA.img.load('other.png',this.width,this.height)\" src=\"other.png\">\n    </div>\n    \n</figure>"
          )
        , ( "media image title attr"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media  lia-figure__zoom\" style=\"background-image:url('other.png');\" data-media-image=\"image\" onmousemove=\"window.LIA.img.zoom(event)\">\n        <img alt=\"alt\" class=\"x\" onerror=\"window.LIA.fetchError('img','other.png')\" onload=\"window.LIA.img.load('other.png',this.width,this.height)\" src=\"other.png\" style=\"color:red\" title=\"cap\">\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        cap\n    </figcaption>\n</figure>"
          )
        , ( "media audio"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"audio\">\n        <div>\n            <a class=\"lia-link lia-print-only\" href=\"a.mp3\" title=\"t\">\n                a\n            </a>\n            <span>\n                <audio alt=\"a\" class=\"x\" preload=\"none\" style=\"color:red\" title=\"t\" controls>\n                    <source onerror=\"window.LIA.fetchError('audio','a.mp3')\" src=\"a.mp3\">\n                </audio>\n            </span>\n        </div>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        t\n    </figcaption>\n</figure>"
          )
        , ( "media audio tube"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"audio\">\n        <div>\n            <a class=\"lia-link lia-print-only\" href=\"https://deezer/x\">\n                a\n            </a>\n            <iframe style=\"width:100%;\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"a\" class=\"lia-audio x\" src=\"https://deezer/x\" style=\"color:red\">\n            </iframe>\n        </div>\n    </div>\n    \n</figure>"
          )
        , ( "media movie"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"movie\">\n        <div>\n            <a class=\"lia-link lia-print-only\" href=\"m.mp4\" title=\"t\">\n                m\n            </a>\n            <div class=\"lia-video-wrapper\">\n                <video alt=\"m\" class=\"x\" preload=\"none\" style=\"color:red\" title=\"t\" controls>\n                    <source onerror=\"window.LIA.fetchError('video','m.mp4')\" src=\"m.mp4\">\n                </video>\n            </div>\n        </div>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        t\n    </figcaption>\n</figure>"
          )
        , ( "media movie tube youtube"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n        <div class=\"lia-iframe-wrapper\">\n            <a class=\"lia-link lia-print-only\" href=\"https://www.youtube-nocookie.com/embed/abc\">\n                m\n            </a>\n            <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" src=\"https://www.youtube-nocookie.com/embed/abc?hl=fr\">\n                m\n            </iframe>\n        </div>\n    </div>\n    \n</figure>"
          )
        , ( "media movie tube youtube query"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n        <div class=\"lia-iframe-wrapper\">\n            <a class=\"lia-link lia-print-only\" href=\"https://www.youtube-nocookie.com/embed/abc?start=3\" title=\"t\">\n                m\n            </a>\n            <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" class=\"x\" src=\"https://www.youtube-nocookie.com/embed/abc?start=3&hl=fr\" style=\"color:red\" title=\"t\">\n                m\n            </iframe>\n        </div>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        t\n    </figcaption>\n</figure>"
          )
        , ( "media movie tube other"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"iframe\">\n        <div class=\"lia-iframe-wrapper\">\n            <a class=\"lia-link lia-print-only\" href=\"https://player.vimeo.com/video/1\">\n                m\n            </a>\n            <iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"\" alt=\"m\" src=\"https://player.vimeo.com/video/1\">\n                m\n            </iframe>\n        </div>\n    </div>\n    \n</figure>"
          )
        , ( "media embed"
          , "<figure class=\"lia-figure\" style=\"height:auto;width:100%;\">\n    <div class=\"lia-figure__media\">\n        <a class=\"lia-link lia-print-only\" href=\"https://e.org/x\">\n            e\n        </a>\n        <lia-embed class=\"\" style=\"display:inline-block;height:auto;max-height:100%;width:100%;\" data-attributes=\"{}\" url=\"https://e.org/x\">\n        </lia-embed>\n        <figcaption class=\"lia-figure__caption\">\n            <a class=\"lia-link\" href=\"https://e.org/x\" target=\"blank_\">\n                https://e.org/x\n            </a>\n        </figcaption>\n    </div>\n</figure>"
          )
        , ( "media embed title attr"
          , "<figure class=\"lia-figure\" style=\"height:auto;width:100%;\">\n    <div class=\"lia-figure__media\">\n        <a class=\"lia-link lia-print-only\" href=\"https://e.org/x\" title=\"cap\">\n            e\n        </a>\n        <lia-embed class=\"\" style=\"display:inline-block;height:auto;max-height:100%;width:100%;\" data-attributes=\"{\"class\":\"x\",\"style\":\"color:red\"}\" url=\"https://e.org/x\">\n        </lia-embed>\n        <figcaption class=\"lia-figure__caption\">\n            cap\n        </figcaption>\n    </div>\n</figure>"
          )
        , ( "media preview lia"
          , "<preview-lia class=\"x\" src=\"https://c.org/README.md\" style=\"color:red\">\n</preview-lia>"
          )
        , ( "media preview link"
          , "<preview-link class=\"\" src=\"https://c.org\">\n</preview-link>"
          )
        , ( "media qr"
          , "<figure class=\"lia-figure\" width=\"300\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <a style=\"background-color:white;display:inline-block;width:300px;\" class=\"lia-link\" href=\"https://q.org\">\n            <svg aria-label=\"QR-Code für Webseite: https://q.org\" shape-rendering=\"crispEdges\" stroke=\"#000\" stroke-width=\"5px\" viewBox=\"0 0 165 165\">\n                <path d=\"M0 0h35m15 0h5m20 0h10m5 0h35M0 5h5m25 0h5m10 0h30m5 0h5m5 0h5m25 0h5M0 10h5m5 0h15m5 0h5m35 0h15m5 0h5m5 0h15m5 0h5M0 15h5m5 0h15m5 0h5m5 0h10m5 0h5m10 0h5m15 0h5m5 0h15m5 0h5M0 20h5m5 0h15m5 0h5m10 0h5m15 0h15m10 0h5m5 0h15m5 0h5M0 25h5m25 0h5m5 0h5m10 0h5m15 0h5m10 0h5m25 0h5M0 30h35m5 0h5m5 0h5m5 0h5m5 0h5m5 0h5m5 0h35M0 35m40 0h25m5 0h15M0 40m5 0h10m15 0h5m10 0h15m5 0h10m15 0h10m5 0h5M0 45h5m5 0h5m5 0h10m20 0h25m15 0h5m10 0h5m5 0h10M0 50h25m5 0h10m10 0h5m5 0h5m10 0h5m20 0h15m5 0h5M0 55h5m10 0h15m35 0h5m20 0h5m10 0h5M0 60m10 0h15m5 0h5m25 0h10m5 0h10m5 0h5m25 0h5M0 65m5 0h15m5 0h5m5 0h5m20 0h5m15 0h5m5 0h10m15 0h10M0 70m10 0h15m5 0h20m15 0h5m10 0h5m20 0h10m5 0h5M0 75m15 0h5m25 0h5m5 0h5m10 0h40M0 80m25 0h15m5 0h5m5 0h10m5 0h5m5 0h25m10 0h5M0 85m40 0h10m5 0h15m10 0h5m15 0h5m15 0h5M0 90h35m10 0h5m5 0h10m10 0h10m5 0h5m5 0h5m15 0h5M0 95h5m25 0h5m10 0h10m5 0h5m5 0h5m5 0h5m15 0h5m10 0h5M0 100h5m5 0h15m5 0h5m10 0h5m5 0h5m10 0h35M0 105h5m5 0h15m5 0h5m10 0h10m20 0h15m10 0h5m5 0h5M0 110h5m5 0h15m5 0h5m5 0h5m5 0h5m10 0h10m5 0h5m10 0h15m5 0h10M0 115h5m25 0h5m5 0h10m5 0h10m15 0h5m10 0h10M0 120h35m15 0h5m15 0h5m5 0h10m15 0h5m10 0h5\" stroke-width=\"5px\" transform=\"translate(20, 22.5)\">\n                </path>\n            </svg>\n        </a>\n    </div>\n    \n</figure>"
          )
        , ( "media qr title attr"
          , "<figure class=\"lia-figure\" width=\"300\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <a style=\"background-color:white;display:inline-block;width:300px;\" class=\"lia-link x\" href=\"https://q.org\" style=\"color:red\" title=\"scan\">\n            <svg aria-label=\"QR-Code für Webseite: https://q.org\" shape-rendering=\"crispEdges\" stroke=\"#000\" stroke-width=\"5px\" viewBox=\"0 0 165 165\">\n                <path d=\"M0 0h35m15 0h5m20 0h10m5 0h35M0 5h5m25 0h5m10 0h30m5 0h5m5 0h5m25 0h5M0 10h5m5 0h15m5 0h5m35 0h15m5 0h5m5 0h15m5 0h5M0 15h5m5 0h15m5 0h5m5 0h10m5 0h5m10 0h5m15 0h5m5 0h15m5 0h5M0 20h5m5 0h15m5 0h5m10 0h5m15 0h15m10 0h5m5 0h15m5 0h5M0 25h5m25 0h5m5 0h5m10 0h5m15 0h5m10 0h5m25 0h5M0 30h35m5 0h5m5 0h5m5 0h5m5 0h5m5 0h5m5 0h35M0 35m40 0h25m5 0h15M0 40m5 0h10m15 0h5m10 0h15m5 0h10m15 0h10m5 0h5M0 45h5m5 0h5m5 0h10m20 0h25m15 0h5m10 0h5m5 0h10M0 50h25m5 0h10m10 0h5m5 0h5m10 0h5m20 0h15m5 0h5M0 55h5m10 0h15m35 0h5m20 0h5m10 0h5M0 60m10 0h15m5 0h5m25 0h10m5 0h10m5 0h5m25 0h5M0 65m5 0h15m5 0h5m5 0h5m20 0h5m15 0h5m5 0h10m15 0h10M0 70m10 0h15m5 0h20m15 0h5m10 0h5m20 0h10m5 0h5M0 75m15 0h5m25 0h5m5 0h5m10 0h40M0 80m25 0h15m5 0h5m5 0h10m5 0h5m5 0h25m10 0h5M0 85m40 0h10m5 0h15m10 0h5m15 0h5m15 0h5M0 90h35m10 0h5m5 0h10m10 0h10m5 0h5m5 0h5m15 0h5M0 95h5m25 0h5m10 0h10m5 0h5m5 0h5m5 0h5m15 0h5m10 0h5M0 100h5m5 0h15m5 0h5m10 0h5m5 0h5m10 0h35M0 105h5m5 0h15m5 0h5m10 0h10m20 0h15m10 0h5m5 0h5M0 110h5m5 0h15m5 0h5m5 0h5m5 0h5m10 0h10m5 0h5m10 0h15m5 0h10M0 115h5m25 0h5m5 0h10m5 0h10m15 0h5m10 0h10M0 120h35m15 0h5m15 0h5m5 0h10m15 0h5m10 0h5\" stroke-width=\"5px\" transform=\"translate(20, 22.5)\">\n                </path>\n            </svg>\n        </a>\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        scan\n    </figcaption>\n</figure>"
          )
        , ( "media image config"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media  lia-figure__zoom\" style=\"background-image:url('img.png');\" data-media-image=\"image\" onmousemove=\"window.LIA.img.zoom(event)\">\n        <img alt=\"alt\" class=\"x\" onerror=\"window.LIA.fetchError('img','img.png')\" onload=\"window.LIA.img.load('img.png',this.width,this.height)\" src=\"img.png\" style=\"color:red\" title=\"t\">\n    </div>\n    <figcaption class=\"lia-figure__caption\">\n        t\n    </figcaption>\n</figure>"
          )
        , ( "media oembed"
          , "<figure class=\"lia-figure\" style=\"height:auto;width:100%;\">\n    <div class=\"lia-figure__media\">\n        <a class=\"lia-link lia-print-only\" href=\"https://e.org/x\">\n            e\n        </a>\n        <lia-embed style=\"display:inline-block;height:auto;max-height:100%;width:300px;\" data-attributes=\"{\"class\":\"x\",\"style\":\"color:red\"}\" scale=\"0.5\" url=\"https://e.org/x\" thumbnail>\n        </lia-embed>\n        <figcaption class=\"lia-figure__caption\">\n            <a class=\"lia-link\" href=\"https://e.org/x\" target=\"blank_\">\n                https://e.org/x\n            </a>\n        </figcaption>\n    </div>\n</figure>"
          )
        , ( "media oembed height"
          , "<figure class=\"lia-figure\" style=\"height:auto;width:100%;\">\n    <div class=\"lia-figure__media\">\n        <a class=\"lia-link lia-print-only\" href=\"https://e.org/x\">\n            e\n        </a>\n        <lia-embed style=\"display:inline-block;height:200px;max-height:100%;width:100%;\" data-attributes=\"{}\" scale=\"1\" url=\"https://e.org/x\">\n        </lia-embed>\n        <figcaption class=\"lia-figure__caption\">\n            <a class=\"lia-link\" href=\"https://e.org/x\" target=\"blank_\">\n                https://e.org/x\n            </a>\n        </figcaption>\n    </div>\n</figure>"
          )
        , ( "image no zoom"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <img alt=\"alt\" loading=\"lazy\" onerror=\"window.LIA.fetchError('img','img.png')\" onload=\"window.LIA.img.load('img.png',this.width,this.height)\" src=\"img.png\">\n    </div>\n    \n</figure>"
          )
        , ( "quiz drops"
          , "<div>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;cursor:pointer;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"true\" draggable=\"true\" onclick=\"on(dragsource,0,[0,0])\" ondragend=\"on(dragend,0,[0,0])\" ondragstart=\"on(dragstart,0,[0,0])\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(dragsource,0,[0,0])\" role=\"button\" tabIndex=\"0\">\n        opt0\n    </span>\n    \n    \n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;cursor:pointer;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" draggable=\"true\" onclick=\"on(dragsource,2,[2,0])\" ondragend=\"on(dragend,2,[2,0])\" ondragstart=\"on(dragstart,2,[2,0])\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(dragsource,2,[2,0])\" role=\"button\" tabIndex=\"0\">\n        opt0\n    </span>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;cursor:pointer;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" draggable=\"true\" onclick=\"on(dragsource,2,[2,1])\" ondragend=\"on(dragend,2,[2,1])\" ondragstart=\"on(dragstart,2,[2,1])\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(dragsource,2,[2,1])\" role=\"button\" tabIndex=\"0\">\n        <strong class=\"lia-bold\">\n            opt1\n        </strong>\n    </span>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;cursor:pointer;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" draggable=\"true\" onclick=\"on(dragsource,2,[2,2])\" ondragend=\"on(dragend,2,[2,2])\" ondragstart=\"on(dragstart,2,[2,2])\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(dragsource,2,[2,2])\" role=\"button\" tabIndex=\"0\">\n        opt2\n    </span>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;cursor:pointer;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" draggable=\"true\" onclick=\"on(dragsource,3,[3,0])\" ondragend=\"on(dragend,3,[3,0])\" ondragstart=\"on(dragstart,3,[3,0])\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(dragsource,3,[3,0])\" role=\"button\" tabIndex=\"0\">\n        opt0\n    </span>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;cursor:pointer;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" draggable=\"true\" onclick=\"on(dragsource,3,[3,1])\" ondragend=\"on(dragend,3,[3,1])\" ondragstart=\"on(dragstart,3,[3,1])\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(dragsource,3,[3,1])\" role=\"button\" tabIndex=\"0\">\n        <strong class=\"lia-bold\">\n            opt1\n        </strong>\n    </span>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;cursor:pointer;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" draggable=\"true\" onclick=\"on(dragsource,3,[3,2])\" ondragend=\"on(dragend,3,[3,2])\" ondragstart=\"on(dragstart,3,[3,2])\" onkeydown=\"if(event.key===' '||event.key==='Enter')on(dragsource,3,[3,2])\" role=\"button\" tabIndex=\"0\">\n        opt2\n    </span>\n</div>"
          )
        , ( "quiz drops inactive"
          , "<div>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"true\" role=\"button\" tabIndex=\"0\">\n        opt0\n    </span>\n    \n    \n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" role=\"button\" tabIndex=\"0\">\n        opt0\n    </span>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" role=\"button\" tabIndex=\"0\">\n        <strong class=\"lia-bold\">\n            opt1\n        </strong>\n    </span>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" role=\"button\" tabIndex=\"0\">\n        opt2\n    </span>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" role=\"button\" tabIndex=\"0\">\n        opt0\n    </span>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" role=\"button\" tabIndex=\"0\">\n        <strong class=\"lia-bold\">\n            opt1\n        </strong>\n    </span>\n    <span style=\"background-color:#88888822;border:3px dotted #888;border-radius:4px;display:inline-block;margin:0.25rem;padding:1rem;\" aria-grabbed=\"false\" role=\"button\" tabIndex=\"0\">\n        opt2\n    </span>\n</div>"
          )
        , ( "drop here"
          , "<div class=\"x\" style=\"align-items:center;color:#888;display:flex;justify-content:center;line-height:1;min-width:3rem;\">\n    ✛\n</div>"
          )
        , ( "audio"
          , "<span>\n    <audio preload=\"auto\">\n        <source src=\"a.mp3\">\n    </audio>\n</span>"
          )
        , ( "audio error"
          , "<span>\n    <audio preload=\"none\" controls>\n        <source onerror=\"window.LIA.fetchError('audio','a.mp3')\" src=\"a.mp3\">\n    </audio>\n</span>"
          )
        , ( "view_inf"
          , "<figure class=\"lia-figure\">\n    <div class=\"lia-figure__media\" data-media-type=\"image\">\n        <img alt=\"alt\" loading=\"lazy\" onClick=\"window.LIA.img.click(\"img.png\")\" onerror=\"window.LIA.fetchError('img','img.png')\" onload=\"window.LIA.img.load('img.png',this.width,this.height)\" src=\"img.png\">\n    </div>\n    \n</figure>"
          )
        , ( "view_inf media"
          , "<span style=\"left:initial;text-decoration:inherit;\">\n    <figure class=\"lia-figure\" width=\"1\">\n        <div class=\"lia-figure__media\" data-media-type=\"image\">\n            <img alt=\"\" loading=\"lazy\" onClick=\"window.LIA.img.click(\"img.png\")\" onerror=\"window.LIA.fetchError('img','img.png')\" src=\"img.png\">\n        </div>\n        \n    </figure>\n    <span>\n        <preview-link src=\"https://l.org\">\n            <a class=\"lia-link\" href=\"https://l.org\" target=\"_blank\">\n                l\n            </a>\n        </preview-link>\n    </span>\n</span>"
          )
        ]
