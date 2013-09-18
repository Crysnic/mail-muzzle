var MailServices = angular.module('Mail-muzzle', ['ngResource']).
    run(function($rootScope, $location) {$rootScope.location = $location;});

function emailRouteConfig($routeProvider) {
    var State = {email: '', passwd: '', data: ''};

    $routeProvider.
    when('/', {
      controller: LogCtrl,
      templateUrl: 'www/login.html'
    }).
    when('/mail', {
        controller: MailCtrl,
        templateUrl: 'www/mail.html'
    }).
    otherwise({
        redirectTo: '/'    
    }); 
}

// Main controller
MailServices.config(emailRouteConfig);

// Mail controller
function MailCtrl($scope, $resource) {
    $scope.message = {email: State.email,
                      data: State.data};
}

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
        var usEmail = document.getElementById('inf').email.value;
        var usPasswd = document.getElementById('inf').passwd.value;
        var result = document.getElementById('answ');
        var user = User.post({met: 'auth'},
            {email: usEmail, passwd: usPasswd},
            function(answer) {
                State = {email: usEmail, passwd: usPasswd,
                         data: answer.ok};
                result.innerHTML = 'INFO: ' + answer.ok;
                $location.path('/mail');
            },
            function(answer){
		State = {email: '', passwd: '', data: ''};
                result.innerHTML = 'Error: ' + answer.data.error;    
            });
    }
}
