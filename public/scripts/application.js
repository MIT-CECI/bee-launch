(function() {
  var BEE, Lab, app, insideOfBounds;

  BEE = {
    VERSION: '1.0.beta',
    EMPTY_LOAD: {
      from: 0,
      to: 0
    }
  };

  Lab = (function() {

    function Lab(_length) {
      this.length = _length;
      this._buildProfile();
      this._registerPartials();
    }

    Lab.prototype.length = Lab.length;

    Lab.prototype.getSerieValues = function(serieInfo) {
      var hourInterval, loadIndex, time, _i, _len, _ref, _results;
      if (serieInfo['name']) {
        loadIndex = this._loadMap[serieInfo['name']];
      } else {
        loadIndex = serieInfo['index'];
      }
      _ref = this.profile;
      _results = [];
      for (time = _i = 0, _len = _ref.length; _i < _len; time = ++_i) {
        hourInterval = _ref[time];
        _results.push(hourInterval[loadIndex]);
      }
      return _results;
    };

    Lab.prototype.getSeries = function() {
      return ['Load 1', 'Load 2', 'Load 3', 'Load 4'];
    };

    Lab.prototype.displayLoadDialog = function(index) {
      var source;
      source = $("#load-list").html();
      if (!this.template) {
        this.template = Handlebars.compile(source);
      }
      return this.template({
        loadIndex: index,
        title: "Managing " + (this.getSeries()[+index]),
        experimentLength: this.length,
        times: this.findLoadSchedule(+index)
      });
    };

    Lab.prototype.findLoadSchedule = function(loadIndex) {
      var results, startIndex, time, to;
      startIndex = this._findFirst(+loadIndex, 0);
      results = [];
      while (startIndex < this.length) {
        to = this._findUntil(loadIndex, startIndex);
        time = {
          from: startIndex,
          to: to
        };
        results.push(time);
        startIndex = this._findFirst(+loadIndex, to + 1);
      }
      return results;
    };

    Lab.prototype.turnLoadOff = function(loadIndex) {
      var num;
      num = 0;
      while (num < this.length) {
        this.profile[num][loadIndex] = 0;
        num++;
      }
      return num;
    };

    Lab.prototype.turnLoadOn = function(loadIndex, startIndex, endIndex) {
      if (typeof console !== "undefined" && console !== null) {
        console.log("Turning " + loadIndex + " from " + startIndex + " to " + endIndex);
      }
      while (startIndex < endIndex) {
        this.profile[startIndex][loadIndex] = parseInt(this._loadMap[loadIndex]);
        startIndex++;
      }
      return true;
    };

    Lab.prototype._findFirst = function(loadIndex, startIndex) {
      while (startIndex < this.length && this.profile[startIndex][loadIndex] === 0) {
        startIndex++;
      }
      return startIndex;
    };

    Lab.prototype._findUntil = function(loadIndex, startIndex) {
      var to;
      to = startIndex;
      while (to < this.length && this.profile[to][loadIndex] !== 0) {
        to++;
      }
      return to;
    };

    Lab.prototype._registerPartials = function() {
      return Handlebars.registerPartial("single_load", $("#single-load").html());
    };

    Lab.prototype._buildProfile = function() {
      return this.profile = (function() {
        var _i, _ref, _results;
        _results = [];
        for (_i = 1, _ref = this.length; 1 <= _ref ? _i <= _ref : _i >= _ref; 1 <= _ref ? _i++ : _i--) {
          _results.push([0, 100, 0, 0]);
        }
        return _results;
      }).call(this);
    };

    Lab.prototype._loadMap = {
      'Load 1': 0,
      'Load 2': 1,
      'Load 3': 2,
      'Load 4': 3,
      0: '100',
      1: '100',
      2: '100',
      3: '100'
    };

    return Lab;

  })();

  insideOfBounds = function(from, to) {
    to = parseInt(to);
    from = parseInt(from);
    return ((0 <= from && from <= to) && to <= app.lab.length);
  };

  app = {
    setup: function() {
      this.lab = new Lab(24);
      this._drawGraph();
      this._setupListeners();
      this._prepareLaunch();
      return $("#js-load-schedule").overlay({
        fixed: false,
        mask: {
          color: '#000',
          loadSpeed: 200,
          opacity: 0.2
        }
      });
    },
    addLoadRow: function(event) {
      var source, template;
      source = $("#single-load").html();
      template = Handlebars.compile(source);
      ($(".load-table")).append(template({
        times: [BEE.EMPTY_LOAD]
      }));
      return event.preventDefault();
    },
    loadSchedule: function(event) {
      var loadHTML, loadIndex;
      loadIndex = $(this).data('load-index');
      loadHTML = app.lab.displayLoadDialog(parseInt(loadIndex));
      $("#js-load-schedule").html(loadHTML);
      $("#js-load-schedule").overlay().load();
      return event.preventDefault();
    },
    removeLoadTime: function(event) {
      $(this).closest('.load').remove();
      return event.preventDefault();
    },
    launchLab: function() {
      if (typeof console !== "undefined" && console !== null) {
        console.log("Launching lab!");
      }
      return window.launchPad.launch();
    },
    submitLoads: function(evnt) {
      var $froms, $tos, error, from, index, loadIndex, _i, _len;
      $tos = $(this).find('input.tos');
      $froms = $(this).find('input.froms');
      loadIndex = parseInt($(this).find("#ldInd").val());
      app.lab.turnLoadOff(loadIndex);
      error = "";
      for (index = _i = 0, _len = $froms.length; _i < _len; index = ++_i) {
        from = $froms[index];
        if (insideOfBounds(parseInt(from.value), parseInt($tos[index].value))) {
          $(from).closest('.load').removeClass('error-row').find('td').removeClass('error-row');
          app.lab.turnLoadOn(loadIndex, parseInt(from.value), parseInt($tos[index].value));
        } else {
          if (typeof console !== "undefined" && console !== null) {
            console.log("Out of bounds " + from.value + " " + (parseInt($tos[index].value)));
          }
          $(from).closest('.load').addClass('error-row').find('td').addClass('error-row');
          error = "#invalid-length";
        }
      }
      if (error !== "") {
        $("#load-modal .error").show();
      } else {
        $("#js-load-schedule").overlay().close();
        window.chart.updateChart(loadIndex);
      }
      return evnt.preventDefault();
    },
    _prepareLaunch: function() {
      if (window.launchPad != null) {
        window.launchPad = null;
      }
      return window.launchPad = new LaunchPad(this.lab);
    },
    _drawGraph: function() {
      if (window.chart != null) {
        window.chart = null;
      }
      return window.chart = new LoadProfile(this.lab);
    },
    _setupListeners: function() {
      $('body').on('click', '.js-add-load-row', this.addLoadRow);
      $('body').on('click', '.js-add-load', this.loadSchedule);
      $('body').on('click', '.load .js-remove', this.removeLoadTime);
      $('body').on('click', '#js-launch-experiment', this.launchLab);
      return $('body').on('submit', '#submit-loads', this.submitLoads);
    }
  };

  jQuery(function($) {
    return app.setup();
  });

}).call(this);
