angular.module('azzertApp').controller 'QuestionCtrl', ($scope, $routeParams, $http, titleService, questionResource, answerResource, answerHistoryService, voteResource, voteCountResource, questionChartService) ->

  $scope.answers = []
  $scope.questionId = $routeParams.id

  totalVotes = () ->
    total = 0
    for answer in $scope.answers
      total += answer.voteCount
    total

  $scope.votePercentage = (voteCount) ->
    total = totalVotes()
    if total == 0 then 0 else Math.floor(voteCount / total * 100)

  $scope.question = questionResource.get {'questionId': $scope.questionId}, () ->
    titleService.set("Question #{$scope.question.name}")

  answerIdToArrIndex = {}

  getAnswer = (answerId) ->
    arrIdx = answerIdToArrIndex[answerId]
    $scope.answers[arrIdx]

  addAnswerMapping = (answerId, arrIdx) ->
    answerIdToArrIndex[answerId] = arrIdx

  seriesData = []

  answerHistoryService.open($scope.questionId)

  initGlobals = (answers) ->
    for answer, i in answers
      answerId = answer._id
      addAnswerMapping(answerId, i)
      seriesData.push([])

  $scope.answers = answerResource.query {'questionId': $scope.questionId}, () ->
    initGlobals($scope.answers)

    $http(
      method: 'GET'
      url: "/api/answerHistory/questions/#{$scope.questionId}"
      params:
        interval: '1s'
    ).success( (answerHistoryList) ->
      createChart(answerHistoryList)
      registerToAnswerEventSource()
    )

  createAnswerHistory = (answerId, voteCount, date) ->
    answerId: answerId
    voteCount: voteCount
    date: date

  createChart = (answerHistoryList) ->
    names = $scope.answers.map( (answer) -> answer.name)
    for answerHistory, i in answerHistoryList
      addPoint(answerHistory)
    chart = questionChartService.create(names, seriesData)
    console.log "chart : ", chart

  answerHistoryListener = (e) ->
    answerHistory = JSON.parse(e.data)
    answerId = answerHistory.answerId
    addPoint(answerHistory)
    $scope.$apply () ->
      getAnswer(answerId).voteCount = answerHistory.voteCount

  registerToAnswerEventSource = () ->
    answerHistoryService.eventSource.addEventListener 'message', answerHistoryListener, false

  unregisterToAnswerEventSource = () ->
    answerHistoryService.eventSource.removeEventListener 'message', answerHistoryListener, false

  addPoint = (answerHistory) ->
    lineIdx = answerIdToArrIndex[answerHistory.answerId]
    serie = seriesData[lineIdx]
    # divide by 1000 because Rickshaw uses dates at the second
    date = Math.floor(answerHistory.date / 1000)

    point =
      x:date
      y:answerHistory.voteCount

    last = serie[serie.length - 1]
    # remove the last element if it has the same date to replace it
    if last != undefined and last.x == answerHistory.date
      serie.pop()
    serie.push(point)
    addMissingPointsForDate(date)

  # add missing answerHistory points which do not exist for the date, it will reuse the last plotted point
  addMissingPointsForDate = (date) ->
    for serie in seriesData
      lastSeriePoint = serie[serie.length - 1]
      if lastSeriePoint != undefined and lastSeriePoint.x != date
        point =
          x: date
          y: lastSeriePoint.y
        serie.push(point)

  $scope.vote = (answerId, val) ->
    voteCountResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'inc': val}
    voteResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'vote': val}
    getAnswer(answerId).voteCount += val
