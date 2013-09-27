// Login controller
function LogCtrl($scope, $rootScope, $resource, $http, $location) {
    if(localStorage.getItem('email')) {
        $location.path("/mail");    
    }
    $scope.remembe = true;

    $http.defaults.headers.post['Content-Type'] = 'application/json';
    var User = $resource('/:met',
        {met:'@method'}, 
        {post:
            {method:'POST', 
             headers: {'ignored':'ignored'}}
    	}
    );

    $scope.send = function() {
        var user = User.post({met: 'auth'},
            {email: $scope.email, passwd: $scope.passwd},
            function(answer) {
                $scope.answ = 'INFO: ' + answer.ok;
                $rootScope.email = $scope.email;
                $rootScope.passwd = $scope.passwd;
                if($scope.remembe == true) {
                    localStorage.setItem('email', $scope.email);
                    localStorage.setItem('passwd', $scope.passwd);
                };
                $location.path('/mail');
            },
            function(answer){
                if(answer.data.error){
                    $scope.answ = 'Error: ' + answer.data.error;
                }
            });
    }
}
