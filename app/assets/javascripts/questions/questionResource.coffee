angular.module('azzertApp').factory 'questionResource', ($resource, resourceService) ->

  $resource('/api/questions/:questionId', {questionId:'@questionId'},
    save:
      method: 'POST'
      transformResponse: resourceService.simpleTransformResponse
   )
