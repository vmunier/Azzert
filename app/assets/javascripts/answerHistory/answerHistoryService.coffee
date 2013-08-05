
angular.module('azzertApp').service 'answerHistoryService', () ->
  withEventSource = (questionId, body) ->
    unless not window.EventSource
      body(new EventSource("/api/answerHistory/questions/#{questionId}/sse"))

  withEventSource: withEventSource
