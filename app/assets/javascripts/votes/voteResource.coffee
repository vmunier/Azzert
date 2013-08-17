angular.module('azzertApp').factory 'voteResource', ($resource) ->
  # inc may be 1 or -1
  $resource('/api/questions/:questionId/answers/:answerId/votes/:vote', {questionId:'@questionId', answerId:'@answerId', vote:'@vote'})
