window.LoadProfile = class LoadProfile

  updateChart: (seriesIndex) ->
    newData = @lab.getSerieValues('index': seriesIndex)
    @chart.series[seriesIndex].setData(newData, true)

  addToCurrentLoad: (xPosition) ->
    xPosition = parseInt(xPosition)
    currentLoad = BEE.activeLoad
    if currentLoad >= 0
      @lab.turnLoadOn(currentLoad, xPosition, xPosition + 1)
      @updateChart(currentLoad)
    else
      console?.log(xPosition, "There is no current load selected")
      $(".navigation").stop().effect("bounce", { times: 3 }, 200)


  buildGraph: ->
    @chart = new Highcharts.Chart
      chart:
        renderTo: 'chart-container'
        type: 'column'
        events:
          click: (event) =>
            @addToCurrentLoad(event.xAxis[0].value)
      title:
        text: 'Load Profiles'
      tooltip:
        formatter: ->
          x = parseInt(@x)
          total = 0
          text  = "<b>#{@x} - #{x + 1}:00</b> <br /> -- <br />"

          for serie in @series.chart.series
            text  += "#{serie.name} <br />" if serie.yData[x] > 0
            total += serie.yData[x]

          text += " -- <br />"
          text += "<b> Total: #{total} wattz </b>"
          text
      xAxis:
        min: 0
        max: @lab.length - 1
        title:
          text: 'Test Chamber Hours'
        categories: (=> "#{hour}:00" for hour in [0..@lab.length])()
      yAxis:
        title:
          text: 'Total Wattz'
        stackedLabels:
          enabled: true
      plotOptions:
        series:
          cursor: 'pointer'
          events:
            click: (event) =>
              console?.log(event, "Clicked a serie")
              @addToCurrentLoad(event.point.x)
        column:
          borderWidth: 2
          pointPadding: 0
          groupPadding: 0
          stacking: 'normal'
          dataLabels:
            enabled: false
      series: @_getSeries()


  _getSeries: ->
    _series = (
      {
        name: serie
        data: @lab.getSerieValues('name': serie)
      } for serie in @lab.getSeries()
    )

  constructor: (lab) ->
    @lab = lab
    @buildGraph()
