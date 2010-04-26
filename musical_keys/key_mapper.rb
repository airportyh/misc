require 'java'
KeyEvent = java.awt.event.KeyEvent
module KeyMapper
  QWERTY =[
    ['ESCAPE', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12' ],
    ['`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 'BACK_SPACE' ],
    ['TAB', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', '\\' ],
    ['CAPS_LOCK', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', '\'', 'ENTER' ],
    ['SHIFT', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', 'SHIFT' ]  
  ]

  DVORAK = [
    ['ESCAPE', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12' ],
    ['`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '[', ']', 'BACK_SPACE' ],
    ['TAB', '\'', ',', '.', 'P', 'Y', 'F', 'G', 'C', 'R', 'L', '/', '=', '\\' ],
    ['CAPS_LOCK', 'A', 'O', 'E', 'U', 'I', 'D', 'H', 'T', 'N', 'S', '-', 'ENTER' ],
    ['SHIFT', ';', 'Q', 'J', 'K', 'X', 'B', 'M', 'W', 'V', 'Z', 'SHIFT' ]
  ]
  
  SHIFT_MAP = {
    '<' => ',',
    '>' => '.',
    '"' => "'",
    '~' => '`',
    '{' => '[',
    '}' => ']',
    '?' => '/',
    '+' => '=',
    '_' => '-',
    '|' => '\\',
    ':' => ';'
  }
  
  #DVORAK = [
  #  ['ESCAPE', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12' ],
  #  ['`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '[', ']', 'BACK_SPACE' ],
  #  ['\'', ',', '.', 'P', 'Y', 'F', 'G', 'C', 'R', 'L', '/', '=', '\\' ],
  #  ['A', 'O', 'E', 'U', 'I', 'D', 'H', 'T', 'N', 'S', '-', 'ENTER' ],
  #  [';', 'Q', 'J', 'K', 'X', 'B', 'M', 'W', 'V', 'Z', ]
  #]
  
  class Key
    attr_accessor :symbol, :row, :col
    def initialize(symbol, row, col)
      @symbol = symbol
      @row = row
      @col = col
    end
    
    def to_s
      @symbol
    end
  end
  
  #  KeyMapper maps a KeyEvent to a human readable key symbol
  class Mapper
    attr_accessor :keyboard
    def initialize(keyboard)
      @keyboard = keyboard
      create_code_map
      create_keyboard_map
    end

    def create_code_map
      @code_map = {}
      KeyEvent.constants.select{|c| c.index('VK_') == 0}.each do |const|
        name = const[3..const.size]
        @code_map[KeyEvent.const_get(const)] = name
      end
    end
    
    def create_keyboard_map
      @keyboard_map = {}
      @keyboard.each_with_index do |row, i|
        row.each_with_index do |key, j|
          @keyboard_map[key] = Key.new(key, @keyboard.size - i, j)
        end
      end
    end

    def key_name(code)
      @code_map[code]
    end

    def shift(chr)
      if SHIFT_MAP.has_key?(chr)
        return SHIFT_MAP[chr]
      else
        return chr.upcase
      end
    end

    def key_char(char)
      if (char == 65535) then nil
      else shift(char.chr)
      end
    end

    def key(key)
      @keyboard_map[key]
    end

    def key_code_for_event(event)
      name = key_name(event.getKeyCode)
      char = key_char(event.getKeyChar)
      (char and char > ' ') ? char : name
    end
    
    def key_for_event(event)
      code = key_code_for_event(event)
      key(code)
    end
    
  end
end