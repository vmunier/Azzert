angular.module('azzertApp').service 'questionChartService', () ->
  self = @

  buildChart = (data) ->
    chart = nv.models.lineChart().x((d) ->
      d[0]
    ).y((d) ->
      d[1] / 100
    )

    # if the visitor is french, this should be %d-%m-%Y
    # d3.time.format("%d-%m-%Y") new Date(d)
    chart.xAxis.tickFormat (d) ->
      d3.time.format("%Y-%m-%d") new Date(d)
    chart.yAxis.tickFormat d3.format(",.1%")

    d3.select("#chart svg").datum(data).transition().duration(500).call chart
    nv.utils.windowResize chart.update
    chart

  draw = (data) ->
    nv.addGraph () ->
      buildChart(data)

  self.draw = draw