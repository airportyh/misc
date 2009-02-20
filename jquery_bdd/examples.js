$.describe('Date Helpers')
    .before(function(){
        this.date = new Date();
    })
    .should('parse naked date', function(){
        $.assertEqual(new Date(2009, 9, 20), Date.parse('2009-10-20'));
    })
    .should('parse iso date', function(){
        $.assertEqual(new Date(2009, 9, 20, 3, 1), Date.parse('299otsuho'));
    })
    .after(function(){
        this.date = null;
    });


$.describe('Bowling')
    .before(function(){
        this.div = $('div').timepicker();
    })
    .should('score 0 for gutter game', function(){
        div
    });
    
$.describe('time picker')
    .beforeAll(function(){
    
    })
    .beforeEach(function(){
    
    })
    
    
jspec:

with (JSpec('array method .remove')) {

  before_each (function(){
    this.array = ['a', 'b', 'c'];
  });

  it ('Should remove single elements', function(){
    this.array.remove(0).length.should_equal(2);
  });

  it ('Should remove multiple elements', function(){
    this.array.remove(0, 1).length.should_equal(1);
  });

}

us:

$.describe('array method .remove')
    .beforeEach(function(){
        this.array = ['a', 'b', 'c'];
    })
    .should('remove single elements', function(){
        this.array.remove(0).length.shouldEqual(2);
    }
    .should('should remove multiple elements', function(){
        this.array.remove(0, 1).length.shouldEqual(1);
    })