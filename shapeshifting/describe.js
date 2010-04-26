/*
Copyright (c) 2010, Toby Ho

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

describe = function(name){
	function Spec(name){
		this.name = name;
		this.tests = {}
	}
	Spec.prototype.beforeEach = function(f){
		this.beforeEach = f;
		return this;
	}
	Spec.prototype.before = Spec.prototype.beforeEach;
	Spec.prototype.beforeAll = function(f){
		this.beforeAll = f;
		return this;
	}
	Spec.prototype.afterEach = function(f){
	    this.afterEach = f;
	    return this;
	}
	Spec.prototype.after = Spec.prototype.afterEach;
	Spec.prototype.afterAll = function(f){
	    this.afterAll = f;
	    return this
	}
	Spec.prototype.it = function(name, testFunc){
		this.tests['it ' + name] = testFunc;
		return this;
	}
	Spec.prototype.should = function(name, testFunc){
		this.tests['should ' + name] = testFunc;
		return this;
	}
	var spec = new Spec(name);
	describe.specs.push(spec);
	return spec;
}
describe.specs = [];
describe.runSpec = function(spec, debug){
	var totalRan = 0;
	var failures = 0;
	if (spec.beforeAll) spec.beforeAll();
	for (var caseName in spec.tests){
        var sp = spec.clone;
        var context = {};
		var testCase = spec.tests[caseName];
		function doit(){
			if (spec.beforeEach) spec.beforeEach.apply(context);
			testCase.apply(context);
		}
		if (debug){
		    doit();
		}else{
    		try{
    		    doit();
    		}catch(e){
                with({print: describe.output}){
                    print(spec.name + ' ' + caseName + ':');
                    print("\t" + e);
                }
    			failures++;
    		}
    	}  
		if (spec.afterEach) spec.afterEach.apply(context);
		totalRan++;
	}
	if (spec.afterAll) spec.afterAll();
	return {total: totalRan, fail: failures};
}
expect = function expect(one, context){
    return {
        toEqual: function(other){
            if ((one && one.constructor === Date) && 
                (other && other.constructor === Date)){
                one = one.getTime();
                other = other.getTime();
            }
            if ((one && one.constructor === Array) && 
                (other && other.constructor === Array)){
                if (one.length != other.length) throw new Error(one + " is not equal to " + other);
                for (var i = 0; i < one.length; i++)
                    if (one[i] != other[i])
                        throw new Error(one + " is not equal to " + other);
                return;
            }
            if ((one && one.constructor === Object) && 
                (other && other.constructor === Object)){
              function listRepr(obj){
                var ret = [];
                for (var key in obj){
                  ret.push(key + ':' + obj[key]);
                }
                return ret;
              }
              expect(listRepr(one)).toEqual(listRepr(other));
              return;
            }
            if (one != other) throw new Error(one + " is not equal to " + other);
        },
        toBe: function(other){
            if (one !== other) throw new Error(one + " is not the same object as " + other);
        },
        toRaise: function(msg){
          var through = false;
          try{
            one.apply(context);
            through = true;
            throw new Error("Should have raised: " + msg);
          }catch(e){
            if (through) throw e;
            else if (msg !== undefined) expect(e.message).toEqual(msg);
          }
        }
    };
}

fail = function fail(reason){
    throw new Error(reason || 'Failed');
};
describe.output = function(msg){
  if (console && console.log)
    console.log(msg);
}
describe.outputOnto = function(id){
  describe.output = function(msg){
    function escape(s){
      if (!s || s.length == 0) return s;
      return s.replace(/</g, '&lt;').replace(/>/g, '&gt;')
    }
    document.getElementById(id).innerHTML += escape(msg) + '<br>';
  }
  return describe;
}
describe.run = function(debug){
	var specs = describe.specs;
	for (var i = 0; i < specs.length; i++){
		var spec = specs[i];
		var res = describe.runSpec(spec, debug);
        with({print: describe.output}){
            print('Ran ' + res.total + ' specs for ' + spec.name + '.');
            print(res.fail + ' failures.');
        }
	}
	return describe;
}