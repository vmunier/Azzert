angular.module('azzertApp').service 'questionChartService', () ->
  self = @

  # create the graph and update it automatically every second.
  create = ($chartContainer, answers, series, setChartLegendDate, seriesData) ->
    $chartContainer.append($('#chartTemplate').clone().children())
    for answer, i in answers
      series.push(
        name: answer.name
        color: answer.color
        data: seriesData[i]
        legendValue: ""
      )

    graph = new Rickshaw.Graph(
      element: $chartContainer.find('.chart')[0]
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
      element: $chartContainer.find('.yAxis')[0]
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
      element: $chartContainer.find('.slider')
    )

    self.intervalId = setInterval(() ->
      graph.update()
    , 1000)

    getNbEnabledLines = ->
      total = 0
      for l in series
        total += 1 if not l.disabled
      total

    enableAllLines = ->
      for s in series
        s.enable()

    addToggleBehavior = ->
      graph.series.forEach (s) ->
        appendBorderColor = ->
          s.legendStyle += '; border-color: ' + s.color

        s.disable = ->
          if getNbEnabledLines() <= 1
            enableAllLines()
          else
            s.disabled = true
            s.legendStyle = 'background-color: white'
            appendBorderColor()
            graph.update()
        s.enable = ->
          s.disabled = false
          s.legendStyle = 'background-color: ' + s.color
          appendBorderColor()
          graph.update()

    addToggleBehavior()
    enableAllLines()

  self.toggleLegend = (line) ->
    if line.disabled
      line.enable()
    else
      line.disable()

  self.create = create

  self.clear = () ->
    clearInterval(self.intervalId)
    $('.chartContainer').empty()
