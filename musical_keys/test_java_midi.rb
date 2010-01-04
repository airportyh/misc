require 'java'
synth = javax.sound.midi.MidiSystem.getSynthesizer
synth.open


soundbank = synth.getDefaultSoundbank
synth.loadAllInstruments(soundbank)
@channel = synth.getChannels[0]

def play_note(note, duration, intensity=8)
  @channel.noteOn(note, intensity)
  sleep(duration.to_f / 1000)
  @channel.noteOff(note, intensity)
end

def rest(duration)
  sleep(duration.to_f / 1000)
end

play_note(52,250)
play_note(60,250)
play_note(58,250)
play_note(56,250)


play_note(52,500)
rest(250)
play_note(52,125)
play_note(52,125)


play_note(52,500)
play_note(60,250)
play_note(58,250)
play_note(56,250)
  
exit 0