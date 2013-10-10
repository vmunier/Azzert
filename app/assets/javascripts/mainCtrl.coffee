angular.module('azzertApp').controller 'MainCtrl', ($scope) ->
  $scope.redirectToLogin = (provider) ->
    loginUri = "/login?provider=#{provider}&referer=#{window.location}"
    window.location = loginUri
