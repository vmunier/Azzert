
angular.module('azzertApp').service 'answerHistoryService', () ->
  self = @

  self.open = (questionId) ->
    self.eventSource = new EventSource("/api/answerHistory/questions/#{questionId}/sse")
