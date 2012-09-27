(function() {
  var Lab, app;

  window.BEE = {
    activeLoad: -1,
    VERSION: '2.0.beta',
    EMPTY_LOAD: {
      from: 0,
      to: 0
    }
  };

  Lab = (function() {

    function Lab(_length) {
      this.length = _length;
      this._buildProfile();
    }

    Lab.prototype.length = Lab.length;

    Lab.prototype.toggleLoad = function(loadIndex, hour) {
      var hourWatts, toggleItAsInt;
      hourWatts = parseInt(this._loadMap[loadIndex]);
      toggleItAsInt = +(!this.profile[hour][loadIndex]);
      return this.profile[hour][loadIndex] = hourWatts * toggleItAsInt;
    };

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

    Lab.prototype._buildProfile = function() {
      return this.profile = (function() {
        var _i, _ref, _results;
        _results = [];
        for (_i = 1, _ref = this.length; 1 <= _ref ? _i <= _ref : _i >= _ref; 1 <= _ref ? _i++ : _i--) {
          _results.push([0, 0, 0, 0]);
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

  app = {
    setup: function() {
      this.lab = new Lab(24);
      this._drawGraph();
      this._setupListeners();
      return this._prepareLaunch();
    },
    setCurrentLoad: function(event) {
      var loadIndex, myLabel;
      $('label.button.active').removeClass('active');
      loadIndex = parseInt($(this).val());
      myLabel = $(this).parent().find('label').addClass('active');
      return BEE.activeLoad = loadIndex;
    },
    removeCurrentLoad: function(event) {
      BEE.activeLoad = -1;
      $('label.button.active').removeClass('active');
      $('.js-add-load').prop('checked', false);
      return event.preventDefault();
    },
    launchLab: function(event) {
      var launchString;
      launchString = window.launchPad.launch();
      if (typeof console !== "undefined" && console !== null) {
        console.log(launchString, "Launching lab!");
      }
      $("#hdnProfile").val(launchString);
      return $("#btnGo").click();
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
      $('body').on('change', '.js-add-load', this.setCurrentLoad);
      $('body').on('click', 'label.button.active', this.removeCurrentLoad);
      return $('body').on('click', '#js-launch-experiment', this.launchLab);
    }
  };

  jQuery(function($) {
    return app.setup();
  });

}).call(this);
