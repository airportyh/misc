module NoteLayouts
  BASE = 48
  
  NOTE_INTERVALS = {
    'c' => 0,
    'c#' => 1,
    'd' => 2,
    'd#' => 3,
    'e' => 4,
    'f' => 5,
    'f#' => 6,
    'g' => 7,
    'g#' => 8,
    'a' => 9,
    'a#' => 10,
    'b' => 11
  }
  
  NOTE_INTERVALS_INVERTED = NOTE_INTERVALS.invert
  
  class ChromaticLayout
    def to_s
      "Chromatic"
    end
  
    def call(key)
      BASE + key.row * 5 + key.col
    end
  end

  ALL = [ChromaticLayout]

  def char_pos(k)
    ret = nil
    $keyboard.each_with_index do |row, r|
      row.each_with_index do |key, c|
        if key == k.chr.downcase then
          ret = [r, c]
        end
      end
    end
    return ret
  end

  def note_to_pitch(sym)
    return nil if sym.nil?
    s = sym.to_s
    octave = s[-1].chr.to_i
    note = s[0..-2]
    return octave * 12 + $note_intervals[note]
  end
  
  #class WholeToneLayout
  #  def to_s
  #    "Whole Tone"
  #  end
  #  
  #  def call(k)
  #    ret = nil
  #    $keyboard.each_with_index do |row, r|
  #      row.each_with_index do |key, c|
  #        if key == k.chr.downcase then
  #          ret = ($base + r * 5 + (c * 2))
  #        end
  #      end
  #    end
  #    return ret
  #  end
  #end
  #
  #class MappingLayout # abstract
  #  def mapping
  #    raise "mapping not implemented"
  #  end
  #  
  #  def call(k)
  #    ret = nil
  #    $keyboard.each_with_index do |row, r|
  #      row.each_with_index do |key, c|
  #        if key == k.chr.downcase then
  #          ret = note_to_pitch(mapping[r][c])
  #        end
  #      end
  #    end
  #    return ret
  #  end
  #end
  #
  #class LowToHigh
  #  def to_s
  #    "Low-to-high"
  #  end
  #  
  #  def call(k)
  #    ret = nil
  #    $keyboard.each_with_index do |row, r|
  #      row.each_with_index do |key, c|
  #        if key == k.chr.downcase then
  #          ret = $base + c * 4 + r
  #        end
  #      end
  #    end
  #    return ret
  #  end
  #end
  #
  #class ScaleLayout < MappingLayout
  #  def to_s
  #    "Scale"
  #  end
  #  
  #  def mapping
  #    [
  #      [:b4, :cs5, :ds5, :f5, :fs5, :fs5, :fs5, :gs5, :as5, :c6, :cs6, :ds6],
  #      [:c5, :d5, :e5, :f5, :g5, :f5, :g5, :a5, :b5, :c6, :d6, :e6],
  #      [:b3, :cs4, :ds4, :f4, :fs4, :fs4, :fs4, :gs4, :as4, :c5, :cs5],
  #      [:c4, :d4, :e4, :f4, :g4, :f4, :g4, :a4, :b4, :c5]
  #    ].reverse
  #  end
  #  
  #end
  #
  #class MajorScaleLayout < MappingLayout
  #  def to_s
  #    "Major Scale"
  #  end
  #  
  #  def mapping
  #    [
  #      [:c7, :d7, :e7, :f7, :g7, :f7, :g7, :a7, :b7, :c8, :d8, :e8],
  #      [:c6, :d6, :e6, :f6, :g6, :f6, :g6, :a6, :b6, :c7, :d7, :e7],
  #      [:c5, :d5, :e5, :f5, :g5, :f5, :g5, :a5, :b5, :c6, :d6],
  #      [:c4, :d4, :e4, :f4, :g4, :f4, :g4, :a4, :b4, :c5]
  #    ].reverse
  #  end
  #end
  #
  #class PentatonicLayout < MappingLayout
  #  def to_s
  #    "Pentatonic"
  #  end
  #  
  #  def mapping
  #    [
  #      [:e6, :g6, :a6, :c7, :d7, :e7, :g7, :a7, :c8, :d8, :e8, :g8, :a8],
  #      [:g5, :a5, :c6, :d6, :e6, :g6, :a6, :c7, :d7, :e7, :g7, :a7],
  #      [:a4, :c5, :d5, :e5, :g5, :a5, :c6, :d6, :e6, :g6, :a6],
  #      [:c4, :d4, :e4, :g4, :a4, :c5, :d5, :e5, :g5, :a5]
  #    ].reverse
  #  end
  #end


end