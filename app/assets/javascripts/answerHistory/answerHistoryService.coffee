
angular.module('azzertApp').service 'answerHistoryService', () ->
  withEventSource = (answerId, body) ->
    unless not window.EventSource
      body(new EventSource("/api/answer-history/#{answerId}/sse"))

  withEventSource: withEventSource
