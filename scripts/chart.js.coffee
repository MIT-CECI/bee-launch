window.LoadProfile = class LoadProfile

  updateChart: (seriesIndex) ->
    newData = @lab.getSerieValues('index': seriesIndex)
    @chart.series[seriesIndex].setData(newData, true)

  buildGraph: ->
    @chart = new Highcharts.Chart
      chart:
        renderTo: 'chart-container'
        type: 'column'
        events:
          click: (event) ->
            console?.log(event, event.xAxis, event.yAxis)
      title:
        text: 'Load Profiles'
      tooltip:
        formatter: ->
          total = 0
          text  = "<b>#{@x}:00 - #{@x + 1}:00</b> <br /> -- <br />"

          for serie in @series.chart.series
            text  += "#{serie.name} <br />" if serie.yData[@x] > 0
            total += serie.yData[@x]

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
