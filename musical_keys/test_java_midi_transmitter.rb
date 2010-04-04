require 'java'
MidiSystem = javax.sound.midi.MidiSystem
ShortMessage = javax.sound.midi.ShortMessage

receiver = MidiSystem.receiver
msg = ShortMessage.new
msg.setMessage(ShortMessage::NOTE_ON, 2, 65, 65)
receiver.send(msg, 1000)
sleep(1)
msg = ShortMessage.new
msg.setMessage(ShortMessage::NOTE_OFF, 2, 65, 65)
receiver.send(msg, 1000)
exit()