(function() {
  var LoadProfile;

  window.LoadProfile = LoadProfile = (function() {

    function LoadProfile() {
      var serie, _series;
      _series = (function() {
        var _i, _len, _ref, _results;
        _ref = lab.getSeries();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          serie = _ref[_i];
          _results.push({
            name: "" + serie + " Wattz",
            data: lab.getSerieValues(serie)
          });
        }
        return _results;
      })();
      this.chart = new Highcharts.Chart({
        chart: {
          renderTo: 'chart-container',
          type: 'column'
        },
        title: {
          text: 'Load Profiles'
        },
        tooltip: {
          formatter: function() {
            return "<b>" + this.x + ":00 - " + (this.x + 1) + ":00</b> <br/> " + this.series.name + ": " + this.y;
          }
        },
        xAxis: {
          title: {
            text: 'Test Chamber Hours'
          }
        },
        yAxis: {
          title: {
            text: 'Total Wattz'
          },
          stackedLabels: {
            enabled: true
          }
        },
        plotOptions: {
          column: {
            borderWidth: 0,
            pointPadding: 0,
            groupPadding: 0,
            stacking: 'normal',
            dataLabels: {
              enabled: false
            }
          }
        },
        series: _series
      });
    }

    return LoadProfile;

  })();

}).call(this);
