#!/usr/bin/env /usr/local/jruby-1.4.0/bin/jruby

require 'java'
require 'cheri_java_preview'
require 'miglayout-3.7-swing.jar'
require 'set'
require 'enumerator'
require 'key_mapper'
require 'note_layouts'

# average function for arrays
class Array
  def avg
   inject{|x, y| x + y} / size.to_f
  end
end

JPanel = javax.swing.JPanel
JLabel = javax.swing.JLabel
BorderLayout = java.awt.BorderLayout
JFrame = javax.swing.JFrame
MigLayout = Java::net.miginfocom.swing.MigLayout
SwingConstants = javax.swing.SwingConstants
JComboBox = javax.swing.JComboBox
JSpinner = javax.swing.JSpinner
Font = java.awt.Font
GridLayout = java.awt.GridLayout
JCheckBox = javax.swing.JCheckBox
Color = java.awt.Color

AudioFormat = javax.sound.sampled.AudioFormat
DataLineInfo = javax.sound.sampled.DataLine::Info
TargetDataLine = javax.sound.sampled.TargetDataLine
AudioSystem = javax.sound.sampled.AudioSystem
AudioFileFormat = javax.sound.sampled.AudioFileFormat


class MidiChannel
  def initialize(real_channel, index)
    @channel = real_channel
    @index = index
  end
  
  def noteOn(pitch, velocity)
    @channel.noteOn(pitch, velocity)
  end
  
  def noteOff(pitch, velocity)
    @channel.noteOff(pitch, velocity)
  end
  
  def allNotesOff
    @channel.allNotesOff
  end
  
  def programChange(bank, program)
    @channel.programChange(bank, program)
  end
  
  def controlChange(controller, value)
    @channel.controlChange(controller, value)
  end
  
  def to_s
    "Channel #{@index}"
  end
end

class KeyboardDisplay < java.awt.Component
  
  def initialize(app)
    super()
    @app = app
    @row_offsets = [0, 0, 0.6, 1, 1.4]
  end
  
  def getPreferredSize
    java.awt.Dimension.new(720, 400)
  end
  
  def scale(num)
    
  end
  
  def paint(g)
    sx = sy = size.width.to_f / getPreferredSize.width.to_f
    g.scale(sx, sy) if sx > 0
    gap = 5
    round = 5
    width = 42.7
    height = width
    @app.key_mapper.keyboard.each_with_index do |row_chars, row|
      row_offset = @row_offsets[row] * width
      key_height = row == 0 ? height * 0.6 : height
      key_width = row == 0 ? width * 1.05 : width
      row_chars.each_with_index do |k, col|
        x = gap + col * (key_width + gap) + row_offset
        y = row == 0 ? gap : gap + (row - 1) * (height + gap) + (height * 0.6 + gap)
        rect = java.awt.geom.RoundRectangle2D::Double.new(
           x, y, key_width, key_height, round, round)
        
        key = @app.key_mapper.key(k)
        
        if @app.current_notes.include?(k)
          org_color = g.color
          g.color = Color.new(188, 188, 188)
          g.fill(rect)
          g.color = org_color
        else
          if @app.split_keyboard and @app.left_hand?(key)
            org_color = g.color
            g.color = Color.new(220, 220, 220)
            g.fill(rect)
            g.color = org_color
          end
        end
        g.draw(rect)
        note = @app.note_for_key(key)
        if note
          g.drawString(note.name, x + gap, y + gap + gap * 2)
        end
      end
    end
  end
end

class KeyboardSection
  include java.awt.event.ActionListener
  include javax.swing.event.ChangeListener
  attr_accessor :current_channel, :current_layout, :offset_octaves, :name
  def initialize(name, app, channel)
    @name = name
    @app = app
    @current_channel = channel
    @current_layout = @app.layouts.first
    @pitch_offset = 0
  end
  
  def create_controls
    form_panel = JPanel.new
    form_panel.layout = MigLayout.new("fill")
    
    title_label = JLabel.new(@name, SwingConstants::CENTER)
    title_label.font = Font.new("Arial", -1, 20)
    form_panel.add(title_label, "span 2, growx, wrap, align center")
    
    @channel_select = JComboBox.new(@app.channels.to_java)
    @channel_select.selectedItem = @current_channel
    @channel_select.focusable = false
    @channel_select.addActionListener(self)
    form_panel.add(JLabel.new("Channel"))
    form_panel.add(@channel_select, "growx, wrap")
    
    @layout_select = JComboBox.new(@app.layouts.to_java)
    @layout_select.focusable = false
    @layout_select.addActionListener(self)
    form_panel.add(JLabel.new("Layout"))
    form_panel.add(@layout_select, "growx, wrap")
  
    @instrument_select = JComboBox.new(@app.loaded_instruments)
    @instrument_select.focusable = false
    @instrument_select.addActionListener(self)
    form_panel.add(JLabel.new("Instrument"))
    form_panel.add(@instrument_select, "growx, wrap")
  
    @offset_spinner = JSpinner.new
    @offset_spinner.focusable = false
    @offset_spinner.editor.textField.focusable = false
    @offset_spinner.addChangeListener(self)
    form_panel.add(JLabel.new("Octave"))
    form_panel.add(@offset_spinner, "growx, wrap")
    return form_panel
  end
  
  def octave_up
    @pitch_offset += 12
    offset_octaves_changed
  end
  
  def octave_down
    @pitch_offset -= 12
    offset_octaves_changed
  end
  
  def pitch_for(key)
    @current_layout.call(key) + @pitch_offset
  end
  
  def actionPerformed(event)
    if event.source == @channel_select
      @current_channel = @channel_select.selectedItem
    elsif event.source == @layout_select
      @current_layout = @layout_select.selectedItem
      current_layout_changed
    elsif event.source == @instrument_select
      sync_channel_program
    end
  end
  
  def stateChanged(event)
    if event.source == @offset_spinner
      @pitch_offset = @offset_spinner.value
      offset_octaves_changed
    end
  end
  
  def offset_octaves_changed
    @offset_spinner.value = @pitch_offset
    @app.keyboard.repaint
  end
  
  def current_layout_changed
    @app.keyboard.repaint
  end

  def sync_channel_program
    instrument = @instrument_select.selectedItem
    @current_channel.programChange(instrument.patch.bank, instrument.patch.program)
  end
