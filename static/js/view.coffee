# Simple view to render the current state using DOM+CSS
class exports.DOMView
  constructor: (@container) ->
    @bars = []
    @data_length = 1

    # Bind any DOM events
    # $(window).resize @resizeView

  # Update the view using a new array size
  setDataLength: (data_length) ->
    @data_length = data_length
    @resizeView()

  # Rescale all elements using parent container size
  resizeView: =>
    # Determine sizes
    width = @container.width()
    height = @container.height()
    bar_width = width / @data_length

    # Create bar elements
    @container.empty()
    @bars = []
    @negatives = []
    for i in [0..@data_length-1]
      bar = $('<div/>').addClass('bar').css
        width: "#{100 / @data_length}%"
      negative = $('<div/>').addClass('negative')
      bar.append negative
      @container.append bar
      @negatives[i] = negative
      @bars[i] = bar

  # Update view from sorter state data
  update: (state) ->
    # Check if we're passed a different data length, if so need to rebuild view
    if state.data.length != @data_length
      @setDataLength state.data.length

    # Update bar heights according to data, reset colors
    for i in [0..@data_length-1]
      height = state.data[i] / @data_length
      @negatives[i].height "#{100 - height * 100}%"
      @bars[i].css 'background-image', 'linear-gradient(to right, #FFFFFF, #BBBBBB)'

    # Color significant indices
    for index in state.sorted
      @bars[index].css 'background-image', 'linear-gradient(to right, #00FF00, #00BB00)'
    if state.compare_a? and state.compare_a < @data_length
      @bars[state.compare_a].css 'background-image', 'linear-gradient(to right, #FF0000, #BB0000)'
    if state.compare_b? and state.compare_b != state.compare_a and state.compare_b < @data_length
      @bars[state.compare_b].css 'background-image', 'linear-gradient(to right, #FF6666, #BB2222)'
