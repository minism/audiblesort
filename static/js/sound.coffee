# Static audiolet object
audiolet = new Audiolet


# Sound synthesizer controller, uses Audiolet library
class exports.SoundController
  constructor: ->
    @synth = new Synth 440
    master = new Gain audiolet, 0.1
    @synth.connect master
    master.connect audiolet.output

  update: (state) ->
    if state.compare_a?
      freq = scale 220, 1000, state.data[state.compare_b] / state.data.length


class Synth extends AudioletGroup
  constructor: (freq) ->
    super audiolet, 0, 1
    @sine = new Sine audiolet, freq
    @gain = new Gain audiolet, 0.5
    @env = new PercussiveEnvelope audiolet, 1, 0.5, 0.5, =>
      audiolet.scheduler.addRelative 0, @remove.bind(@this)
    @env.connect @gain, 0, 1
    @sine.connect @gain
    @gain.connect @outputs[0]


scale = (lower, upper, alpha) ->
  lower + ((upper - lower) * alpha)
