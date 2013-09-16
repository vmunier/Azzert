angular.module('azzertApp').service 'questionChartService', () ->
  self = @

  # create the graph and update it automatically every second.
  create = (answers, series, setChartLegendDate, seriesData) ->
    for answer, i in answers
      series.push(
        name: answer.name
        color: answer.color
        data: seriesData[i]
        legendValue: ""
      )

    graph = new Rickshaw.Graph(
      element: document.querySelector('.chart')
      width: 760
      height: 500
      renderer: 'line'
      # 'linear' interpolation is used to have straight lines,
      # other interpolation options such as 'cardinal' do not work well with mouse hover.
      interpolation: 'linear'
      stroke: true
      preserve: true
      series: series
    )

    yTicks = new Rickshaw.Graph.Axis.Y(
      graph: graph
      orientation: 'left'
      tickFormat: Rickshaw.Fixtures.Number.formatKMBT
      element: document.querySelector('.yAxis')
    )

    graph.render()

    Hover = Rickshaw.Class.create(Rickshaw.Graph.HoverDetail,
      render: (args) ->
        setChartLegendDate(args.formattedXValue)

        sorted = args.detail.sort((a, b) ->
          a.order - b.order
        )

        for d, idx in sorted
          series[idx].legendValue = d.formattedYValue
          # display horizontal dots
          dot = document.createElement('div')
          dot.className = 'dot'
          dot.style.top = graph.y(d.value.y0 + d.value.y) + 'px'
          dot.style.borderColor = d.series.color
          @element.appendChild dot
          dot.className = 'dot active'
          @show()
    )
    hover = new Hover(graph: graph)

    hoverDetail = new Rickshaw.Graph.HoverDetail(graph: graph)

    axes = new Rickshaw.Graph.Axis.Time(graph: graph)
    axes.render()

    slider = new Rickshaw.Graph.RangeSlider(
      graph: graph,
      element: $('.slider')
    )

    setInterval(() ->
      graph.update()
    , 1000)

    addToggleBehavior = ->
      graph.series.forEach (s) ->
        s.disable = ->
          throw ("only one series left")  if graph.series.length <= 1
          s.disabled = true
          graph.update()
        s.enable = ->
          s.disabled = false
          graph.update()

    addToggleBehavior()

  self.toggleLegend = (line) ->
    if line.disabled
      line.enable()
    else
      line.disable()

  self.create = create
