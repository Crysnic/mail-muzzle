function LogCtrl($scope, $http) {
    var method = 'POST';
    var url = 'https://127.0.0.1:9999/auth';
    $scope.send = function() {
        var FormData = {
          "email" : document.getElementById('inf').email.value,
          "password" : document.getElementById('inf').passwd.value
        };
        
        $http({
            method: method,
            url: url,
            data: FormData,
            headers: {'Content-Type': 'application/json'}
        }).success(function(data, status, headers, config) {
            document.getElementById("answ").innerHTML = 
                "INFO: " + data.email;
        }).error(function(data, status, headers, config) {
            document.getElementById("answ").innerHTML = 
                "Error: " + data.error;    
        });
    }
}
