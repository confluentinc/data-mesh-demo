import './static/main.less';
import logoPath from './static/images/logo.png';
import {Elm} from './src/Main.elm';
import "uikit/dist/css/uikit.min.css";
import "uikit/dist/js/uikit.min.js";
import "uikit/dist/js/uikit-icons.js";

var socket = new WebSocket("ws://" + window.location.host + "/priv/socket", ["v12.stomp"]);
socket.onopen = function() {
  var app = Elm.Main.init({
    node: document.getElementById("app"),
    flags: {
      images: {
        logo: logoPath
      }
    }
  });

  app.ports.socket.subscribe(function(data) {
    socket.send(data);
  });
  socket.onmessage = function(event) {
    app.ports.onMessage.send(event.data);
  };
};
