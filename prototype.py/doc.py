"""
# create a new type using @constructor
>>> from prototype import *
>>> @constructor
... def Person(this, first, last):
...   this.firstName = first
...   this.lastName = last
...
>>> Person
<class 'prototype.Person'>

# initialize an instance
>>> bird = Person('Charlie', 'Parker')
>>> bird.firstName
'Charlie'
>>> bird.lastName
'Parker'

# dynamically add methods
>>> def sing(this):
...   print '%s sings!!' % this.lastName
...
>>> bird.sing = sing
>>> bird.sing()
Parker sings!!

# use the prototype chain to add properties and methods to the type
>>> def getName(this):
...   return '%s %s' % (this.firstName, this.lastName)
...
>>> Person.prototype.name = property(getName)
>>> bird.name
'Charlie Parker'
>>> def greet(this):
...   print 'Hello, my name is %s' % this.name
...
>>> Person.prototype.greet = greet
>>> bird.greet()
Hello, my name is Charlie Parker
>>> monk = Person('Thelonious', 'Monk')
>>> monk.greet()
Hello, my name is Thelonious Monk

# using prototype inheritence
>>> father = Person('Tom', 'Bard')
>>> son = Person('Tommy', 'Bard')
>>> son.__proto__ = father
>>> father.eyeColor = 'blue'
>>> son.eyeColor
'blue'

# prototype chain relationships
assert son.__proto__ == father
assert son.constructor == father.constructor == Person
assert father.__proto__ == Person.prototype
assert Object.prototype.constructor == Object
assert Person.prototype.constructor == Person
assert Person.prototype.__proto__ == Object.prototype
"""
if __name__ == "__main__":
    import doctest
    doctest.testmod()