window.LoadProfile = class LoadProfile

  updateChart: (seriesIndex) ->
    newData = @lab.getSerieValues('index': seriesIndex)
    @chart.series[seriesIndex].setData(newData, true)

  buildGraph: ->
    @chart = new Highcharts.Chart
      chart:
        renderTo: 'chart-container'
        type: 'column'
      title:
        text: 'Load Profiles'
      tooltip:
        formatter: ->
          "<b>#{@x}:00 - #{@x + 1}:00</b> <br/> #{@series.name}: #{@y}"
      xAxis:
        title:
          text: 'Test Chamber Hours'
      yAxis:
        title:
          text: 'Total Wattz'
        stackedLabels:
          enabled: true
      plotOptions:
        column:
          borderWidth: 0
          pointPadding: 0
          groupPadding: 0
          stacking: 'normal'
          dataLabels:
            enabled: false
      series: @_getSeries()


  _getSeries: ->
    _series = (
      {
        name: "#{serie} Wattz"
        data: @lab.getSerieValues('name': serie)
      } for serie in @lab.getSeries()
    )

  constructor: (lab) ->
    @lab = lab
    @buildGraph()
