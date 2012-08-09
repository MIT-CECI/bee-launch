BEE =
  VERSION: '1.0.beta'
  EMPTY_LOAD:
    from: 0
    to: 0

class Lab
  constructor: (_length) ->
    @length  = _length
    @_buildProfile()
    @_registerPartials()

  length: @length

  displayLoadDialog: (index) ->
    source = $("#load-list").html()
    @template = Handlebars.compile(source)
    @template(
      title: "Adding #{@_loadMap[index]} wattz"
      experimentLength: @length
      times: @findLoadSchedule(+index)
    )

  findLoadSchedule: (loadIndex) ->
    startIndex = @_findFirst(+loadIndex, 0)
    results = [ ]
    console?.log("Starting at #{startIndex}")

    while startIndex < @length
      to = @_findUntil(loadIndex, startIndex)
      time = {from: startIndex, to: to}
      results.push time
      startIndex = @_findFirst(+loadIndex, to + 1)

    console?.log("The schedule is", results)
    results

  _findFirst: (loadIndex, startIndex) ->
    while (startIndex < @length and @profile[startIndex][loadIndex] == 0)
      startIndex++
    startIndex

  _findUntil: (loadIndex, startIndex) ->
    console?.log("Find until <#{loadIndex}, #{startIndex}>")
    to = startIndex
    while (to < @length and @profile[to][loadIndex] != 0 )
      to++
    to

  _registerPartials: ->
    Handlebars.registerPartial("single_load", $("#single-load").html());

  # Builds a `@maxLength` * 4 matrix that will hold what loads are on
  # at a specific time.
  _buildProfile: ->
    @profile = ([0,0,0,0] for [1..@length])

  # Map that holds the labels and indexes for each load
  # The index is the one in the `@profile` matrix
  _loadMap:
    '100' : 0
    '75'  : 1
    '50'  : 2
    '25'  : 3
    0     : '100'
    1     : '75'
    2     : '50'
    3     : '25'

# End of Lab Class

jQuery ($) ->
  window.lab = new Lab(48)

  ($ ".add-load").click (e) ->
    loadIndex = ($ @).data('load-index')
    console?.log("Adding #{loadIndex}")
    loadHTML = window.lab.displayLoadDialog(parseInt(loadIndex))
    $("#showme").html loadHTML
    false

  
