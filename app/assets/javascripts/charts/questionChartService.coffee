angular.module('azzertApp').service 'questionChartService', () ->
  self = @

  palette = new Rickshaw.Color.Palette()

  # when creating an empty graph, Rickshaw insert one fake point for each line.
  # We want to remove these fake points as soon as we receive our first data points.
  # This array is inited to true for each point and set to false when addPoint is called.
  answerHasNoPoints = []

  # create the graph and update it automatically every second.
  create = (names) ->
    series = []
    for name, i in names
      series.push(name:name)
      answerHasNoPoints[i] = true

    graph = new Rickshaw.Graph(
      element: document.querySelector('.chart')
      width: 960
      height: 500
      renderer: 'line'
      # 'linear' interpolation is used to have straight lines,
      # other interpolation options such as 'cardinal' do not work well with mouse hover.
      interpolation: 'linear'
      stroke: true
      preserve: true
      series: new Rickshaw.Series(series)
    )

    yTicks = new Rickshaw.Graph.Axis.Y(
      graph: graph
      orientation: 'left'
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT
      element: document.querySelector('.yAxis')
    )
    graph.render()
    chartLegend = document.querySelector('.chartLegend')
    Hover = Rickshaw.Class.create(Rickshaw.Graph.HoverDetail,
      render: (args) ->
        chartLegend.innerHTML = args.formattedXValue
        args.detail.sort((a, b) ->
          a.order - b.order
        ).forEach ((d) ->
          chartLegendBlock = document.createElement('div')
          chartLegendBlock.className = 'chartLegendBlock'
          swatch = document.createElement('div')
          swatch.className = 'swatch'
          swatch.style.backgroundColor = d.series.color
          chartLegendLabel = document.createElement('div')
          chartLegendLabel.className = 'chartLegendLabel'
          chartLegendLabel.innerHTML = d.name + ': ' + d.formattedYValue
          chartLegendBlock.appendChild swatch
          chartLegendBlock.appendChild chartLegendLabel
          chartLegend.appendChild chartLegendBlock
          dot = document.createElement('div')
          dot.className = 'dot'
          dot.style.top = graph.y(d.value.y0 + d.value.y) + 'px'
          dot.style.borderColor = d.series.color
          @element.appendChild dot
          dot.className = 'dot active'
          @show()
        ), this
    )
    hover = new Hover(graph: graph)

    hoverDetail = new Rickshaw.Graph.HoverDetail(graph: graph)

    axes = new Rickshaw.Graph.Axis.Time(graph: graph)
    axes.render()

    setInterval(() ->
      graph.update()
    , 1000)
    self.graph = graph

  addPoint = (lineIdx, point) ->
    serieData = self.graph.series[lineIdx].data
    if answerHasNoPoints[lineIdx]
      serieData.splice(0, 1)
      answerHasNoPoints[lineIdx] = false
    serieData.push(point)

  self.create = create
  self.addPoint = addPoint
