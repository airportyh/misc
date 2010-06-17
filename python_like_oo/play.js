var sys = require('sys')

function toArray(args){
  var ret = []
  for (var i = 0; i < args.length; i++)
    ret.push(args[i])
  return ret
}

function Class(parent){
  function bind(func, obj){
    var ret = function(){
      var args = toArray(arguments)
      args.splice(0, 0, obj)
      //sys.puts('args: ' + args.join(','))
      return func.apply(undefined, args)
    }
    return ret
  }
  
  return function(attrs){
    return function(){
      for (var name in attrs){
        var value = attrs[name]
        if (typeof(value) == 'function'){
          this[name] = bind(value, this)
          this[name].name = name
        }else{
          this[name] = value
        }
      }
      this.__init__.apply(this, arguments)
    }
  }
}

var Man = Class(Object)({
	__init__: function(self, name){
		self.name = name
	},
	greeting: function(self, other){
	  //sys.puts('self: ' + self.name)
	  setTimeout(function(){
	    self.say("Hello, " + other.name + ", my name is " + self.name)
	  }, 100)
		
	},
	say: function(self, msg){
		sys.puts(msg)
	}
})

var dan = new Man('Dan')
var john = new Man('John')
dan.greeting(john)
john.say('How do?')
