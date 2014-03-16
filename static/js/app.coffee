sorters = require './sorters.coffee'
view = require './view.coffee'


SPEED = 50
SIZE = 50


class Application
  constructor: ->
    # Setup all subsystems
    @sorter = new sorters.SelectionSorter SIZE, SPEED
    @view = new view.View $('#app')
    @time = 0

    # Schedule main loop
    requestAnimationFrame @update

  update: (time) =>
    # Calculate DT for subsystems
    dt = time - @time
    @time = time

    # Update subsystems
    @sorter.update(dt)
    state = @sorter.getState()
    @view.update state
    requestAnimationFrame @update


# Initialize
window.app = new Application