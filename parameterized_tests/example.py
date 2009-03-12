import browsertest
        
class TestCustomerPage(browsertest.BrowserTest):
    def testFrontPage(self):
        print("testing front page on %s" % self.browser)
        
class TestUserPage(browsertest.BrowserTest):
    def testFrontPage(self):
        print("testing front page on %s" % self.browser)
        
browsertest.expand_browsers(globals())

if __name__ == '__main__':
    import unittest
    unittest.main()
    