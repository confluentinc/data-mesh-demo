import './static/main.less';
import {Elm} from './src/Main.elm';
import "uikit/dist/css/uikit.min.css";
import "uikit/dist/js/uikit.min.js";
import "uikit/dist/js/uikit-icons.js";

Elm.Main.init({node: document.getElementById("app")});
