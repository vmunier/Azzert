angular.module('azzertApp').factory 'voteResource', ($resource) ->

  $resource('/api/questions/:questionId/answers/:answerId/votes/:vote', {questionId:'@questionId', answerId:'@answerId', vote:'@vote'})
