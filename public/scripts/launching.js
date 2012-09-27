(function() {
  var LaunchPad;

  window.LaunchPad = LaunchPad = (function() {

    function LaunchPad(lab) {
      this.lab = lab;
      this.profile = lab.profile;
    }

    LaunchPad.prototype.launch = function() {
      var hours, i, launchString, _i, _ref;
      launchString = "";
      hours = 1;
      for (i = _i = 0, _ref = this.lab.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (this._sameProfile(this.profile[i], this.profile[i + 1])) {
          hours++;
        } else {
          launchString += "" + (hours * 60) + " " + (this._normalizeHourProfile(this.profile[i]).join(" ")) + " ";
          hours = 1;
        }
      }
      return launchString;
    };

    LaunchPad.prototype._normalizeHourProfile = function(hourProfile) {
      var element, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = hourProfile.length; _i < _len; _i++) {
        element = hourProfile[_i];
        _results.push(!!element ? '1' : '0');
      }
      return _results;
    };

    LaunchPad.prototype._sameProfile = function(a, b) {
      var element, index, _i, _len;
      if (!b) {
        return false;
      }
      for (index = _i = 0, _len = a.length; _i < _len; index = ++_i) {
        element = a[index];
        if (b[index] !== element) {
          return false;
        }
      }
      return true;
    };

    return LaunchPad;

  })();

}).call(this);
