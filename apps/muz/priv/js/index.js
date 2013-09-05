function LogCtrl($scope, $http) {
    var method = 'POST';
    var url = 'https://localhost:9999/auth';
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
        }).success(function(response) {
            document.getElementById("answ").innerHTML = 
                "INFO: " + response.data;
        }).error(function(response) {
            document.getElementById("answ").innerHTML = 
                "Error: " + response.data;    
        });
    }
}
