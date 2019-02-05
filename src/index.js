import './scss/main.scss';

import {LiaScript} from './javascript/liascript/index.js';

if (process.env.NODE_ENV !== 'production') {
    var app = new LiaScript(document.body, true);
} else {
    var app = new LiaScript(document.body, false);
}
