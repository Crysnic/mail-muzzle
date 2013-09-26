function MailCtrl($scope, $rootScope) {
    var ws = new WebSocket("wss://127.0.0.1:9999/websocket");     

    ws.onopen = function() {
    var SendObj = {"ws": "start"};
	ws.send(JSON.stringify(SendObj));
    };
        
    ws.onclose = function() {
        alert("Connection closed");  
    };
    
    $scope.inbox = function() {
        ws.send(JSON.stringify({"ws": "inbox"}));      
    };

    ws.onmessage = function(evt) {
        var data = JSON.parse(evt.data);
        if(data.email) {
        $scope.message = {inbox: mailBoxRetStr(data.INBOX[1]),
                          email: data.email,
                          sent: mailBoxRetStr(data.Sent[1]),
                          drafts: mailBoxRetStr(data.Drafts[1]),
                          spam: mailBoxRetStr(data.SPAM[1]),
                          trash: mailBoxRetStr(data.Trash[1])};
        } else if(data[0] == 'inbox'){
            alert(data);  
        }
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
