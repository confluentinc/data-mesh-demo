"use strict";
/*global exports*/

exports.registerPorts = function(app, socket) {
  app.ports.socket.subscribe(function(data) {
    socket.send(data);
  });
  socket.onmessage = function(event) {
    app.ports.onMessage.send(event.data);
  };
};
