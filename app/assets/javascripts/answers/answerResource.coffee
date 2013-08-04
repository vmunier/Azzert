angular.module('azzertApp').factory 'answerResource', ($resource) ->

  $resource('/api/questions/:questionId/answers/:answerId', {questionId:'@questionId', answerId:'@answerId'})
