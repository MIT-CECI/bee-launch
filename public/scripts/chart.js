(function() {
  var LoadProfile;

  window.LoadProfile = LoadProfile = (function() {

    LoadProfile.prototype.updateChart = function(seriesIndex) {
      var newData;
      newData = this.lab.getSerieValues({
        'index': seriesIndex
      });
      return this.chart.series[seriesIndex].setData(newData, true);
    };

    LoadProfile.prototype.buildGraph = function() {
      return this.chart = new Highcharts.Chart({
        chart: {
          renderTo: 'chart-container',
          type: 'column'
        },
        title: {
          text: 'Load Profiles'
        },
        tooltip: {
          formatter: function() {
            var serie, text, total, _i, _len, _ref;
            total = 0;
            text = "<b>" + this.x + ":00 - " + (this.x + 1) + ":00</b> <br /> -- <br />";
            _ref = this.series.chart.series;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              serie = _ref[_i];
              if (serie.yData[this.x] > 0) {
                text += "" + serie.name + " <br />";
              }
              total += serie.yData[this.x];
            }
            text += " -- <br />";
            text += "<b> Total: " + total + " wattz </b>";
            return text;
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
        series: this._getSeries()
      });
    };

    LoadProfile.prototype._getSeries = function() {
      var serie, _series;
      return _series = (function() {
        var _i, _len, _ref, _results;
        _ref = this.lab.getSeries();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          serie = _ref[_i];
          _results.push({
            name: "" + serie + " Wattz",
            data: this.lab.getSerieValues({
              'name': serie
            })
          });
        }
        return _results;
      }).call(this);
    };

    function LoadProfile(lab) {
      this.lab = lab;
      this.buildGraph();
    }

    return LoadProfile;

  })();

}).call(this);
