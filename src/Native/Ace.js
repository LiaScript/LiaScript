var _user$project$Native_Ace = function() {

// TODO Check memory leaks
// TODO Set options directly to Ace, maybe...

// Source: http://unscriptable.com/2009/03/20/debouncing-javascript-methods/
var debounced = function (func, threshold, execAsap) {

    var timeout;

    return function debounced () {
        var obj = this, args = arguments;
        function delayed () {
            if (!execAsap)
                func.apply(obj, args);
            timeout = null;
        };

        if (timeout)
            clearTimeout(timeout);
        else if (execAsap)
            func.apply(obj, args);

        timeout = setTimeout(delayed, threshold || 100);
    };

}

// VIRTUAL-DOM WIDGETS

// `toHtml` called everytime component appeared or model changed
function toHtml(factList, skipChildren) {
    var model = extractModel(factList);
    // Ace event's uses this facts to dispatch custom event
    return _elm_lang$virtual_dom$Native_VirtualDom.custom(factList, model, implementation);
}

function emptyModel() {
    return {
        theme: null,
        mode: null,
        value: null,
        shared: null,
        showPrintMargin: true,
        highlightActiveLine: true,
        tabSize: 4,
        useSoftTabs: true,
        useWrapMode: false,
        readOnly: false,
        showCursor: true,
        showGutter: true,
        extensions: [],
        maxLines: Infinity,
        annotations : []
    };
}

function extractModel(factList) {
    var model = emptyModel();
    var current = factList;
    while (current.ctor != "[]") {
        var payload = current._0;
        // TODO Consider to use map of functions instead of large switch/case
        switch (payload.key) {
            case "AceTheme":
                model.theme = payload.value;
                break;
            case "AceMode":
                model.mode = payload.value;
                break;
            case "AceValue":
                model.value = payload.value;
                break;
            case "AceShowPrintMargin":
                model.showPrintMargin = payload.value;
                break;
            case "AceHighlightActiveLine":
                model.highlightActiveLine = payload.value;
                break;
            case "AceTabSize":
                model.tabSize = payload.value;
                break;
            case "AceUseSoftTabs":
                model.useSoftTabs = payload.value;
                break;
            case "AceUseWrapMode":
                model.useWrapMode = payload.value;
                break;
            case "AceReadOnly":
                model.readOnly = payload.value;
                break;
            case "AceShowCursor":
                model.showCursor = payload.value;
                break;
            case "AceShowGutter":
                model.showGutter = payload.value;
                break;
            case "AceEnableBasicAutocompletion":
                model.enableBasicAutocompletion = payload.value;
                break;
            case "AceEnableLiveAutocompletion":
                model.enableLiveAutocompletion = payload.value;
                break;
            case "AceEnableSnippets":
                model.enableSnippets = payload.value;
                break;
            case "AceExtensions":
                model.extensions = payload.value;
                break;
            case "AceMaxLines":
                model.maxLines = payload.value;
                break;
            case "AceAnnotations":
                model.annotations = payload.value;
                break;

        }
        current = current._1;
    }
    return model;
}

// WIDGET IMPLEMENTATION

var implementation = {
    render: render,
    diff: diff
};

//
// `render` function calls everytime component appeared on th screen
// if you have tabs/pages and component hides it will be destroyed
// and new one created when you back to tab with this component
// `render` also be called
//
// It's impossible to detect when it destroyed, because it needs DOMNodeRemoved event
// which fires when component self-destroyed, but this API was deprecated
// and only MutationObserver available. The last needs an information about a parent
// which isn't available, because `div` created dynamically and will attached
// to tree later. Information about parent isn't available here.
//
function render(model) {
    var shared = {
        // Shared reference to an editor instance
        editor: null,
        // Skip next flag to prevent self-updates (much of them can drop typed symbols)
        skipNext: false,
    };
    var div = document.createElement('div');
    // TODO It replaces class
    div.setAttribute("class", "elm-ace");

    for (var ext in model.extensions) {
        ace.require("ace/ext/" + ext);
    }
    var editor = ace.edit(div);
    shared.editor = editor;

    editor.$blockScrolling = Infinity; // won't use deprecated
    editor.setOptions({
        showPrintMargin: model.showPrintMargin,
        highlightActiveLine: model.highlightActiveLine,
        showGutter: model.showGutter,
        maxLines: model.maxLines,
        autoScrollEditorIntoView: true
    });
    //editor.setAutoScrollEditorIntoView(true);

    editor.renderer.setScrollMargin(8, 8, 8, 8);

    if (!model.showCursor)
        editor.renderer.$cursorLayer.element.style.display = "none"
    editor.getSession().setTabSize(model.tabSize);
    editor.getSession().setUseSoftTabs(model.useSoftTabs);
    editor.getSession().setUseWrapMode(model.useWrapMode);
    editor.getSession().setValue(model.value || "");

    var dummy = emptyModel();
    dummy.shared = shared;
    // It uses editor instance of prev and copy it to new
    diff({ model: dummy }, { model: model })

    // To resize automatically
    editor.setAutoScrollEditorIntoView(true);

    var changer = function(_val) {
        var new_source = editor.getSession().getValue();
        div.value = new_source;
        var event = new Event('AceSourceChange');
        // Infinite loops are impossible, bacause Elm never calls `diff` inside handlers
        shared.skipNext = true;
        div.dispatchEvent(event);
        div.value = null;
    };

    // Add debounce, because "change" event is extremelly often
    // and value of Ace and model can be in different state
    editor.on("change", debounced(changer, 150, false));

    return div;
}

// `diff` called everytime view updates, but you are still on the same page
function diff(prev, next) {
    var pm = prev.model;
    var nm = next.model;
    var shared = pm.shared;
    var editor = shared.editor;
    var session = editor.getSession();

    if (pm.theme != nm.theme) {
        editor.setTheme("ace/theme/" + nm.theme);
    }

    if (pm.readOnly != nm.readOnly) {
      editor.setOptions({ readOnly: nm.readOnly });
    }


    if (pm.mode != nm.mode) {
        session.setMode("ace/mode/" + nm.mode);
    }

    if (!shared.skipNext && nm.value != editor.getValue()) {
        var pos = editor.getCursorPositionScreen();
        if (nm.value != null) {
            editor.setValue(nm.value, pos);
        }
    }

    if (pm.annotations != nm.annotations) {
        if (nm.annotations == null)
            editor.getSession().setAnnotations([]);
        else
            editor.getSession().setAnnotations(nm.annotations);
    }

    // Keep reference to shared state
    shared.skipNext = false;
    nm.shared = shared;


    // It's not necessary to use patches, because Ace do changes itself
    // But It usesd to inform Ace about changes
    return null;
}

return {
    toHtml: F2(toHtml),
};
}();
