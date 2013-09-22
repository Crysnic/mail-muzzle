var MailServices = angular.module('Mail-muzzle', ['ngResource']).
    run(function($rootScope, $location) {$rootScope.location = $location;});

function emailRouteConfig($routeProvider) {
    $routeProvider.
    when('/', {
      controller: LogCtrl,
      templateUrl: 'www/login.html'
    }).
    when('/mail', {
        controller: MailCtrl, // in the file mail.js
        templateUrl: 'www/mail.html'
    }).
    otherwise({
        redirectTo: '/'    
    }); 
}

// Main controller
MailServices.config(emailRouteConfig);

// Login controller
function LogCtrl($scope, $resource, $http, $location) {
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
                $location.path('/mail');
            },
            function(answer){
                $scope.answ = 'Error: ' + answer.data.error;    
            });
    }
}
