angular.module('azzertApp').controller 'QuestionCtrl', ($scope, $routeParams, $http, titleService, questionResource, answerResource, answerHistoryService, voteResource, voteCountResource, questionChartService) ->

  $scope.answers = []
  $scope.questionId = $routeParams.id

  $scope.question = questionResource.get {'questionId': $scope.questionId}, () ->
    titleService.set("Question #{$scope.question.name}")

  answerIdToArrIndex = {}

  getAnswer = (answerId) ->
    arrIdx = answerIdToArrIndex[answerId]
    $scope.answers[arrIdx]

  addAnswerMapping = (answerId, arrIdx) ->
    answerIdToArrIndex[answerId] = arrIdx

  lastAnswerHistoryVote = {}
  insertedForLastDate = {}

  initGlobals = (answers) ->
    for answer, i in answers
      answerId = answer._id
      lastAnswerHistoryVote[answerId] = 0
      insertedForLastDate[answerId] = false
      addAnswerMapping(answerId, i)

  $scope.answers = answerResource.query {'questionId': $scope.questionId}, () ->
    initGlobals($scope.answers)
    createChart()

    $http(
      method: 'GET'
      url: "/api/answerHistory/questions/#{$scope.questionId}"
      params:
        interval: '1d'
    ).success( (answerHistoryList) ->
      initChartFromAnswerHistory(answerHistoryList)
      registerToAnswerEventSource($scope.questionId)
    )

  initChartFromAnswerHistory = (answerHistoryList) ->
    for answerHistory, i in answerHistoryList
      next = answerHistoryList[i + 1]
      date = answerHistory.date
      answerId = answerHistory.answerId

      updateChartSerie(answerHistory)
      lastAnswerHistoryVote[answerId] = answerHistory.voteCount
      insertedForLastDate[answerId] = true

      if next == undefined || next.date != date
        addMissingPointsForDate(date)
        resetInsertedForLastDate()

  # add missing answerHistory points which do not exist for the answerHistory.date, it will reuse the last plotted point
  addMissingPointsForDate = (date) ->
    for answerId of insertedForLastDate
      if not insertedForLastDate[answerId]
        missingAnswerHistory = createAnswerHistory(answerId, lastAnswerHistoryVote[answerId], date)
        updateChartSerie(missingAnswerHistory)

  createAnswerHistory = (answerId, voteCount, date) ->
    answerId: answerId
    voteCount: voteCount
    date: date

  resetInsertedForLastDate = () ->
    for answerId of insertedForLastDate
      insertedForLastDate[answerId] = false

  createChart = () ->
    names = $scope.answers.map( (answer) -> answer.name)
    questionChartService.create(names)

  registerToAnswerEventSource = (questionId) ->
    answerHistoryService.withEventSource questionId, (feed) ->
      feed.addEventListener 'message', ((e) ->
        answerHistory = JSON.parse(e.data)
        answerId = answerHistory.answerId
        updateChartSerie(answerHistory)
        $scope.$apply () ->
          getAnswer(answerId).voteCount = answerHistory.voteCount
      ), false

  updateChartSerie = (answerHistory) ->
    lineIdx = answerIdToArrIndex[answerHistory.answerId]
    # divide by 1000 because Rickshaw uses dates at the second
    date = Math.floor(answerHistory.date / 1000)
    point =
      x:date
      y:answerHistory.voteCount
    questionChartService.addPoint(lineIdx, point)

  $scope.vote = (answerId, val) ->
    voteCountResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'inc': val}
    voteResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'vote': val}
    getAnswer(answerId).voteCount += val
