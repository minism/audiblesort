_ = require 'lodash'



class SortState
  constructor:(@data) ->


# Base class for sorters.
# A sorter contains all of the logic for a sorting algorithm, with an interface to explain
# the current state of values as well as what are "significant" values, such as the last
# number to be moved.
# 
# Sorters don't schedule themselves, they expect clients to ask them to iterate.
class BaseSorter
  constructor: (@size, @speed) ->
    # Array data to be sorted
    @data = [1..@size]

    # Boolean whether the sorting is complete
    @complete = false

    # Two comparison inices to keep track of
    @compare_a = null
    @compare_b = null

    # List of indices which are in their final position
    @sorted = []

    # Controls update timing
    @timer = 0

    # Randomize initially
    @_randomize()

  update: (dt) ->
    # Perform a single sorting iteration each timer interval
    @timer -= dt
    if @timer < 0
      @timer += @speed
      @_iterate()

  # Returns an object which encapsulates the state data used to synchronize
  # between different subsystems (audio, view, ...)
  getState: ->
    state =
      data: @getData()
      compare_a: @compare_a
      compare_b: @compare_b
      complete: @complete
      sorted: @sorted

  # Get the data representation for this sorter
  getData: ->
    @data

  # This should be implemented for each sorter
  _iterate: ->
    throw Error "Not implemented"

  _randomize: ->
    @data = _.shuffle @data

  # Swap two values in data
  _swap: (a, b) ->
    tmp = @data[a]
    @data[a] = @data[b]
    @data[b] = tmp


class exports.SelectionSorter extends BaseSorter
  constructor: (args...) ->
    super args...
    @sorted_index = 0

  _iterate: ->
    # No comparison base, start next scan
    if @compare_a is null
      if @sorted_index < @data.length
        @compare_a = @compare_b = @sorted_index
      else
        complete = true

    # Active scan
    else if @compare_b < @data.length - 1
      if @data[++@compare_b] < @data[@compare_a]
        @compare_a = @compare_b

    # Perform swap and trigger next scan
    else
      @_swap(@compare_a, @sorted_index)
      @sorted.push @sorted_index++
      @compare_a = null


class exports.InsertionSorter extends BaseSorter
  constructor: (args...) ->
    super args...
    @compare_a = @compare_b = 0

  # Remove value from 'from' index, inserting at 'to' index and shifting everything upwards. 
  _insert: (from, to) ->
    tmp = @data[from]
    for i in [from..to+1]
      @data[i] = @data[i-1]
    @data[to] = tmp

  _iterate: ->
    # No comparison base, start next scan
    if @compare_a >= @data.length
      complete = true
      @sorted = [0..@data.length-1]

    # Active scan
    else if @compare_b < @compare_a
      if @data[@compare_a] < @data[@compare_b]
        @_insert(@compare_a++, @compare_b)
        @compare_b = 0
      else
        @compare_b++

    # Already in correct order
    else
      @compare_a++
      @compare_b = 0

