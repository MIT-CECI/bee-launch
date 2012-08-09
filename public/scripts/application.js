(function() {
  var BEE, Lab;

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

    Lab.prototype.displayLoadDialog = function(index) {
      var source;
      source = $("#load-list").html();
      this.template = Handlebars.compile(source);
      return this.template({
        loadIndex: index,
        title: "Adding " + this._loadMap[index] + " wattz",
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
      var _results;
      if (typeof console !== "undefined" && console !== null) {
        console.log("Turning " + loadIndex + " from " + startIndex + " to " + endIndex);
      }
      _results = [];
      while (startIndex < endIndex) {
        this.profile[startIndex][loadIndex] = parseInt(this._loadMap[loadIndex]);
        _results.push(startIndex++);
      }
      return _results;
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
          _results.push([0, 0, 0, 0]);
        }
        return _results;
      }).call(this);
    };

    Lab.prototype._loadMap = {
      '100': 0,
      '75': 1,
      '50': 2,
      '25': 3,
      0: '100',
      1: '75',
      2: '50',
      3: '25'
    };

    return Lab;

  })();

  jQuery(function($) {
    window.lab = new Lab(48);
    ($('body')).on('click', '.js-add-load-row', function() {
      var source, template;
      source = $("#single-load").html();
      template = Handlebars.compile(source);
      ($(".load-table")).append(template({
        times: [BEE.EMPTY_LOAD]
      }));
      return false;
    });
    ($('body')).on('submit', '#submit-loads', function(evnt) {
      var $froms, $tos, from, index, loadIndex, _i, _len;
      $tos = $(this).find('input.tos');
      $froms = $(this).find('input.froms');
      loadIndex = parseInt($(this).find("#ldInd").val());
      lab.turnLoadOff(loadIndex);
      for (index = _i = 0, _len = $froms.length; _i < _len; index = ++_i) {
        from = $froms[index];
        lab.turnLoadOn(loadIndex, parseInt(from.value), parseInt($tos[index].value));
      }
      $("#showme").html("Loads added!");
      return evnt.preventDefault();
    });
    ($(".js-add-load")).click(function(e) {
      var loadHTML, loadIndex;
      loadIndex = ($(this)).data('load-index');
      loadHTML = window.lab.displayLoadDialog(parseInt(loadIndex));
      $("#showme").html(loadHTML);
      return false;
    });
    return $('body').on('click', '.load .js-remove', function(evnt) {
      $(this).closest('.load').remove();
      return evnt.preventDefault();
    });
  });

}).call(this);