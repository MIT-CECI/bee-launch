class Lab
  constructor: (maxLength) ->
    @maxLength  = maxLength
    @_buildProfile()

  maxLength: @maxLength

  # Builds a `@maxLength` * 4 matrix that will hold what loads are on
  # at a specific time.
  _buildProfile: ->
    @profile    = ([0,0,0,0] for [1..@maxLength])

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


# jQuery ($) ->
window.lab = new Lab(48)