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

  getSerieValues: (serieInfo) ->
    if serieInfo['name']
      loadIndex = @_loadMap[serieInfo['name']]
    else
      loadIndex = serieInfo['index']
    hourInterval[loadIndex] for hourInterval in @profile

  getSeries: ->
    ['100', '75', '50', '25']

  displayLoadDialog: (index) ->
    source = $("#load-list").html()
    @template = Handlebars.compile(source)
    @template(
      loadIndex: index
      title: "Adding #{@_loadMap[index]} wattz"
      experimentLength: @length
      times: @findLoadSchedule(+index)
    )

  findLoadSchedule: (loadIndex) ->
    startIndex = @_findFirst(+loadIndex, 0)
    results = [ ]

    while startIndex < @length
      to = @_findUntil(loadIndex, startIndex)
      time = {from: startIndex, to: to}
      results.push time
      startIndex = @_findFirst(+loadIndex, to + 1)

    results

  turnLoadOff: (loadIndex) ->
    num = 0
    while num < @length
      @profile[num][loadIndex] = 0
      num++
    num

  turnLoadOn: (loadIndex, startIndex, endIndex) ->
    console?.log("Turning #{loadIndex} from #{startIndex} to #{endIndex}")
    while startIndex < endIndex
      @profile[startIndex][loadIndex] = parseInt @_loadMap[loadIndex]
      startIndex++

  # Private Functions ---------------------------------------------------------

  _findFirst: (loadIndex, startIndex) ->
    while (startIndex < @length and @profile[startIndex][loadIndex] == 0)
      startIndex++
    startIndex

  _findUntil: (loadIndex, startIndex) ->
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

# End of Lab Class ------------------------------------------------------------

insideOfBounds = (from, to) ->
  to    = parseInt(to)
  from  = parseInt(from)
  0 <= from <= to <= app.lab.length

app =
  setup: ->
    @lab = new Lab(48) # Max lab lenght
    @_drawGraph()
    @_setupListeners()
    $("#js-load-schedule").overlay
      fixed: false
      mask:
        color: '#000'
        loadSpeed: 200
        opacity: 0.2

  addLoadRow: (event) ->
    source = $("#single-load").html()
    template = Handlebars.compile(source)
    ($ ".load-table").append(template(times: [BEE.EMPTY_LOAD]))
    event.preventDefault()

  loadSchedule: (event) ->
    loadIndex = $(this).data('load-index')
    loadHTML = app.lab.displayLoadDialog(parseInt(loadIndex))
    $("#js-load-schedule").html(loadHTML)
    $("#js-load-schedule").overlay().load()
    event.preventDefault()

  removeLoadTime: (event) ->
    $(this).closest('.load').remove()
    event.preventDefault()

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

  _drawGraph: ->
    window.chart = null if window.chart?
    window.chart = new LoadProfile(@lab)

  _setupListeners: ->
    $('body').on 'click', '.js-add-load-row', @addLoadRow
    $('body').on 'click', '.js-add-load',     @loadSchedule
    $('body').on 'click', '.load .js-remove', @removeLoadTime

    $('body').on 'submit', '#submit-loads', @submitLoads


jQuery ($) ->
  app.setup()


