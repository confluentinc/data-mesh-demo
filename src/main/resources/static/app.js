var stompClient = null;

function setConnected(connected) {
    $("#connect").prop("disabled", connected);
    $("#disconnect").prop("disabled", !connected);
    $("#auditevents").html("");
}

function connect() {
    var protocol = window.location.protocol == "https:" ? "wss:" : "ws:";
    var socket = new WebSocket(protocol + "//" + window.location.host + "/priv/socket", ["v12.stomp"]);
    stompClient = Stomp.over(socket);
    stompClient.connect({}, function (frame) {
        setConnected(true);
        console.log('Connected: ' + frame);
        stompClient.subscribe('/topic/audit-log', function (event) {
            showEvent(JSON.parse(event.body));
        });
    });
}

function disconnect() {
    if (stompClient !== null) {
        stompClient.disconnect();
    }
    setConnected(false);
    console.log("Disconnected");
}

function showEvent(event) {
    console.log(event.message);
    $("#auditevents").append("<tr><td>" + event.message + "</td></tr>");
}

$(function () {
    $("form").on('submit', function (e) {
        e.preventDefault();
    });
    $( "#connect" ).click(function() { connect(); });
    $( "#disconnect" ).click(function() { disconnect(); });
});
