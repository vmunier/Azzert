angular.module('azzertApp').controller 'QuestionCtrl', ($scope, $routeParams, titleService, questionResource, answerResource, answerHistoryService, voteResource, voteCountResource, questionChartService) ->

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

  $scope.answers = answerResource.query {'questionId': $scope.questionId}, () ->
    for answer, i in $scope.answers
      answerId = answer._id
      addAnswerMapping(answerId, i)
    createChart()
    drawLoop()
    registerToAnswerEventSource($scope.questionId)

  registerToAnswerEventSource = (questionId) ->
    answerHistoryService.withEventSource questionId, (feed) ->
      feed.addEventListener 'message', ((e) ->
        answerHistory = JSON.parse(e.data)
        answerId = answerHistory.answerId
        pushChartLine(answerId, answerHistory)
        $scope.$apply () ->
          getAnswer(answerId).voteCount = answerHistory.voteCount
      ), false

  drawLoop = () ->
    console.log("draw!")
    questionChartService.draw()
    setTimeout drawLoop, 3500

  createChart = () ->
    lines = []
    for answer in $scope.answers
      lines.push(
        key: answer.name
        values: []
      )
    questionChartService.setData(lines)

  pushChartLine = (answerId, answerHistory) ->
    idx = answerIdToArrIndex[answerId]
    date = new Date(answerHistory.date)
    yVal = answerHistory.voteCount
    questionChartService.pushLineData(idx, [date, yVal])

  $scope.vote = (answerId, val) ->
    voteCountResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'inc': val}
    voteResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'vote': val}
    getAnswer(answerId).voteCount += val
