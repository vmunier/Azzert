angular.module('azzertApp').controller 'QuestionCtrl', ($scope, $routeParams, $http, titleService, questionResource, answerResource, answerHistoryService, voteResource, voteByIpResource, questionChartService, chartTimeService) ->

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

  addColors = (answers) ->
    palette = new Rickshaw.Color.Palette()
    for answer in answers
      answer.color = palette.color()

  initGlobals = (answers) ->
    addColors(answers)
    for answer, i in answers
      answerId = answer._id
      setAnswerAlreadyVoted(answer)
      addAnswerMapping(answerId, i)
      seriesData.push([])

  setTimeout () ->
    str = "["
    for serie in seriesData
      str += "["
      for elt in serie
        str += "{x: #{elt.x}, y: #{elt.y}},"
      str = str.substring(0, str.length - 1)
      str += "],"
    str = str.substring(0, str.length - 1)
    str += "];"
    console.log("export series to be used in Rickshaw : ")
    console.log(str)
  , 1500

  setAnswerAlreadyVoted = (answer) ->
    answer.previousVote = undefined
    voteByIpResource.get {'questionId': $scope.questionId, 'answerId': answer._id}, (vote) ->
      answer.previousVote = vote

  $scope.getMinusClassBtn = (previousVote) ->
    if previousVote?.value == -1 then "disabled votedMinusBtn"
    else if previousVote?.value == 1 then "disabled minusBtn"
    else "minusBtn"

  $scope.getPlusClassBtn = (previousVote) ->
    if previousVote?.value == 1 then "disabled votedPlusBtn"
    else if previousVote?.value == -1 then "disabled plusBtn"
    else "plusBtn"

  $scope.voteTooltip = (previousVote) ->
    if previousVote?
      pv = if previousVote.value == 1 then "+1" else "-1"
      "You already voted #{pv} for this answer in #{new Date(previousVote.date).toString('yyyy-MM-dd HH:mm')}"
    else ""

  loadHistory = (start, interval) ->
    $http(
      method: 'GET'
      url: "/api/answerHistory/questions/#{$scope.questionId}"
      params:
        startTimestamp: start.getTime().toString()
        interval: interval
    )

  # Use a timeout to wait the Dom to be complete
  setTimeout(
    () -> $('[rel=tooltip]').tooltip()
  , 500)

  $scope.answers = answerResource.query {'questionId': $scope.questionId}, () ->
    initGlobals($scope.answers)
    loadHistory(new Date(0), '1s').success( (answerHistoryList) ->
      createChart(answerHistoryList)
      registerToAnswerEventSource()
    ).error( (reason) ->
      console.log "reason : ", reason
    )

  createAnswerHistory = (answerId, voteCount, date) ->
    answerId: answerId
    voteCount: voteCount
    date: date

  createChart = (answerHistoryList) ->
    names = $scope.answers.map( (answer) -> answer.name)
    for answerHistory, i in answerHistoryList
      addPoint(answerHistory)
    questionChartService.create($scope.answers, seriesData)

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

  $scope.vote = (answer, val) ->
    answerId = answer._id
    saveSuccess = () ->
      getAnswer(answerId).voteCount += val
    saveFailure = (reason) ->
      console.log("reason : ", reason)
    if answer.previousVote == undefined
      voteResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'vote': val}, saveSuccess, saveFailure

  $scope.setChartTime = (chartTime) ->
    $scope.selectedChartTime = chartTime
    unregisterToAnswerEventSource()
    clearPoints()
    console.log("seriesData : ", seriesData)
    console.log("chartTime.value() : ", chartTime.value())
    loadHistory(chartTime.value(), '1s').success( (answerHistoryList) ->
      createChart(answerHistoryList)
    ).error( (reason) ->
      console.log "reason : ", reason
    )


  $scope.chartTimeOptions = chartTimeService.chartTimeOptions
  $scope.selectedChartTime = $scope.chartTimeOptions[0]

  clearPoints = () ->
    for i in [0..seriesData.length]
      seriesData[i] = []
