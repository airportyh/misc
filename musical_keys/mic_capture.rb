#!/usr/bin/env /usr/local/jruby-1.4.0/bin/jruby
require 'java'
require 'cheri_java_preview'
class Array
  def avg
   inject{|x, y| x + y} / size.to_f
  end
end

AudioFormat = javax.sound.sampled.AudioFormat
DataLineInfo = javax.sound.sampled.DataLine::Info
TargetDataLine = javax.sound.sampled.TargetDataLine
AudioSystem = javax.sound.sampled.AudioSystem
AudioFileFormat = javax.sound.sampled.AudioFileFormat
format = AudioFormat.new(8000.0, 8, 1, true, false)
data_line_info = DataLineInfo.new(TargetDataLine.java_class, format)
data_line = AudioSystem.getLine(data_line_info)
data_line.open
data_line.start
array_size = 500
bytes = Array.java_array :byte, array_size
while true
  bytes_read = data_line.read(bytes, 0, array_size)
  #print "read #{bytes_read} bytes"
  #print "#{bytes.map{|b|b.abs}.avg} "
  bytes.each do |b|
    puts "#{b} "
  end
end
exit 0