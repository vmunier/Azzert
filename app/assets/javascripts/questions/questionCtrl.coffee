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

  seriesData = []

  initGlobals = (answers) ->
    for answer, i in answers
      answerId = answer._id
      lastAnswerHistoryVote[answerId] = 0
      insertedForLastDate[answerId] = false
      addAnswerMapping(answerId, i)
      seriesData.push([])

  $scope.answers = answerResource.query {'questionId': $scope.questionId}, () ->
    initGlobals($scope.answers)

    $http(
      method: 'GET'
      url: "/api/answerHistory/questions/#{$scope.questionId}"
      params:
        interval: '1d'
    ).success( (answerHistoryList) ->
      createChart(answerHistoryList)
      registerToAnswerEventSource($scope.questionId)
    )

  # add missing answerHistory points which do not exist for the answerHistory.date, it will reuse the last plotted point
  addMissingPointsForDate = (date) ->
    for answerId of insertedForLastDate
      if not insertedForLastDate[answerId]
        missingAnswerHistory = createAnswerHistory(answerId, lastAnswerHistoryVote[answerId], date)
        addPoint(missingAnswerHistory)

  createAnswerHistory = (answerId, voteCount, date) ->
    answerId: answerId
    voteCount: voteCount
    date: date

  resetInsertedForLastDate = () ->
    for answerId of insertedForLastDate
      insertedForLastDate[answerId] = false

  createChart = (answerHistoryList) ->
    names = $scope.answers.map( (answer) -> answer.name)

    for answerHistory, i in answerHistoryList
      next = answerHistoryList[i + 1]
      date = answerHistory.date
      answerId = answerHistory.answerId

      addPoint(answerHistory)
      lastAnswerHistoryVote[answerId] = answerHistory.voteCount
      insertedForLastDate[answerId] = true

      if next == undefined || next.date != date
        addMissingPointsForDate(date)
        resetInsertedForLastDate()

    questionChartService.create(names, seriesData)


  registerToAnswerEventSource = (questionId) ->
    answerHistoryService.withEventSource questionId, (feed) ->
      feed.addEventListener 'message', ((e) ->
        answerHistory = JSON.parse(e.data)
        answerId = answerHistory.answerId
        addPoint(answerHistory)
        $scope.$apply () ->
          getAnswer(answerId).voteCount = answerHistory.voteCount
      ), false

  addPoint = (answerHistory) ->
    lineIdx = answerIdToArrIndex[answerHistory.answerId]
    serie = seriesData[lineIdx]
    # divide by 1000 because Rickshaw uses dates at the second
    date = Math.floor(answerHistory.date / 1000)
    point =
      x:date
      y:answerHistory.voteCount

    serie.push(point)

  $scope.vote = (answerId, val) ->
    voteCountResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'inc': val}
    voteResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'vote': val}
    getAnswer(answerId).voteCount += val
