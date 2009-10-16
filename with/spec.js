describe('with')
  .beforeEach(function(){
    this.name = 'Houston'
    this.age = 18
    this.eyes = null
    this.lips = undefined
    window.name = "window's name"
  })
  .should('get attr', function(){
    with(this){
      expect(name).toBe('Houston')
      expect(age).toBe(18)
      expect(eyes).toBe(null)
      expect(lips).toBe(undefined)
    }
  })
  .should('raise if doesn\'t exist', function(){
    with(this){
      expect(function(){namee}).toRaise()
      this.namee // but write "this." and doesn't raise
    }
  })
  .should('reference variable from outside with scope', function(){
    var hair = 'dark'
    with(this){
      expect(hair).toBe('dark')
    }
  })
  .should('do assignment', function(){
    with(this){
      name = 'Kenny'
    }
    expect(this.name).toBe('Kenny')
  })
  .should('not do assignment if attr does exist yet', function(){
    /*
    when you make an assignment to an attribute of the object in 
    question(the one you are working *with*), that attribute must 
    already exist(been assigned some value), otherwise, it will 
    behave like it would outside the with scope and assign the 
    attribute to the window object.
    */
    with(this){
      hair = 'dark'
    }
    expect(this.hair).toBe(undefined)
    expect(hair).toBe('dark')
    expect(window.hair).toBe('dark')
  })
  .should('do assignment if attr is defined to be undefined', function(){
    /*
    I had always thought that assigning undefined to an attribute 
    is the same as it having never been assigned a value at all. 
    I was wrong. But deleting the attribute will revert it to the 
    state of non-existence, as the next test shows.
    */
    with(this){
      lips = 'pink'
    }
    expect(this.lips).toBe('pink')
  })
  .should('not do assignment if attr has been ' +
    'deleted(deleting makes it "not exist")', function(){
    /*
    Deleting the attribute will revert it to the 
    state of non-existence, which makes unassignable from within
    the 'with' scope again
    */
    delete this.name
    with(this){
      name = 'tony' // this sets window.name to 'tony'
    }
    expect(this.name).toBe(undefined)
    expect(window.name).toBe('tony')
  })
  .should('delete', function(){
    with(this){
      delete name
    }
    expect(this.name).toBe(undefined)
  })
  .should('deleting makes the attribute non-existant, and you are' +
    'again accessing window\'s attrs', function(){
    with(this){
      expect(name).toBe('Houston')
      delete name
      expect(name).toBe("window's name")
    }
  })
  .should('be silent if deleting non-existing attr', function(){
    with(this){
      delete hands
    }
    expect(this.hands).toBe(undefined)
  })
  .should('do assignment if attr is null', function(){
    with(this){
      eyes = 'brown'
    }
    expect(this.eyes).toBe('brown')
  })
  .should('do assignment using this. if attr does not exist', function(){
    with(this){
      this.hair = 'dark'
    }
    expect(this.hair).toBe('dark')
  })
  .should('var outside with scope does not override', function(){
    /*
    variables defined outside the with scope has lower precedence 
    than attributes of the object in question.
    */
    var name = 'Jen'
    with(this){
      expect(name).toBe('Houston')
    }
  })
  .should('var outside with scope does not override (2)', function(){
    this.window = 'Not window'
    with(this){
      expect(window).toBe('Not window')
    }
  })
  .should('var inside scope overrides attribute', function(){
    with(this){
      var name = 'Jen' // this has the same effect as: name = 'Jen'
      expect(name).toBe('Jen')
    }
    expect(this.name).toBe('Jen')
  })
  .should('have no lexical scoping', function(){
    var instrument = 'sax'
    with(this){
      var instrument = 'trumpet'
      expect(instrument).toBe('trumpet')
    }
    expect(instrument).toBe('trumpet')
  })
  .should('reset vars after the with scope closes', function(){
    var name = 'blah'
    with(this){
      expect(name).toBe('Houston')
    }
    expect(name).toBe('blah')
  })
  
describe('javascript')
  .should('raise if var does\'t exist', function(){
    expect(function(){namee}).toRaise()
  })
  .should('not raise if used within typeof', function(){
    expect(typeof namee).toBe('undefined')
  })
  .should('no raise if accessing non-existing attr', function(){
    expect(this.name).toBe(undefined)
  })
  .should('not delete variable', function(){
    var name = 'tony'
    expect(name).toBe('tony')
    delete name
    expect(name).toBe('tony')
  })
  .should('be in if defined to be undefined', function(){
      var obj = {}
      obj.attr = undefined
      expect('attr' in obj).toBe(true)
  })