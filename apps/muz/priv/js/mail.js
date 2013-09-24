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
        var retArray = JSON.parse(evt.data);
        $scope.message = {inbox: retArray[2][1],
                          email: retArray[0]};
        $scope.$digest();
    };
}
