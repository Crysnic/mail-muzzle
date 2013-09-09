angular.module('Mail-muzzle', ['ngResource']);

function LogCtrl($scope, $resource, $http) {
    $http.defaults.headers.post['Content-Type'] = 'application/json';
    var User = $resource('https://127.0.0.1\\:9999/:met',
        {met:'@method'}, 
        {post:
            {method:'POST', 
             headers: {'ignored':'ignored'}}
        });


    $scope.send = function() {
        var usEmail = document.getElementById('inf').email.value;
        var usPasswd = document.getElementById('inf').passwd.value;
        var result = document.getElementById('answ');
        var user = User.post({met: 'auth'},
            {email: usEmail, passwd: usPasswd},
            function(answer) {
                result.innerHTML = 'INFO: ' + answer.data;
            },
            function(answer){
                result.innerHTML = 'Error: ' + answer.data.error;    
            });
    }
}
