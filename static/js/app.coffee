sorters = require './sorters.coffee'
view = require './view.coffee'
sound = require './sound.coffee'


SPEED = 0.1
SIZE = 50


class Application
  constructor: ->
    # Setup all subsystems
    sortclass = window.location.hash and sorters.InsertionSorter or sorters.SelectionSorter
    @sorter = new sortclass SIZE, SPEED
    @view = new view.DOMView $('#app')
    @sound = new sound.SoundController SPEED

    # Keep track of last timestamp for dt calculation
    @ts = 0

    # Schedule main loop
    requestAnimationFrame @update

  update: (ts) =>
    # Calculate DT and update sorter
    dt = ts - @ts
    @ts = ts
    @sorter.update(dt)

    # Update subsystems with sorter state
    state = @sorter.getState()
    @view.update state
    @sound.update state
    requestAnimationFrame @update


# Initialize
window.app = new Application