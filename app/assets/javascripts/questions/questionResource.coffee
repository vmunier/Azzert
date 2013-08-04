angular.module('azzertApp').factory 'questionResource', ($resource) ->

  $resource('/api/questions/:questionId', {questionId:'@questionId'} )
