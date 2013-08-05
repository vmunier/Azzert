angular.module('azzertApp').controller 'QuestionCtrl', ($scope, $routeParams, titleService, questionResource, answerResource, answerHistoryService, voteResource, voteCountResource, questionChartService) ->

  $scope.answers = []
  $scope.questionId = $routeParams.id

  $scope.question = questionResource.get {'questionId': $scope.questionId}, () ->
    titleService.set("Question #{$scope.question.name}")

  answerIdToArrIndex = {'123az': 0}

  getAnswer = (answerId) ->
    arrIdx = answerIdToArrIndex[answerId]
    $scope.answers[arrIdx]

  addAnswerMapping = (answerId, arrIdx) ->
    answerIdToArrIndex[answerId] = arrIdx

  $scope.answers = answerResource.query {'questionId': $scope.questionId}, () ->
    for answer, i in $scope.answers
      answerId = answer._id
      addAnswerMapping(answerId, i)
    registerToAnswerEventSource($scope.questionId)

  registerToAnswerEventSource = (questionId) ->
    answerHistoryService.withEventSource questionId, (feed) ->
      feed.addEventListener 'message', ((e) ->
        answerHistory = JSON.parse(e.data)
        console.log("answerHistory : ", answerHistory)
        $scope.$apply () ->
          getAnswer(answerHistory.answerId).voteCount = answerHistory.voteCount
      ), false

  $scope.vote = (answerId, val) ->
    voteCountResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'inc': val}
    voteResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'vote': val}
    getAnswer(answerId).voteCount += val

  dateLine = (num) ->
    key: "Line" + num
    values: range(0, 20).map((d) ->
      currentDate = new Date()
      currentDate.setDate currentDate.getDate() + d
      yVal = Math.floor(Math.random() * 50) + 1
      [currentDate.getTime(), yVal]
    )

  testDataWithDate = ->
    range(0, 2).map (num) ->
      dateLine num

  testData = ->
    lines = stream_layers(2, 20, .1)
    lines.map (data, i) ->
      key: "Stream" + i
      values: data

  range = (start, end) ->
    foo = []
    i = start

    while i <= end
      foo.push i
      i++
    foo

  chartData = testDataWithDate()

  questionChartService.setData(chartData)
  questionChartService.draw()

  chart = questionChartService.chart

  pushLineData = (answerId, value) ->
    idx = answerIdToArrIndex[answerId]
    questionChartService.pushLineData(idx, value)

  f = () ->
    setTimeout () ->
      for val in testDataWithDate()[0].values.slice(0, 4)
        pushLineData('123az', val)
      questionChartService.draw()
      f()
    ,
      5000
  # f()
