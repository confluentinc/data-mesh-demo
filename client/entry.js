"use strict";
/*global WebSocket*/

import "uikit/dist/css/uikit.min.css";
import './static/styles/main.less';


import logoPath from './static/images/logo.png';
import exportScreenshotPath from './static/images/export.png';
import schemaScreenshotPath from './static/images/schema.png';
import topicScreenshotPath from './static/images/topic.png';
import lineageScreenshotPath from './static/images/lineage.png';
import landingImage1Path from './static/images/landing/landing-p1.svg';
import landingImage2Path from './static/images/landing/landing-p2.svg';
import landingImage3Path from './static/images/landing/landing-p3.svg';

import * as Stomp from './src/Stomp';
import * as Scrolling from './src/Scrolling';
import { Elm } from './src/Main.elm';

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
        lineageScreenshotPath: lineageScreenshotPath,
        landingImage1Path: landingImage1Path,
        landingImage2Path: landingImage2Path,
        landingImage3Path: landingImage3Path
      }
    }
  });

  Stomp.registerPorts(app, socket);
  Scrolling.registerPorts(app);
};
