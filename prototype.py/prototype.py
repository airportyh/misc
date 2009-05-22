import new
import inspect

def _getattr(obj, name):
    try:
        return object.__getattribute__(obj, name)
    except AttributeError:
        return None

class Object(object):
    prototype = None
    
    def __init__(this):
        this.__proto__ = this.prototype
        this.constructor = this.__class__
    
    def __getattribute__(this, name):
        val = _getattr(this, name) or _getattr(_getattr(this, '__proto__'), name)
        if isinstance(val, property):
            get = new.instancemethod(val.__get__, this)
            return get()
        elif inspect.isfunction(val):
            func = new.instancemethod(val, this)
            return func
        else:
            return val

Object.prototype = Object()

def constructor(func):
    ret = type(func.__name__, (Object,), dict())
    ret.prototype = ret()
    def init(this, *vargs, **kwargs):
        Object.__init__(this)
        func(this, *vargs, **kwargs)
    ret.__init__ = init
    return ret
    
