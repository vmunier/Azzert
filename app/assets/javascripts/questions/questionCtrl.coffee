angular.module('azzertApp').controller 'QuestionCtrl', ($scope, questionChartService) ->

  dateLine = (num) ->
    key: "Line" + num
    values: range(0, 20).map((d) ->
      currentDate = new Date()
      currentDate.setDate currentDate.getDate() + d
      yVal = Math.floor(Math.random() * 50) + 1
      console.log "currentDate: ", currentDate.getTime()
      [currentDate.getTime(), yVal]
    )

  testDataWithDate = ->
    range(0, 2).map (num) ->
      dateLine num

  testData = ->
    lines = stream_layers(2, 20, .1)
    console.log lines.length
    console.log lines
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

  questionChartService.draw(testDataWithDate())