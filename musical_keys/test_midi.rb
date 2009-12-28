require 'rubygems'
require 'midiator'
midi = MIDIator::Interface.new
midi.autodetect_driver
midi.use('dls_synth')
midi.play(84, 0.5)