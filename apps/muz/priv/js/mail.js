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
    };
    
    $scope.mailbox_send = function(mailbox) {
        ws.send(JSON.stringify({"ws": mailbox}));
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
        } else {
            $scope.see = false;
            $scope.headers = ["Subject", "From", "Date"];
            var letters = [];
            for(var i=1; i<data.length; i+=2) { 
                letters[i-1] = {
                    numb: i-1,
                    subj: stringShotern(data[i+1][3], 60),
                    subjFull: data[i+1][3],
                    fromFull: data[i+1][0],
                    from: data[i+1][0].match(/^[".a-zA-Z ]*/)[0],
                    to: data[i+1][1][0],
                    date: data[i+1][2],
                    data: data[i+1][4]};
            }
            $scope.letters = letters;
            $scope.seeLetter = function(index) {
                $scope.see = !$scope.see;
                $scope.to = letters[index].to;
                $scope.subj = letters[index].subjFull;
                $scope.from = letters[index].fromFull;
                $scope.data = letters[index].data;
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
