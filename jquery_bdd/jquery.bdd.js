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
        var sp = spec.clone
		var testCase = spec.tests[caseName];
        if (testCase.ishelper) continue;
		try{
			if (spec.beforeEach) spec.beforeEach();
			testCase.apply(spec);
			if (spec.afterEach) spec.afterEach();
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
$.setupShouldHelpers = function(){
    Number.prototype.shouldEqual = function(other){
        if (this != other) throw new Error(this + " is not equal to " + other + ". Called by " + arguments.caller);
    }
    Number.prototype.shouldEqual.ishelper = true;
    Date.prototype.shouldEqual = function(other){
        if (this.getTime() != other.getTime()) throw new Error(this + ' is not equal to ' + other);
    }
    Date.prototype.shouldEqual.ishelper = true;
}
$.specOutput = console ? console.log: function(){};
$.runSpecs = function(){
    $.setupShouldHelpers();
	var specs = $.specs();
	for (var i = 0; i < specs.length; i++){
		var spec = specs[i];
		var res = $.runSpec(spec);
        with({print: $.specOutput}){
            print('Ran ' + res.total + ' specs.');
            print(res.fail + ' failures.');
        }
	}
}