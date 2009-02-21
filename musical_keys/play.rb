require "highline/system_extensions"
include HighLine::SystemExtensions
require 'rubygems'
require 'midiator'
midi = MIDIator::Interface.new
midi.autodetect_driver

qwerty = [
'1234567890-='.scan(/./),
'qwertyuiop[]'.scan(/./),
"asdfghjkl;'".scan(/./),
'zxcvbnm,./'.scan(/./)
]
keyboard = qwerty.reverse

def find_pitch(keyboard, k)
    base = 60
    ret = nil
    keyboard.each_with_index do |row, r|
        row.each_with_index do |key, c|
            if key == k.chr then
                ret = (base + r * 5 + c)
            end
        end
    end
    ret
end
while true do
    k = get_character
    note = nil
    if k == 27 then # ESC
        exit
    else
        puts k
        if note then midi.note_off(note[:pitch], note[:duration], note[:velocity]) end
        pitch = find_pitch(keyboard, k)
        puts "pitch #{pitch}"
        note = {:pitch => pitch, :duration => 1, :velocity => 40}
        midi.note_on(note[:pitch], note[:duration], note[:velocity])
    end
end