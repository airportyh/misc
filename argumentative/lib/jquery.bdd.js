$.specs = function(){
	var specs = $(document).data('specs');
	if (!specs){
		specs = [];
		$(document).data('specs', specs);
	}
	return specs;
}
$.describe = function(name){
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
	Spec.prototype.it = function(name, testFunc){
		this.tests['it ' + name] = testFunc;
		return this;
	}
	Spec.prototype.should = function(name, testFunc){
		this.tests['should ' + name] = testFunc;
		return this;
	}
	var spec = new Spec(name);
	$.specs().push(spec);
	return spec;
}
$.runSpec = function(spec){
	var totalRan = 0;
	var failures = 0;
	if (spec.beforeAll) spec.beforeAll();
	for (var caseName in spec.tests){
        var sp = spec.clone;
        var context = {};
		var testCase = spec.tests[caseName];
		try{
			if (spec.beforeEach) spec.beforeEach.apply(context);
			testCase.apply(context);
			if (spec.afterEach) spec.afterEach.apply(context);
		}catch(e){
            with({print: $.specOutput}){
                print(spec.name + ' ' + caseName + ':');
                print("\t" + e);
            }
			failures++;
		}
		totalRan++;
	}
	if (spec.afterAll) spec.afterAll();
	return {total: totalRan, fail: failures};
}
$.test = function(one){
    return {
        shouldEqual: function(other){
            if ((one && one.constructor == Date) && (other && other.constructor == Date)){
                one = one.getTime();
                other = other.getTime();
            }
            if ((one && one.constructor == Array) && (other && other.constructor == Array)){
                if (one.length != other.length) throw new Error(one + " is not equal to " + other);
                for (var i = 0; i < one.length; i++)
                    if (one[i] != other[i])
                        throw new Error(one + " is not equal to " + other);
                return;
            }
            if (one != other) throw new Error(one + " is not equal to " + other);
        },
        shouldBeTrue: function(){
            if (!one) throw new Error("Assertion failed.");
        },
        fail: function(reason){
            throw new Error(reason || 'Failed');
        },
        shouldRaise: function(msg){
          var through = false;
          try{
            one();
            through = true;
            throw new Error("Should have raised: " + msg);
          }catch(e){
            if (through) throw e;
            else $t(e.message).shouldEqual(msg);
          }
        }
    };
}
$.t = $.test;
$t = $.test;
$.specOutput = function(){};
$.runSpecs = function(){
	var specs = $.specs();
	for (var i = 0; i < specs.length; i++){
		var spec = specs[i];
		var res = $.runSpec(spec);
        with({print: $.specOutput}){
            print('Ran ' + res.total + ' specs for ' + spec.name + '.');
            print(res.fail + ' failures.');
        }
	}
}