angular.module('azzertApp').factory 'voteCountResource', ($resource) ->
  # inc may be 1 or -1
  $resource('/api/questions/:questionId/answers/:answerId/voteCount/:inc', {questionId:'@questionId', answerId:'@answerId', inc:'@inc'})