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

  length: @length


  # Turns a load on/off at a specific hour
  #
  # It will not update the chart
  toggleLoad: (loadIndex, hour) ->
    hourWatts = parseInt @_loadMap[loadIndex]
    toggleItAsInt = + !@profile[hour][loadIndex] # returns 1 or 0 as integers
    @profile[hour][loadIndex] = hourWatts * toggleItAsInt


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


  # Private Functions ---------------------------------------------------------

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

  # jQuery Listener
  # Launches the experiment
  # TODO: Send everything to the server
  launchLab: ->
    console?.log("Launching lab!")
    window.launchPad.launch()

  _prepareLaunch: ->
    window.launchPad = null if window.launchPad?
    window.launchPad = new LaunchPad(@lab)

  _drawGraph: ->
    window.chart = null if window.chart?
    window.chart = new LoadProfile(@lab)

  _setupListeners: ->
    $('body').on 'change', '.js-add-load',        @setCurrentLoad
    $('body').on 'click',  'label.button.active', @removeCurrentLoad

    $('body').on 'click', '#js-launch-experiment', @launchLab

jQuery ($) ->
  app.setup()


