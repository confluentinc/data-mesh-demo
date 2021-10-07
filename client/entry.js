/*global WebSocket*/

import './static/main.less';
import logoPath from './static/images/logo.png';
import exportScreenshotPath from './static/images/export.png';
import schemaScreenshotPath from './static/images/schema.png';
import topicScreenshotPath from './static/images/topic.png';
import lineageScreenshotPath from './static/images/lineage.png';

import { Elm } from './src/Main.elm';
import "uikit/dist/css/uikit.min.css";
import "uikit/dist/js/uikit.min.js";
import "uikit/dist/js/uikit-icons.js";

var protocol = window.location.protocol == "https:" ? "wss:" : "ws:";
var socket = new WebSocket(protocol + "//" + window.location.host + "/priv/socket", ["v12.stomp"]);

socket.onopen = function() {
  var app = Elm.Main.init({
    node: document.getElementById("app"),
    flags: {
      staticImages: {
        logoPath: logoPath,
        exportScreenshotPath: exportScreenshotPath,
        schemaScreenshotPath: schemaScreenshotPath,
        topicScreenshotPath: topicScreenshotPath,
        lineageScreenshotPath: lineageScreenshotPath
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
