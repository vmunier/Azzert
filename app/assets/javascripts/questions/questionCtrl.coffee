angular.module('azzertApp').controller 'QuestionCtrl', ($scope, $routeParams, titleService, questionResource, answerResource, voteResource, voteCountResource, questionChartService) ->

  $scope.answers = []
  $scope.votes = []
  $scope.voteCounts = []
  $scope.questionId = $routeParams.id

  $scope.question = questionResource.get {'questionId': $scope.questionId}, () ->
    titleService.set("Question #{$scope.question.name}")

  answerIdToArrIndex = {'123az': 0}

  $scope.answers = answerResource.query {'questionId': $scope.questionId}, () ->
    for answer in $scope.answers
      answerId = answer._id
      $scope.votes[answerId] = voteResource.query {'questionId': $scope.questionId, 'answerId': answerId}
      $scope.voteCounts[answerId] = voteCountResource.get {'questionId': $scope.questionId, 'answerId': answerId}

  $scope.inc = (answerId, val) ->
    voteCountResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'inc': val}
    voteResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'vote': val}
    $scope.votes[answerId] += val

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