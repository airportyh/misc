class Deferred(object):
    def __init__(self, f):
        self.callback = f

def run(f):
    gen = f()
    value = gen.next()
    def callback(value):
        gen.send(value)
    if isinstance(value, Deferred):
        value.callback = callback
    else:
        gen.next()
        
def do_stuff():
    
    
    