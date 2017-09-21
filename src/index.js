//var $ = require("jquery");

// var Lia = {
//     init (elment, url, script) {
//         Elm.Main.embed(elment, {url: url, script: script});
//     }
// }

//export default Lia;

// let Lia = {
//     init(element, url, script) {
//         if (!element) { return }
//
//         Elm.Main.embed(element, {url: url, script: script});
//     },
// }
//
// export default Lia

/*$(function () {
    // store created ripple from mousedown until mouseup
    var $ripple;

    $(".lia-btn").on("mousedown", function (ev) {
        ev.preventDefault();

        $ripple = $('<div class="lia-ripple"></div>');
        var btn_pos = $(this).offset();
        var offset = {
            x: ev.pageX - btn_pos.left,
            y: ev.pageY - btn_pos.top,
        };
        var btn_width = $(this).width();
        var btn_height = $(this).height();
        var size = btn_width > btn_height ? btn_width : btn_height;
        size *= 4;

        // first append to DOM, to trigger transition correctly
        $ripple.appendTo($(this));

        // decouple setting of css from this thread to trigger transition
        window.setTimeout(function () {
            $ripple.css({
                top: offset.y,
                left: offset.x,
                width: size,
                height: size,
                margin: -size / 2,
                opacity: 0.25,
            });
        }, 0);
    });

    $(document).on("mouseup", function() {
        var $old_ripple = $($ripple);
        $old_ripple.css({
            opacity: 0,
        });

        window.setTimeout(function () {
            $old_ripple.remove();
        }, 500);
    });
});*/