end

class PlayedNote
  attr_accessor :keyboard, :pitch
  def initialize(keyboard, pitch)
    @keyboard = keyboard
    @pitch = pitch
  end
  
  def name
    octave = @pitch / 12
    note_interval = @pitch % 12
    note = NoteLayouts::NOTE_INTERVALS_INVERTED[note_interval]
    return "#{note.upcase}#{octave}"
  end
end

class App
  include java.awt.event.WindowListener
  include java.awt.event.KeyListener
  include java.awt.event.ActionListener
  include java.awt.event.MouseWheelListener
  attr_accessor :current_notes, :channels, :layouts
  attr_accessor :loaded_instruments, :keyboard, :key_mapper, :split_keyboard
  def initialize
    @layouts = NoteLayouts::ALL.map{|c|c.new}
      
    @split_keyboard = false
    
    @current_notes = {}
    @last_wheel_moved = nil
    
    @amplitude = 0
    
    @key_mapper = KeyMapper::Mapper.new(KeyMapper::QWERTY)
    
    @wind_mode = true
    
    @volume = 65
    
    initialize_synth
    
    @first_keyboard = KeyboardSection.new("Left Hand", self, @channels[0])
    @second_keyboard = KeyboardSection.new("Right Hand", self, @channels[1])
    initialize_frame
    track_microphone_amplitude
  end

  def track_microphone_amplitude
    avg_window_size = 20
    avg_window = [0] * avg_window_size
    @microphone_thread = Thread.new do
      format = AudioFormat.new(8000.0, 8, 1, true, false)
      data_line_info = DataLineInfo.new(TargetDataLine.java_class, format)
      data_line = AudioSystem.getLine(data_line_info)
      data_line.open
      data_line.start
      array_size = 15
      bytes = Array.java_array :byte, array_size
      while true
        begin
          if @wind_mode
            bytes_read = data_line.read(bytes, 0, array_size)
            value = bytes.map{|b|b.abs}.avg
            avg_window = avg_window[1..avg_window_size-1] + [value]
            @amplitude = avg_window.avg
            amplitude_changed
          else
            amp = 90
            if @amplitude != amp
              @amplitude = amp
              amplitude_changed
            end
          end
        rescue => e
          puts e
        end
      end
    end
  end 
  
  def keyboards
    [@first_keyboard, @second_keyboard]
  end
  
  def blow_threshold
    65
  end
  
  def amplitude_changed
    #puts "amplitude: #{@amplitude}"
    @volume = Math.log(@amplitude) / 4 * 127
    
    #@amplitude_label.text = @volume.to_s
    if @wind_mode
      if @volume == 0
        keyboards.each do |kb|
          kb.current_channel.allNotesOff
        end
        current_notes.keys.each do |key|
          current_notes[key] = nil
        end
      elsif @volume >= blow_threshold
        changed = false
        current_notes.each do |key, note|
          if note.nil?
            note = note_for_key(key_mapper.key(key))
            #puts "playing #{note}"
            current_notes[key] = note
            changed = true
            note.keyboard.current_channel.noteOn(note.pitch, velocity)
          end
        end
        current_notes_changed if changed
      end
    end
    #puts "volume: #{volume}"
    sync_volume
  end
  
  def pedal_down
    keyboards.each do |kb|
      kb.current_channel.controlChange(64, 127)
    end
  end
  
  def pedal_up
    keyboards.each do |kb|
      kb.current_channel.controlChange(64, 0)
    end
  end
  
  def sync_volume
    keyboards.each do |kb|
      kb.current_channel.controlChange(7, @volume)
    end
  end
  
  def all_notes_off
    @current_notes = {}
    keyboards.each do |kb|
      kb.current_channel.allNotesOff
    end
  end
  
  def initialize_frame
    @frame = JFrame.new('Musical Keys')
    @frame.defaultCloseOperation = JFrame::EXIT_ON_CLOSE
    @frame.addWindowListener(self)
    
    @frame.addKeyListener(self)
    @frame.addMouseWheelListener(self)
    panel = JPanel.new
    panel.layout = BorderLayout.new
      controls_panel = JPanel.new
      controls_panel.layout = GridLayout.new(1,2)
      
        controls_panel.add(@first_keyboard.create_controls)
        controls_panel.add(@second_keyboard.create_controls)
      
      panel.add(controls_panel, BorderLayout::NORTH)
      
      @keyboard = KeyboardDisplay.new(self)
      panel.add(@keyboard, BorderLayout::CENTER)
      
      
      bottom_panel = JPanel.new
        @split_keyboard_cb = JCheckBox.new
        @split_keyboard_cb.focusable = false
        @split_keyboard_cb.selected = @split_keyboard
        bottom_panel.add(JLabel.new("Split Keyboard?"))
        bottom_panel.add(@split_keyboard_cb)
        @split_keyboard_cb.addActionListener(self)
        
        @wind_mode_cb = JCheckBox.new
        @wind_mode_cb.focusable = false
        @wind_mode_cb.selected = @wind_mode
        bottom_panel.add(JLabel.new("Wind Mode?"))
        bottom_panel.add(@wind_mode_cb)
        @wind_mode_cb.addActionListener(self)
        
        @amplitude_label = JLabel.new
        bottom_panel.add(@amplitude_label)
        
      panel.add(bottom_panel, BorderLayout::SOUTH)
      
    @frame.add(panel)
    @first_keyboard.offset_octaves_changed
    @second_keyboard.offset_octaves_changed
    current_notes_changed
    @first_keyboard.sync_channel_program
    @second_keyboard.sync_channel_program
    @frame.pack()
    @frame.setLocationRelativeTo(nil)
    @frame.show()
  end
  
  def initialize_synth
    @synth = javax.sound.midi.MidiSystem.synthesizer
    @synth.open
    @soundbank = @synth.defaultSoundbank
    @synth.loadAllInstruments(@soundbank)
    @loaded_instruments = @synth.loadedInstruments
    @channels = @synth.channels.enum_for(:each_with_index).map{|c, i| MidiChannel.new(c, i)}
  end
  
  def main_keyboard
    @split_keyboard ? @second_keyboard : @first_keyboard
  end
  
  def octave_up
    main_keyboard.octave_up
  end
  
  def octave_down
    main_keyboard.octave_down
  end
  
  def actionPerformed(event)
    if event.source == @split_keyboard_cb
      @split_keyboard = @split_keyboard_cb.selected
      split_keyboard_changed
    elsif event.source == @wind_mode_cb
      @wind_mode = @wind_mode_cb.selected
      wind_mode_changed
    end
  end
  
  def wind_mode_changed
  end
  
  def split_keyboard_changed
    @keyboard.repaint
  end
  
  def mouseWheelMoved(event)
    now = Time.now
    if @last_wheel_moved.nil? or (now - @last_wheel_moved > 0.2)
      if event.unitsToScroll > 0
        octave_down
      else
        octave_up
      end
    end
    @last_wheel_moved = now
  end
  
  def windowActivated(event);end
  def windowClosed(event);end
  def windowClosing(event);end
  def windowDeiconified(event);end
  def windowIconified(event);end
  def windowOpened(event);end
  
  def windowDeactivated(event)
    all_notes_off
  end
  
  def current_notes_changed
    @keyboard.repaint
  end
  
  def left_hand?(key)
    return key.row >= 2 ? key.col <= 6 : key.col <= 5
  end
  
  def note_for_key(key)
    keyboard = @split_keyboard ?
      (left_hand?(key) ? @first_keyboard : @second_keyboard) :
      @first_keyboard
    pitch = keyboard.pitch_for(key)
    return PlayedNote.new(keyboard, pitch)
  end
  
  def velocity
    65
  end
  
  def keyPressed(event)
    key_code = event.getKeyCode
    if key_code == 38 # up arrow
      octave_up
    elsif key_code == 40 # down arrow
      octave_down
    elsif key_code == 32 #space
      pedal_down
    else
      key = key_mapper.key_for_event(event)
      note = note_for_key(key)
      return if note.nil?
      if not @current_notes.include?(key.symbol)
        if @wind_mode
          if @volume >= blow_threshold
            @current_notes[key.symbol] = note
          else
            @current_notes[key.symbol] = nil
          end
        else
          @current_notes[key.symbol] = note
        end
        current_notes_changed
        if @current_notes[key.symbol]
          note.keyboard.current_channel.noteOn(note.pitch, velocity)
        end  
      end
    end
  end
  
  def keyReleased(event)
    key_code = event.getKeyCode
    if key_code == 32
      pedal_up
    end
    key = key_mapper.key_for_event(event)
    return if not @current_notes.include?(key.symbol)
    note = @current_notes[key.symbol]
    @current_notes.delete(key.symbol)
    current_notes_changed
    note.keyboard.current_channel.noteOff(note.pitch, velocity) if note
  end
  
  def keyTyped(event);end
end

App.new
