window.BEE =
  activeLoad: -1
  VERSION: '2.0.beta'
  EMPTY_LOAD:
    from: 0
    to: 0

# Lab class holds the main logic for the experiment. It is the controller of
# everything.
class Lab
  constructor: (_length) ->
    @length  = _length
    @_buildProfile()
    @_registerPartials()

  length: @length

  # Given object with either an index or a name, this method returns the
  # profile for that specific series.
  #
  # Returns the array of data.
  #
  # Examples:
  #
  # getSeriesValues({'name': '100 Wattz'})
  #   => returns an array with the values for the 100 Wattz series
  #
  # getSeriesValues({'index': 0})
  #   => returns an array with the values for the serie at index 0
  getSerieValues: (serieInfo) ->
    if serieInfo['name']
      loadIndex = @_loadMap[serieInfo['name']]
    else
      loadIndex = serieInfo['index']
    hourInterval[loadIndex] for hourInterval, time in @profile

  # Returns an array with the loads of each serie
  getSeries: -> ['Load 1', 'Load 2', 'Load 3', 'Load 4']

  # Displays the Handlebars template for the dialog loaded with the profile
  # for the series at `index`
  #
  # This index is for the graph series array.
  displayLoadDialog: (index) ->
    source = $("#load-list").html()
    @template = Handlebars.compile(source) unless @template
    @template(
      loadIndex: index
      title: "Managing #{@getSeries()[+index]}"
      experimentLength: @length
      times: @findLoadSchedule(+index)
    )

  # Finds all time intervals when the load at `loadIndex` is on.
  # It will find 'closed - open' intervals `[start, end)` meaning that the light
  # is on from `start` to `end` (but not on `end`)
  #
  # Returns an unsorted array of objects, like this `{from: start, to: end}`
  #
  # Examples:
  #
  # findLoadSchedule(0)
  #   => [{from: 2, to: 10}, {from: 13, to: 15}]
  #
  # findLoadSchedule(2)
  #   => [{from: 20, to: 25}, {from: 13, to: 15}] # not ordered!
  findLoadSchedule: (loadIndex) ->
    startIndex = @_findFirst(+loadIndex, 0)
    results = [ ]

    while startIndex < @length
      to = @_findUntil(loadIndex, startIndex)
      time = {from: startIndex, to: to}
      results.push time
      startIndex = @_findFirst(+loadIndex, to + 1)

    results

  # Turns off the load at `loadIndex` at every possible time in the experiment
  #
  # Changes the `@profile` array:
  # makes profile[i][`loadIndex`] = 0 for every index i
  #
  # Returns the experiment lenght.
  turnLoadOff: (loadIndex) ->
    num = 0
    while num < @length
      @profile[num][loadIndex] = 0
      num++
    num

  # Turns the load at `loadIndex` in the interval [`startIndex`, `endIndex`)
  turnLoadOn: (loadIndex, startIndex, endIndex) ->
    console?.log("Turning #{loadIndex} from #{startIndex} to #{endIndex}")
    while startIndex < endIndex
      @profile[startIndex][loadIndex] = parseInt @_loadMap[loadIndex]
      startIndex++
    true # force a true return, not an array.

  # Private Functions ---------------------------------------------------------

  # Private Function
  # Finds the first non-zero index for the load at `loadIndex` starting at
  # `startIndex`. This is used to build the intervals for each load profile.
  #
  # Returns an integer
  #
  # Examples:
  #
  # _findFirst(0, 3)
  #   => 4 # There is a non-zero value at 4
  _findFirst: (loadIndex, startIndex) ->
    while (startIndex < @length and @profile[startIndex][loadIndex] == 0)
      startIndex++
    startIndex

  # Private Function
  # Finds the first zero value of the load at `loadIndex` starting from
  # startIndex.
  #
  # This is used to find the upper (open) limit of the time interval for each
  # load profile.
  #
  # Returns an integer
  #
  # Examples:
  #
  # _findUntil(2, 4)
  #   => 5 # There is a zero value at 5
  _findUntil: (loadIndex, startIndex) ->
    to = startIndex
    while (to < @length and @profile[to][loadIndex] != 0 )
      to++
    to

  # Private Function
  # Registers a Handlerbar partial for usage on the templates
  _registerPartials: ->
    Handlebars.registerPartial("single_load", $("#single-load").html());

  # Private Function
  # Builds a `@maxLength` * 4 matrix that will hold what loads are on
  # at a specific time.
  #
  # Returns the matrix
  _buildProfile: -> @profile = ([0,0,0,0] for [1..@length])

  # Private object
  # Map that holds the labels and indexes for each load
  # The index is the one in the `@profile` matrix
  _loadMap:
    'Load 1'  : 0
    'Load 2'  : 1
    'Load 3'  : 2
    'Load 4'  : 3
    0         : '100'
    1         : '100'
    2         : '100'
    3         : '100'

