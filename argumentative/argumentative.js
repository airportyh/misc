/* ============= String utilities ========================= */
function strip(s) {
  return s.replace(/^\s*|\s*$/g, "");
}
function singleQuote(str){
  return "'" + str + "'";
}
/* ============= End of String utilities ================== */
/* =========== Collection utility functions w/o modifying the core types ===== */

Map = {
  size: function(map){
    var size = 0;
    for (var key in map) size++;
    return size;
  },
  keys: function(map){
    var keys = [];
    Map.iter(map, function(key){ keys.push(key); });
    return keys;
  },
  hasKey: function(map, key){
    var ret = false;
    Map.iter(map, function(k){
      if (k == key) ret = true;
    });
    return ret;
  },
  values: function(map){
    var vals = [];
    Map.iter(map, function(key, val){ vals.push(val); });
    return vals;
  },
  iter: function(map, itr){
    for (var key in map) itr(key, map[key]);
  },
  items: function(map){
    var items = [];
    Map.iter(map, function(key, value){
      items.push([key, value]);
    });
    return items;
  }
}

function find(list, match){
  return list.reduce(function(cur, item){
    return match(item) ? item : cur;
  }, null);
}

function remove(list, item){
  var index = list.indexOf(item);
  if (index < 0) return;
  list.splice(index, 1);
}

function last(list){
  if (list.length == 0) return null;
  return list[list.length - 1];
}

/* ============ End of collection utility functions ======================= */
/* ============ Helper functions for displaying english sentences ========= */
function listInEnglish(list){
  if (list.length == 1)
    return list[0];
  else{
    return list.slice(0, list.length - 1).join(', ') + 
      ' and ' + 
      list[list.length - 1];
  }
}

$.describe('listInEnglish')
  .should('say single thing', function(){
   $t(listInEnglish([1])).shouldEqual("1")
  })
  .should('say and with 2', function(){
    $t(listInEnglish(['one','two'])).shouldEqual("one and two")
  })
  .should('comma separate with and at the end for more', function(){
    $t(listInEnglish(['one', 'two', 'three'])).shouldEqual("one, two and three")
  })

noun = $f(
  {plural: null},
  function noun(word, count, plural){
  if (Math.abs(count) <= 1) return word;
  else return plural ? plural : word + 's';
})

$.describe(noun)
  .should('do singular', function(){
    $t(noun('thing', 1)).shouldEqual('thing');
  })
  .should('do plural', function(){
    $t(noun('thing', 2)).shouldEqual('things');
  })
  .should('do explicit plural', function(){
    $t(noun('person', 2, {plural: 'people'})).shouldEqual('people');
  })
/* =============== End Helper functions for English =================== */  

