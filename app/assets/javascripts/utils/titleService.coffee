angular.module('azzertApp').service 'titleService', ($rootScope) ->
  self = @

  self.set = (title) ->
    $rootScope.pageTitle = title

  self.get = () ->
    $rootScope.pageTitle