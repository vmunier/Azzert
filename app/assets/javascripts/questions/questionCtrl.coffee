angular.module('azzertApp').controller 'QuestionCtrl', ($scope, $routeParams, $http, titleService, questionResource, answerResource, answerHistoryService, voteResource, voteByIpResource, QuestionChart, chartTimeService) ->
  self = @

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

  logSeries = () ->
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

  setTimeout logSeries, 1500

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
      "You have already voted #{pv} for this answer in #{new Date(previousVote.date).toString('yyyy-MM-dd HH:mm')}"
    else ""


  $scope.chartTimeOptions = chartTimeService.chartTimeOptions
  $scope.selectedChartTime = $scope.chartTimeOptions[0]
  historyStartDate = $scope.selectedChartTime.value()

  $scope.setChartTime = (chartTime) ->
    clearChart()
    $scope.selectedChartTime = chartTime
    historyStartDate = chartTime.value()
    unregisterToAnswerEventSource()
    loadChartWithHistory()

  loadHistory = (start, interval) ->
    $http(
      method: 'GET'
      url: "/api/answerHistory/questions/#{$scope.questionId}"
      params:
        startTimestamp: start.getTime().toString()
        interval: interval
    )

  loadChartWithHistory = () ->
    loadHistory(historyStartDate, '1s').success( (answerHistoryList) ->
      createChart(answerHistoryList)
      registerToAnswerEventSource()
    ).error( (reason) ->
      createChart(getDefaultHistoryList())
      console.log "reason : ", reason
    )

  $scope.answers = answerResource.query {'questionId': $scope.questionId}, () ->
    initGlobals($scope.answers)
    loadChartWithHistory()

  getDefaultHistoryList = () ->
    $scope.answers.map( (answer) -> {voteCount: answer.voteCount, answerId: answer._id, date: historyStartDate})

  createAnswerHistory = (answerId, voteCount, date) ->
    answerId: answerId
    voteCount: voteCount
    date: date

  # scope chart variables
  $scope.series = []
  $scope.toggleLegend = (line) ->
    if line.disabled then line.enable() else line.disable()

  $scope.chartLegendDate = ""
  setChartLegendDate = (date) ->
    $scope.$apply () ->
      $scope.chartLegendDate = "" + date

  questionChart = undefined

  createChart = (answerHistoryList) ->
    #  set seriesData before adding points
    for a in $scope.answers
      seriesData.push([])
    for answerHistory, i in answerHistoryList
      addPoint(answerHistory)

    questionChart = new QuestionChart($('.chartContainer'), $scope.answers, $scope.series, setChartLegendDate, seriesData, false)

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
      setAnswerAlreadyVoted(answer)
      answer.voteCount += val
    saveFailure = (reason) ->
      console.log("reason : ", reason)
    if answer.previousVote == undefined
      voteResource.save {'questionId': $scope.questionId, 'answerId': answerId, 'vote': val}, saveSuccess, saveFailure

  safeApply = (action) ->
    # checks $digest is already in progress
    if $scope.$$phase then action() else $scope.$apply(action)

  clearChart = () ->
    seriesData = []
    $scope.chartLegendDate = ""
    angular.copy([], $scope.series)
    safeApply () -> angular.copy([], $scope.series)
    questionChart.clear()
