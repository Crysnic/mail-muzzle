function MailCtrl($scope) {
    var ws = new WebSocket("wss://127.0.0.1:9999/websocket");     

    ws.onopen = function() {
    var SendObj = {"ws": "start"};
	ws.send(JSON.stringify(SendObj));
    };
        
    ws.onclose = function() {
        alert("Connection closed");  
    };

    ws.onmessage = function(evt) {
        var retArray = JSON.parse(evt.data);
        if(retArray[0] == "INBOX") {
            alert("Inbox " + retArray[1][1]);
            message.inbox = retArray[1][1];
        };
    };
}
