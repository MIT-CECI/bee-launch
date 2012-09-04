window.LaunchPad = class LaunchPad
  constructor: (lab) ->
    @lab = lab
    @profile = lab.profile
    console?.log 'hello houston, we are T - 238 minutes'

  launch: ->
    launchString = ""
    hours = 1
    for i in [0...@lab.length]
      if @_sameProfile(@profile[i], @profile[i + 1])
        hours++
      else
        console?.log "Hours: #{hours} -> Time: #{i} -> Profile: #{@profile[i]}"
        launchString += "#{hours * 60} #{@_normalizeHourProfile(@profile[i]).join(" ")} "
        hours = 1

    console?.log(launchString, "This is the launch profile string")
    launchString

  _normalizeHourProfile: (hourProfile) ->
    ( if !!element then '1' else '0' ) for element in hourProfile

  _sameProfile: (a, b) ->
    return false unless b
    for element, index in a
      return false if b[index] != element
    true