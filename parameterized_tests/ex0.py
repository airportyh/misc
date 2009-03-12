import unittest

class TestPages(unittest.TestCase):
    def testPage(self):
        print("testing page on %s" % self.browser)

class TestMorePages(unittest.TestCase):
    def testPageTwo(self):
        print("testing page two on %s" % self.browser)

def expand_browsers(gls, browsers=['firefox', 'ie6', 'ie7', 'safari', 'chrome', 'opera']):
    original_test_classes = filter(
        lambda o: isinstance(o, type) and issubclass(o, unittest.TestCase), 
        gls.values())
    
    for cls in original_test_classes:
        for browser in browsers:
            new_class = type('%sOn%s' % (cls.__name__, browser), (cls,), dict(browser=browser))
            gls[new_class.__name__] = new_class
        del gls[cls.__name__]

expand_browsers(globals())

if __name__ == '__main__':
    unittest.main()