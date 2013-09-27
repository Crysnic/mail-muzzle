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


