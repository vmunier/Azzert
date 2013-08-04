angular.module('azzertApp').service 'questionChartService', () ->
  self = @

  self.data = []

  self.init = () ->
    self.chart = nv.models.lineChart().x((d) ->
      d[0]
    ).y((d) ->
      d[1] / 100
    )
    # if the visitor is french, this should be %d-%m-%Y
    # d3.time.format("%d-%m-%Y") new Date(d)
    self.chart.xAxis.tickFormat (d) ->
      d3.time.format("%Y-%m-%d") new Date(d)
    self.chart.yAxis.tickFormat d3.format(",.1%")
    nv.addGraph () ->
      self.chart

  self.init()

  self.setData = (data) ->
    self.data = data

  self.pushLineData = (idx, value) ->
    self.data[idx].values.push(value)

  self.draw = () ->
    d3.select("#chart svg").datum(self.data).transition().duration(500).call self.chart
    nv.utils.windowResize self.chart.update
