function MailCtrl($scope, $rootScope) {
    var ws = new WebSocket("wss://127.0.0.1:9999/websocket");     

    ws.onopen = function() {
    var SendObj = {"ws": "start"};
	ws.send(JSON.stringify(SendObj));
    };
        
    ws.onclose = function() {
        alert("Connection closed");  
    };

    ws.onmessage = function(evt) {
        var mailBoxes = JSON.parse(evt.data);
        $scope.message = {inbox: mailBoxRetStr(mailBoxes.INBOX[1]),
                          email: mailBoxes.email,
                          sent: mailBoxRetStr(mailBoxes.Sent[1]),
                          drafts: mailBoxRetStr(mailBoxes.Drafts[1]),
                          spam: mailBoxRetStr(mailBoxes.SPAM[1]),
                          trash: mailBoxRetStr(mailBoxes.Trash[1])};
        $scope.$digest();
    };
}

function mailBoxRetStr(string) {
    if(parseInt(string) == 0) {
        return '';    
    } else {
        return "(" + string + ")";    
    }
}
