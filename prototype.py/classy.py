from prototype import *

def Class(func):
  attrs = func()
  cls = constructor(attrs['init'])
  del attrs['init']
  cls.__name__ = func.__name__
  for name in attrs.keys():
    setattr(cls.prototype, name, attrs[name])
  return cls
  
@Class
def Show():
  def init(this, title):
    this.title = title
    this.personnel = []
  def addPersonnel(this, person):
    this.personnel.append(person)
  return locals()
  
