"use strict";
/*global exports*/

exports.registerPorts = function(app) {
  app.ports.scrollToBottom.subscribe(function(elementId) {
    var element = document.getElementById(elementId);

    if (element) {
      element.scrollTo({ top: element.scrollHeight, behavior: 'smooth' });
    } else {
      console.error("Cannot scroll to elementId - it does not exist.", elementId);
    }
  });
};
