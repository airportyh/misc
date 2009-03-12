import unittest
class BrowserTest(unittest.TestCase):
    def setUp(self):
        print("Setting up %s" % self.browser)

def expand_browsers(gls, browsers=['firefox', 'ie6', 'ie7', 'safari']):
    original_test_classes = filter(
        lambda o: isinstance(o, type) and issubclass(o, BrowserTest), 
        gls.values())
    
    for cls in original_test_classes:
        for browser in browsers:
            new_class = type('%sOn%s' % (cls.__name__, browser), (cls,), dict(browser=browser))
            gls[new_class.__name__] = new_class
        del gls[cls.__name__]