/* =============== Helper functions for $f ============================ */
function parseFunc(f){
  var m = f.toString().match(/function[ \t\n]*([^\(]*)\((.*?)\).*/);
  var name = m[1] || null;
  var allArgs = m[2] == '' ? 
    [] : 
    (m[2].split(',')
    .map(function(arg){ 
      return strip(arg);
    }));
  var vargs = find(allArgs, isVargs);
  var kwargs = find(allArgs, isKwargs);
  var args = allArgs
    .filter(function(arg){ 
      return arg != vargs && arg != kwargs;
    })
    
  return {name: name, args: args, vargs: vargs, kwargs: kwargs, allArgs: allArgs};
}


$.describe('parseFunc')
  .should('parse function with two args', function(){
    function f(a, b){}
    $t(parseFunc(f).args.length).shouldEqual(2);
  })
  .should('parse function name', function(){
    function f(a, b){}
    $t(parseFunc(f).name).shouldEqual('f');
  })
  .should('parse function with one arg', function(){
    function h(a){}
    $t(parseFunc(h).args.length).shouldEqual(1);
  })
  .should('parse function with no args', function(){
    function i(){}
    $t(parseFunc(i).args.length).shouldEqual(0);
  })
  .should('parse function with no args (2)', function(){
    $t(parseFunc(function greet(){ console.log('hello');}).args.length)
      .shouldEqual(0);
  })
  .should('parse anonymous function', function(){
    $t(parseFunc(function(a){}).name).shouldEqual(null);
    $t(parseFunc(function(a){}).args.length).shouldEqual(1);
  })
  .should('parse vargs', function(){
    $t(parseFunc(function($vargs){}).vargs).shouldEqual('$vargs');
  })
  .should('parse kwargs', function(){
    $t(parseFunc(function($$kwargs){}).kwargs).shouldEqual('$$kwargs');
  })
  .should('give allArgs which includes vargs and kwargs', function(){
    $t(parseFunc(function($$kwargs, $vargs){}).allArgs).shouldEqual(['$$kwargs', '$vargs'])
  })


function displayFunc(f){
  var args;
  if (f.optionals)
    args = f.args.map(function(arg){
      var optVal = f.optionals[arg];
      if (optVal !== undefined)
        return arg + '=' + optVal;
      else
        return arg;
    }).join(', ');
  else
    args = f.args.join(', ');
  args = '(' + args + ')';
  if (f.name)
    return 'function ' + f.name + args;
  else
    return 'function' + args;
}

function displayArgs(args){
  var arr = [];
  for (var i = 0; i < args.length; i++)
    arr.push(args[i]);
  return '(' + arr.join(', ') + ')';
}

function isVargs(argName){
  if (!argName) return false;
  return argName.match(/^\$[a-zA-Z0-9]+$/) != null;
}

function isKwargs(argName){
  if (!argName) return false;
  return argName.match(/^\$\$[a-zA-Z0-9]+$/) != null;
}

function processArgs(func, args){
  var argMap = {};
  var vargs = [];
  var kwargs = {};
  var lastFuncArg = last(func.args);
  for (var i = 0; i < args.length; i++){
    var arg = args[i];
    if (arg && 
        arg.constructor == Object && 
        i == args.length - 1){
      // This is a keyword hash
      for (var key in arg){
        var val = arg[key];
        if (func.args.indexOf(key) < 0){
          kwargs[key] = val;
        }else if (argMap[key] !== undefined){
          throw new Error("Multiple definitions of argument '" + key + "' of " + displayFunc(func) + ', first as ' + argMap[key] + ', then as ' + arg[key] + '.');
        }
        argMap[key] = val;
      }
    }else{
      var funcArg = func.args[i];
      if (funcArg === undefined)
        vargs.push(arg);
      else
        argMap[funcArg] = arg;
    }
  }
  if (func.kwargs){
    argMap[func.kwargs] = kwargs;
  }else{
    if (Map.size(kwargs) > 0){
      var keys = Map.keys(kwargs);
      throw new Error("Unexpected " + noun('argument', keys.length) + " " + listInEnglish(keys.map(singleQuote)) + " for " + displayFunc(func) + '.');
    }
  }
  if (func.vargs){
    argMap[func.vargs] = vargs;
  }else{
    if (vargs.length > 0){
      throw new Error(displayFunc(func) + ' expected ' + func.args.length +
        ' arguments but got ' + args.length + ': ' + displayArgs(args) + '.');
    }
  }
  var ret = [];
  for (var i = 0; i < func.allArgs.length; i++){
    var argName = func.allArgs[i];
    var val;
    if (!Map.hasKey(argMap, argName)){
      if (Map.hasKey(func.optionals, argName))
        val = func.optionals[argName];
      else
        throw new Error("Argument '" + argName + "' of " + displayFunc(func) + " was not specified.");
    }else
      val = argMap[argName];
    ret.push(val);    
  }
  return ret;
}

function $f(){
  var f, optionals;
  if (arguments[0].constructor === Function)
    f = arguments[0];
  if (arguments[0].constructor === Object){
    optionals = arguments[0];
    f = arguments[1];
  }
  if (arguments[0].constructor === Array){
    optionals = {};
    arguments[0].forEach(function(key){
      optionals[key] = undefined;
    });
    f = arguments[1];
  }
  var func = parseFunc(f);
  func.optionals = optionals || {};
  var ret = function(){
    var args = processArgs(func, arguments);
    return f.apply(this, args);
  }
  ret.info = func;
  ret.sig = function(){
    return displayFunc(this.info);
  }
  ret.toString = ret.sig;
  return ret;
}



$.describe('$f')
  .should('only take named parameters at the end', function(){
    var f = $f(function f(one, other){ return one; })
    $t(f(1, {other: 2})).shouldEqual(1);
    $t(f({one: 1}, 1).one).shouldEqual(1);
  })
  .should('display anonymous functions', function(){
    $t(displayFunc(parseFunc(function f(x){}))).shouldEqual("function f(x)");
  })
  .should('work with objects', function(){
    var cat = {name: 'cutie'};
    cat.greet = $f(function(){
      return "Meow! I am " + this.name + ".";
    })
    $t(cat.greet()).shouldEqual("Meow! I am cutie.");
  })
  .should('attach info to result function', function(){
    $t($f(function f(x){}).info.name).shouldEqual('f');
  })
  .should('give sig()', function(){
    $t($f(function f(x){}).sig()).shouldEqual('function f(x)');
  })
  
$.describe('argumentative with add function')
  .beforeEach(function(){
    window.add = $f(function add(one, other){
      return one + other;
    });
  })
  .should('work if right number of args', function(){
    $t(add(1,2)).shouldEqual(3);
  })
  .should('error on wrong number of args', function(){
    $t(function(){ add(1, 2, 3); }).shouldRaise(
      'function add(one, other) expected 2 arguments but got 3: (1, 2, 3).'
      )
  })
  .should('do named arguments', function(){
    $t(add({one: 1, other: 2})).shouldEqual(3);
  })
  .should('error when named args result in wrong number of args', function(){
    $t(function(){ add({one: 1}) }).shouldRaise(
      "Argument 'other' of function add(one, other) was not specified.");
  })
  .should('allow mixed args', function(){
    $t(add(1, {other: 2})).shouldEqual(3);
  })
  .should('not allow redefining args', function(){
    $t(function(){ add(1, 2, {one: 3}) }).shouldRaise(
      "Multiple definitions of argument 'one' of function add(one, other), first as 1, then as 3."
      )
  })
  .should('error if passing in wrong named parameter', function(){
    $t(function(){ add({one: 1, other: 2, two: 2})}).shouldRaise(
      "Unexpected argument 'two' for function add(one, other)."
      )
  })
  .should('error if passing in wrong named parameters', function(){
    $t(function(){ add({one: 1, other: 2, two: 2, three: 3})}).shouldRaise(
      "Unexpected arguments 'two' and 'three' for function add(one, other)."
      )
  })
  .should('cope with null arguments', function(){
    $t(add(null, null)).shouldEqual(0);
  })
  
$.describe('optional args')
  .beforeEach(function(){
    window.add = $f(
      {one: 1, other: 2},
      function add(one, other){
        return one + other;
      }
    );
  })
  .should('do optional arguments', function(){
    $t(add()).shouldEqual(3);
  })
  .should('override arguments', function(){
    $t(add(2)).shouldEqual(4);
  })
  .should('override named arguments', function(){
    $t(add({other: 5})).shouldEqual(6);
  })
  .should('should optionals in sig()', function(){
    $t(add.sig()).shouldEqual('function add(one=1, other=2)');
  })
  .should('override toString()', function(){
    $t(add.toString()).shouldEqual(add.sig());
  })
  .should('allow undefined as default', function(){
    var f = $f(
      {a: undefined},
      function(a){
        return a;
      });
    $t(f()).shouldEqual(undefined);
  })
  .should('be able to set optional by undefined using list format', function(){
    var f = $f(
      ['a'],
      function(a){
        return a;
      });
    $t(f()).shouldEqual(undefined);
  })

$.describe('variable length arg list')
  .beforeEach(function(){
    Array.prototype.append = $f(function($vargs){
      var self = this;
      $vargs.forEach(function(elm){
        self.push(elm);
      });
    })
    window._return = $f(function(name, $vargs){
      return [name, $vargs];
    })
  })
  .should("work", function(){
    var arr = [1,2,3];
    arr.append(4, 5, 6);
    $t(arr).shouldEqual([1,2,3,4,5,6]);
  })
  .should("pass in empty list if nothing passed in", function(){
    var arr = [1,2,3];
    arr.append();
    $t(arr).shouldEqual([1,2,3]);
  })
  .should("be able to mix normal args and vargs", function(){
    $t(_return('add', 1, 2, 3)[1]).shouldEqual([1,2,3]);
  })
  .should("be able to use any $name", function(){
    var f = $f(function($values){
      return $values;
    });
    $t(f(1,2,3)).shouldEqual([1,2,3]);
  })
  
$.describe('keyword arguments')
  .beforeEach(function(){
    window.keywords = $f(function($$kwargs){
      return $$kwargs;
    });
  })
  .should("work", function(){
    $t(keywords({one: 1, two: 2})).shouldEqual({one: 1, two: 2});
  })
  .should("be able to mix vargs and kwargs", function(){
    var f = $f(function($vargs, $$kwargs){
      return [$vargs, $$kwargs];
    });
    var result = f(1,2,3,4,{one: 1, two: 2});
    $t(result[0]).shouldEqual([1,2,3,4]);
    $t(result[1]).shouldEqual({one: 1, two: 2});
  })


/* ===== setup for jquery.bdd =========== */
$.specOutput = function(msg){
  $('#log').append(msg + '<br/>')
}
$($.runSpecs);