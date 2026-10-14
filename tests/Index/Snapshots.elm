module Index.Snapshots exposing (snapshots)

{-| Recorded from the view before the refactoring.
-}


snapshots : List ( String, String )
snapshots =
    [ ( "search empty"
      , "<div>\n    <input class=\"lia-input\" aria-hidden=\"false\" id=\"lia-input-search\" placeholder=\"Search\" tabIndex=\"0\" type=\"search\" value=\"\">\n    <span class=\"icon icon-search\">\n    </span>\n    \n    \n</div>"
      )
    , ( "search inactive"
      , "<div>\n    <input class=\"lia-input\" aria-hidden=\"true\" id=\"lia-input-search\" placeholder=\"Suche\" tabIndex=\"-1\" type=\"search\" value=\"\">\n    <span class=\"icon icon-search\">\n    </span>\n    \n    \n</div>"
      )
    , ( "search no result"
      , "<div>\n    <input class=\"lia-input\" aria-hidden=\"false\" id=\"lia-input-search\" placeholder=\"Search\" tabIndex=\"0\" type=\"search\" value=\"x\">\n    <span class=\"icon icon-search\">\n    </span>\n    <button class=\"lia-toc__clear-index\" tabIndex=\"0\" title=\"clear search\">\n        <i class=\"lia-btn__icon icon icon-close\">\n        </i>\n    </button>\n    <span class=\"hidden-visually\" aria-live=\"assertive\">\n        no results\n    </span>\n</div>"
      )
    , ( "search one result"
      , "<div>\n    <input class=\"lia-input\" aria-hidden=\"false\" id=\"lia-input-search\" placeholder=\"Search\" tabIndex=\"0\" type=\"search\" value=\"x\">\n    <span class=\"icon icon-search\">\n    </span>\n    <button class=\"lia-toc__clear-index\" tabIndex=\"0\" title=\"clear search\">\n        <i class=\"lia-btn__icon icon icon-close\">\n        </i>\n    </button>\n    <span class=\"hidden-visually\" aria-live=\"assertive\">\n        one result\n    </span>\n</div>"
      )
    , ( "search results"
      , "<div>\n    <input class=\"lia-input\" aria-hidden=\"true\" id=\"lia-input-search\" placeholder=\"Search\" tabIndex=\"-1\" type=\"search\" value=\"x\">\n    <span class=\"icon icon-search\">\n    </span>\n    <button class=\"lia-toc__clear-index\" tabIndex=\"-1\" title=\"clear search\">\n        <i class=\"lia-btn__icon icon icon-close\">\n        </i>\n    </button>\n    <span class=\"hidden-visually\" aria-live=\"assertive\">\n        2 results\n    </span>\n</div>"
      )
    , ( "content"
      , "<div>\n    <a class=\"lia-toc__link lia-toc__link--is-lvl-1 hide\" aria-hidden=\"false\" href=\"#1\" tabIndex=\"0\">\n        b\n    </a>\n    <a class=\"lia-active lia-toc__link lia-toc__link--is-lvl-2\" aria-hidden=\"false\" href=\"#2\" id=\"focusedToc\" tabIndex=\"0\">\n        d\n    </a>\n    <a class=\"lia-toc__link lia-toc__link--is-lvl-3\" aria-hidden=\"false\" href=\"#3\" tabIndex=\"0\">\n        **e**\n    </a>\n</div>"
      )
    , ( "content inactive"
      , "<div>\n    <a class=\"lia-active lia-toc__link lia-toc__link--is-lvl-1\" aria-hidden=\"true\" href=\"#1\" id=\"focusedToc\" tabIndex=\"-1\">\n        b\n    </a>\n</div>"
      )
    , ( "bottom"
      , "<button class=\"lia-btn  lia-btn--transparent\" aria-hidden=\"false\" id=\"lia-btn-home\" tabIndex=\"0\">\n    <i class=\"icon icon-grid\" aria-hidden=\"true\">\n    </i>\n    <span class=\"lia-btn__text\">\n        Home\n    </span>\n</button>"
      )
    , ( "bottom inactive"
      , "<button class=\"lia-btn  lia-btn--transparent\" aria-hidden=\"true\" id=\"lia-btn-home\" tabIndex=\"-1\">\n    <i class=\"icon icon-grid\" aria-hidden=\"true\">\n    </i>\n    <span class=\"lia-btn__text\">\n        Übersicht\n    </span>\n</button>"
      )
    ]
