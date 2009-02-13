class Meta(type):
    def __init__(cls, name, bases, dct):
        if hasattr(cls, 'classmixins'):
            cmixins = cls.classmixins
            for cm in cmixins:
                for n in dir(cm):
                    v = getattr(cm, n)
                    if hasattr(v, 'im_func'):
                        setattr(cls, n, classmethod(v.im_func))

class MyMixin(object):
    def method1(self):
        print "method1 invoked on %s" % self
        
class MyClass(object):
    __metaclass__ = Meta
    
    classmixins = [MyMixin]
    
if __name__ == '__main__':
    MyClass.method1()