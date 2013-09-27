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
            $scope.headers = ["Subject", "From", "Date"];
            $scope.letter = {subj: stringShotern(data[4], 60),
                             from: data[1].match(/^[a-zA-Z ]*/)[0],
                             date: data[3]};
            $scope.seeLetter = function() {
                alert(data[5]);    
            }
        }
        $scope.$digest();
    };
}

function stringShotern(str, numb) {
    if(str.length > numb) {
        return str.slice(0,(numb - 3)) + "...";    
    } else {
        return str;    
    }
}

function mailBoxRetStr(string) {
    if(parseInt(string) == 0) {
        return '';    
    } else {
        return "(" + string + ")";    
    }
}
