module PhysicalKeyboards
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
  
  #  KeyMapper maps a KeyEvent to a human readable key symbol
  class KeyMapper
    def initialize
      create_code_map
    end

    def create_code_map
      @map = {}
      KeyEvent.constants.select{|c| c.index('VK_') == 0}.each do |const|
        name = const[3..name.size]
        @map[name] = KeyEvent.const_get(const)
      end
    end

    def key_name(code)
      @map[code]
    end

    def key_char(char)
      if (char == 65535) then nil
      else char.chr.upcase
      end
    end

    def event_to_key(event)
      name = key_name(event.getKeyCode)
      char = key_char(event.getKeyChar)
      char and char > ' ' ? char : name
    end
  end
end