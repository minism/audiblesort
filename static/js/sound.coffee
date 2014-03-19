# Constants
SAMPLE_RATE = 44100
CHANNELS = 1


# Sound synthesizer controller, uses Audiolet library
class exports.SoundController
  constructor: (update_rate) ->
    # Setup core audio.  Ensure our buffer size can cover our update speed
    ups = 1000 / update_rate
    bufsize = constrain(pow2floor(SAMPLE_RATE / ups), 32, 8192)
    console.log bufsize
    @audiolet = new Audiolet SAMPLE_RATE, CHANNELS, 2048
    @master = new Gain @audiolet, 0.1
    @master.connect @audiolet.output
    @synth = new Synth @audiolet
    @synth.connect @master

    # State tracking
    @last_compare = null

  update: (state) ->
    if state.compare_b? and state.compare_b != @last_compare
      @last_compare = state.compare_b
      freq = scale 220, 1000, state.data[state.compare_b] / state.data.length
      @synth.sine.frequency.setValue freq


class Synth extends AudioletGroup
  constructor: (@audiolet) ->
    super @audiolet, 0, 1
    @sine = new Sine @audiolet, 0
    @gain = new Gain @audiolet, 0.5
    @env = new PercussiveEnvelope @audiolet, 1, 0.01, 0.03, =>
      @audiolet.scheduler.addRelative 0, => @remove()

    # Connect envelope to gain level input (1)
    # @env.connect @gain, 0, 1

    # Connect sine to gain signal input (0)
    @sine.connect @gain, 0, 0
    @gain.connect @outputs[0]


# Return the nearest power of two, rounding down
pow2floor = (n) ->
  n |= n >> 1
  n |= n >> 2
  n |= n >> 4
  n |= n >> 8
  n |= n >> 16
  (n >> 1) + 1


constrain = (val, lower, upper) ->
  Math.max(Math.min(val, upper), lower)


scale = (lower, upper, alpha) ->
  lower + ((upper - lower) * alpha)
