angular.module('azzertApp').factory 'answerResource', ($resource) ->

  $resource('/api/questions/:id/answers', {id:'@id'})
