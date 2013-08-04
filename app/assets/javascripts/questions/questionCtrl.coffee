angular.module('azzertApp').controller 'QuestionCtrl', ($scope, $routeParams, titleService, questionResource, answerResource, questionChartService) ->



  $scope.answers = []
  $scope.votes = []
  $scope.questionId = $routeParams.id

  $scope.question = questionResource.get {'id': $scope.questionId}, () ->
    titleService.set("Question #{$scope.question.name}")

  answerIdToArrIndex = {'123az': 0}

  $scope.answers = answerResource.query {'id': $scope.questionId}, () ->
    for answer in $scope.answers
      console.log("answer : ", answer)
      $scope.votes[answer._id] = 0

  $scope.inc = (answerId, val) ->
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