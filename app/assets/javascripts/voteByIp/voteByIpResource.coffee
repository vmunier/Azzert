angular.module('azzertApp').factory 'voteByIpResource', ($resource) ->
  $resource('/api/questions/:questionId/answers/:answerId/voteByIp', {questionId:'@questionId', answerId:'@answerId'})
