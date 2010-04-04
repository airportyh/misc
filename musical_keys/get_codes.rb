require 'java'
JFrame = javax.swing.JFrame
KeyEvent = java.awt.event.KeyEvent
class App
  include java.awt.event.KeyListener
  
  def initialize
    print '['
    frame = JFrame.new('Get Codes')
    frame.addKeyListener(self)
    frame.show()
  end
  
  def keyName(code)
    name = KeyEvent.constants.select{|c| c.index('VK_') == 0}.find{|vk| code == KeyEvent.const_get(vk)}
    return name[3..name.size] if name
  end
  
  def keyChar(char)
    if (char == 65535) then nil
    else char.chr.upcase
    end
  end
  
  def keyRepr(event)
    name = keyName(event.getKeyCode)
    char = keyChar(event.getKeyChar)
    if char and char > ' ' then char
    else name
    end
  end
  
  def keyPressed(event)
    if event.getKeyCode == 10
      print "]\n["
    else
      print "'#{keyRepr(event)}', "
    end
    
  end
  
  def keyReleased(event)
  end
  
  def keyTyped(event);end
  
end

App.new
