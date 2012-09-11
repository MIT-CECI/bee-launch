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

    LoadProfile.prototype.addToCurrentLoad = function(xPosition) {
      var currentLoad;
      xPosition = Math.round(xPosition);
      if (xPosition < 0) {
        xPosition = 0;
      }
      if (xPosition >= this.lab.lenght) {
        xPosition = this.lab.lenght - 1;
      }
      currentLoad = BEE.activeLoad;
      if (currentLoad >= 0) {
        this.lab.toggleLoad(currentLoad, xPosition);
        return this.updateChart(currentLoad);
      } else {
        return $(".navigation").stop().effect("bounce", {
          times: 2
        }, 200);
      }
    };

    LoadProfile.prototype.buildGraph = function() {
      var labWidth,
        _this = this;
      labWidth = 900;
      return this.chart = new Highcharts.Chart({
        chart: {
          renderTo: 'chart-container',
          type: 'column',
          events: {
            click: function(event) {
              _this.addToCurrentLoad(event.xAxis[0].value);
              return false;
            }
          }
        },
        title: {
          text: 'Load Profiles'
        },
        tooltip: {
          formatter: function() {
            var serie, text, total, x, _i, _len, _ref;
            x = parseInt(this.x);
            total = 0;
            text = "<b>" + this.x + " - " + (x + 1) + ":00</b> <br /> -- <br />";
            _ref = this.series.chart.series;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              serie = _ref[_i];
              if (serie.yData[x] > 0) {
                text += "" + serie.name + " <br />";
              }
              total += serie.yData[x];
            }
            text += " -- <br />";
            text += "<b> Total: " + total + " wattz </b>";
            return text;
          }
        },
        xAxis: {
          min: 0,
          max: this.lab.length - 1,
          padding: 0,
          title: {
            text: 'Test Chamber Hours'
          },
          categories: (function() {
            var hour, _i, _ref, _results;
            _results = [];
            for (hour = _i = 0, _ref = _this.lab.length; 0 <= _ref ? _i <= _ref : _i >= _ref; hour = 0 <= _ref ? ++_i : --_i) {
              _results.push("" + hour + ":00");
            }
            return _results;
          })()
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
          series: {
            cursor: 'pointer',
            point: {
              events: {
                click: function(event) {
                  _this.addToCurrentLoad(event.point.x);
                  event.preventDefault();
                  return false;
                }
              }
            }
          },
          column: {
            borderWidth: 2,
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
            name: serie,
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
