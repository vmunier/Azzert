angular.module('azzertApp').controller 'QuestionCtrl', ($scope) ->

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

  nv.addGraph ->
    chart = nv.models.lineWithFocusChart()
    chart.xAxis.tickFormat d3.format(",f")
    chart.x2Axis.tickFormat d3.format(",f")
    chart.yAxis.tickFormat d3.format(",.2f")
    chart.y2Axis.tickFormat d3.format(",.2f")
    draw = ->
      d3.select("#chart svg").datum(testData()).transition().duration(500).call chart

    draw()
    nv.utils.windowResize chart.update
    chart

  range = (start, end) ->
    foo = []
    i = start

    while i <= end
      foo.push i
      i++
    foo