# End of Lab Class ------------------------------------------------------------

# Returns wether the interval is valid for this experiment
#
# Returns a boolean
#
# Examples (with a 48 hour experiment)
#
# insideOfBounds(1,20)
#   => true
#
# insideOfBounds(1,50)
#   => false # upper limit too big
#
# insideOfBounds(21,20)
#   => false # lower limit < upper limit
insideOfBounds = (from, to) ->
  to    = parseInt(to)
  from  = parseInt(from)
  0 <= from <= to <= app.lab.length

app =
  setup: ->
    @lab = new Lab(24) # Max lab lenght
    @_drawGraph()
    @_setupListeners()
    @_prepareLaunch()
    $("#js-load-schedule").overlay
      fixed: false
      mask:
        color: '#000'
        loadSpeed: 200
        opacity: 0.2

  # jQuery Listener
  # Adds an input row to the load dialog
  addLoadRow: (event) ->
    source = $("#single-load").html()
    template = Handlebars.compile(source)
    ($ ".load-table").append(template(times: [BEE.EMPTY_LOAD]))
    event.preventDefault()

  # jQuery Listener
  # This will set the `window.currentLoad` to the one pointed by the radio
  # button that was just clicked.
  #
  # This will also toggle the label to an 'active' state
  setCurrentLoad: (event) ->
    $('label.button.active').removeClass('active')
    loadIndex = parseInt($(this).val())
    myLabel = $(this).parent().find('label').addClass('active')
    BEE.activeLoad = loadIndex

  # jQuery Listener
  # This will set the BEE.activeLoad to `-1` and also will remove any active
  # state from any label.
  removeCurrentLoad: (event) ->
    BEE.activeLoad = -1
    $('label.button.active').removeClass('active')
    $('.js-add-load').prop('checked', false)
    event.preventDefault()



  # DEPRECATED
  #
  # jQuery Listener
  # Displays the modal window with the selected load profile
  loadSchedule: (event) ->
    console?.log("DEPRECATED ON VERSION 2.0!")
    loadIndex = $(this).data('load-index')
    loadHTML = app.lab.displayLoadDialog(parseInt(loadIndex))
    $("#js-load-schedule").html(loadHTML)
    $("#js-load-schedule").overlay().load()
    event.preventDefault()

  # jQuery Listener
  # Removes the load input interval row
  removeLoadTime: (event) ->
    $(this).closest('.load').remove()
    event.preventDefault()

  # jQuery Listener
  # Launches the experiment
  # TODO: Send everything to the server
  launchLab: ->
    console?.log("Launching lab!")
    window.launchPad.launch()

  # jQuery Listener
  # Processes the information entered by the user and turns updates the profile
  # with the new data turning lights on/off.
  #
  # Handles errors for invalid data (like out of bound intervals).
  submitLoads: (evnt) ->
    $tos      = $(this).find 'input.tos'
    $froms    = $(this).find 'input.froms'
    loadIndex = parseInt $(this).find("#ldInd").val()

    app.lab.turnLoadOff(loadIndex)

    error = ""

    for from, index in $froms
      if insideOfBounds(parseInt(from.value), parseInt($tos[index].value))
        $(from).closest('.load').removeClass('error-row').find('td').removeClass('error-row')
        app.lab.turnLoadOn(loadIndex, parseInt(from.value), parseInt($tos[index].value))
      else
        console?.log "Out of bounds #{from.value} #{parseInt($tos[index].value)}"
        $(from).closest('.load').addClass('error-row').find('td').addClass('error-row')
        error = "#invalid-length"

    if error != ""
      $("#load-modal .error").show()
    else
      $("#js-load-schedule").overlay().close()
      window.chart.updateChart(loadIndex)

    evnt.preventDefault()

  _prepareLaunch: ->
    window.launchPad = null if window.launchPad?
    window.launchPad = new LaunchPad(@lab)

  _drawGraph: ->
    window.chart = null if window.chart?
    window.chart = new LoadProfile(@lab)

  _setupListeners: ->
    $('body').on 'click',  '.js-add-load-row', @addLoadRow
    $('body').on 'click',  '.load .js-remove', @removeLoadTime

    $('body').on 'change', '.js-add-load',        @setCurrentLoad
    $('body').on 'click',  'label.button.active', @removeCurrentLoad

    $('body').on 'click', '#js-launch-experiment', @launchLab

    $('body').on 'submit', '#submit-loads', @submitLoads


jQuery ($) ->
  app.setup()


