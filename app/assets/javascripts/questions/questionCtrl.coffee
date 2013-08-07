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
    registerToAnswerEventSource($scope.questionId)

  createChart = () ->
    names = []
    for answer in $scope.answers
      names.push(answer.name)
    questionChartService.create(names)

  registerToAnswerEventSource = (questionId) ->
    answerHistoryService.withEventSource questionId, (feed) ->
      feed.addEventListener 'message', ((e) ->
        answerHistory = JSON.parse(e.data)
        answerId = answerHistory.answerId
        updateChartSerie(answerId, answerHistory)
        $scope.$apply () ->
          getAnswer(answerId).voteCount = answerHistory.voteCount
      ), false

  updateChartSerie = (answerId, answerHistory) ->
    lineIdx = answerIdToArrIndex[answerId]
    date = Math.floor(answerHistory.date / 1000)
    point =
      x:date
      y:answerHistory.voteCount
    questionChartService.addPoint(lineIdx, point)

  $scope.vote = (answerId, val) ->
    voteCountResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'inc': val}
    voteResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'vote': val}
    getAnswer(answerId).voteCount += val
