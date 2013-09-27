function MailCtrl($scope, $rootScope, $location) {
    var ws = new WebSocket("wss://127.0.0.1:9999/websocket");     

    ws.onopen = function() {
        var email;
        var passwd;

        if($rootScope.email) {
            email = $rootScope.email;
            passwd = $rootScope.passwd;
        } else if(localStorage.getItem('email')) {
            email = localStorage.getItem('email');
            passwd = localStorage.getItem('passwd');
        };

        $scope.email = email;

        var SendObj = {"ws": "start",
                   "email": email,
                   "passwd": passwd};
	    ws.send(JSON.stringify(SendObj));
    };
        
    ws.onclose = function() {
        alert("Connection closed");
        ws = new WebSocket("wss://127.0.0.1:9999/websocket");
    };
    
    $scope.mailbox_send = function(mailbox) {
        if(mailbox == "INBOX") {
            ws.send(JSON.stringify({"ws": mailbox}));
        }
    };

    $scope.exit = function() {
        localStorage.removeItem('email');
        localStorage.removeItem('passwd');
        $location.path("/");
    };

    ws.onmessage = function(evt) {
        var data = JSON.parse(evt.data);
        if(data[0] == "mailbox") {
            var array = [];
            for(var i=1; i < data.length; i += 2) {
                if(parseInt(data[i+1].MESSAGES) > 0) {
                    array.push({mailbox: data[i], 
                    unseen: mailBoxRetStr(data[i+1].UNSEEN)});
                }
            }
            $scope.mailboxes = array;
        } else if(data[0] == 'INBOX'){
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
