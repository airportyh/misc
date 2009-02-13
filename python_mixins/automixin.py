class Meta(type):
    def __new__(cls, name, bases, dct):
        helper_mixin = globals().get('%sHelper' % name)
        if helper_mixin:
            bases = list(bases)
            bases.append(helper_mixin)
            return type.__new__(cls, name, tuple(bases), dct)
        else:
            return type.__new__(cls, name, bases, dct)
        
class Controller(object):
    __metaclass__ = Meta
        
class ProductControllerHelper(object):
    def method1(self):
        print "method1 invoked"
        
class ProductController(Controller):
    def index(self):
        self.method1()
        
class Meta2(type):
    def __new__(cls, name, bases, dct):
        mixins = []
        all = dct.get('all')
        if all:
            mixins.extend(all)
        each = dct.get('each')
        if each:
            mixins.extend(each)
        bases = list(bases)
        bases.extend(mixins)
        return type.__new__(cls, name, tuple(bases), dct)
        
class TestCase(object):
    __metaclass__ = Meta2
    
class Fixture1(object):
    def method2(self):
        print "method2 invoked"
    
class Fixture2(object):
    def method3(self):
        print "method3 invoked"
        
class BlahBlahTest(TestCase):
    all = [Fixture1]
    each = [Fixture2]
    def blah_test(self):
        self.method2()
        self.method3()
        
if __name__ == '__main__':
    ProductController().index()
    BlahBlahTest().blah_test()