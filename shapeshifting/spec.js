require('./describe')
var puts = require('sys').puts

ClosedDoor = {
  isClosed: function(){
    return true
  },
  isOpen: function(){
    return false
  }
}

OpenDoor = {
  isClosed: function(){
    return false
  },
  isOpen: function(){
    return true
  }
}

function Door(){
  this.__proto__ = ClosedDoor
  this.open = function(){
    this.__proto__ = OpenDoor
  }
  this.close = function(){
    this.__proto__ = ClosedDoor
  }
}

describe('Shape-Shifter')
  .should('open door', function(){
    var door = new Door()
    expect(door.isClosed()).toBe(true)
    expect(door.isOpen()).toBe(false)
    door.open()
    expect(door.isClosed()).toBe(false)
    expect(door.isOpen()).toBe(true)
    door.close()
    expect(door.isClosed()).toBe(true)
    expect(door.isOpen()).toBe(false)
  })
  .should('work with separate doors', function(){
    var door1 = new Door()
    var door2 = new Door()
    door1.open()
    expect(door1.isOpen()).toBe(true)
    expect(door2.isOpen()).toBe(false)
  })
  
describe.output = function(msg){
  puts(msg)
}

describe.run()