# Constants
SAMPLE_RATE = 44100
CHANNELS = 1


# Sound synthesizer controller, uses Audiolet library
class exports.SoundController
  constructor: (update_rate) ->
    # Setup core audio.  Ensure our buffer size can cover our update speed
    ups = 1000 / update_rate
    bufsize = constrain(pow2floor(SAMPLE_RATE / ups), 512, 8192)
    console.log "Setting bufsize to #{bufsize}"
    @audiolet = new Audiolet SAMPLE_RATE, CHANNELS, bufsize
    @master = new Gain @audiolet, 0.1
    @master.connect @audiolet.output
    @synth = new Synth @audiolet
    @synth.connect @master

    # State tracking
    @last_compare = null

  update: (state) ->
    if state.compare_b? and state.compare_b != @last_compare
      @last_compare = state.compare_b
      value = state.data[state.compare_b] / state.data.length
      @synth.setValue value


class Synth extends AudioletGroup
  constructor: (@audiolet) ->
    # Setup output audio nodes
    super @audiolet, 0, 1
    @gain = new Gain @audiolet, 1
    @gain.connect @outputs[0]
    @voice = new OscGain @audiolet, 220, 1
    @voice.connect @gain


  setValue: (value) ->
    # @voice.setFreq Math.pow(100, 1 + value * 0.25)
    @voice.setFreq 110 + value * 400
    # @voice.osc.pulseWidth.setValue 0.95 - value * 0.4


# Simple OSC+Gain group
class OscGain extends AudioletGroup
  constructor: (@audiolet, freq, gain) ->
    super @audiolet, 0, 1
    @osc = new Triangle @audiolet, freq
    @gain = new Gain @audiolet, gain
    @osc.connect @gain
    @gain.connect @outputs[0]

  setGain: (gain) ->
    @gain.gain.setValue gain

  setFreq: (freq) ->
    @osc.frequency.setValue freq


# Return the nearest power of two, rounding down
pow2ceil = (n) ->
  n |= n >> 1
  n |= n >> 2
  n |= n >> 4
  n |= n >> 8
  n |= n >> 16
  n


pow2floor = (n) -> (pow2ceil n >> 1) + 1

constrain = (val, lower, upper) -> Math.max(Math.min(val, upper), lower)

scale = (lower, upper, alpha) -> lower + ((upper - lower) * alpha)
