function strip(s) {
  return s.replace(/^\s*|\s*$/g, "");
}

function parseFunc(f){
  var m = f.toString().match(/function[ \t\n]*([^\(]*)\((.*?)\).*/);
  var name = m[1] || null;
  var args = m[2] == '' ? [] : m[2].split(',');
  args = args.map(function(arg){ return strip(arg); });
  return {name: name, args: args};
}

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

function processArgs(func, args, optionals){
  var argMap = {};
  var extraArgs = [];
  for (var i = 0; i < args.length; i++){
    var arg = args[i];
    if (arg.constructor == Object && i == args.length - 1){
      // This is a keyword hash
      for (var key in arg){
        if (func.args.indexOf(key) < 0)
          throw new Error("Unexpected argument '" + key + "' for " + displayFunc(func) + '.');
        if (argMap[key] !== undefined){
          throw new Error('Multiple definitions of argument ' + key + ' of ' + displayFunc(func) + ', first as ' + argMap[key] + ', then as ' + arg[key] + '.');
        }
        argMap[key] = arg[key];
      }
    }else{
      var funcArg = func.args[i];
      if (funcArg === undefined)
        extraArgs.push(arg);
      argMap[funcArg] = arg;
    }
  }
  if (extraArgs.length > 0){
    throw new Error(displayFunc(func) + ' expected ' + func.args.length +
      ' arguments but got ' + args.length + ': ' + displayArgs(args) + '.');
  }
  var ret = [];
  for (var i = 0; i < func.args.length; i++){
    var argName = func.args[i];
    var val = argMap[argName];
    if (val === undefined){
      if (optionals[argName] !== undefined)
        val = optionals[argName];
      else
        throw new Error('Argument \'' + argName + '\' of ' + displayFunc(func) + ' was not specified.');
    }
    ret.push(val);    
  }
  return ret;
}

function $f(){
  var f, optionals;
  if (arguments[0].constructor == Function)
    f = arguments[0];
  if (arguments[0].constructor == Object){
    optionals = arguments[0];
    f = arguments[1];
  }
  var func = parseFunc(f);
  func.optionals = optionals;
  var ret = function(){
    var args = processArgs(func, arguments, optionals || {});
    return f.apply(this, args);
  }
  //if (func.name)
  //  this[func.name] = ret;
  ret.info = func;
  ret.sig = function(){
    return displayFunc(this.info);
  }
  ret.toString = ret.sig;
  return ret;
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
    $t(function(){ console.log(add(1, 2, 3)); }).shouldRaise(
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
      'Multiple definitions of argument one of function add(one, other), first as 1, then as 3.'
      )
  })
  .should('error if passing in wrong named parameter', function(){
    $t(function(){ add({one: 1, other: 2, two: 2})}).shouldRaise(
      "Unexpected argument 'two' for function add(one, other)."
      )
  })
  
$.describe('argumentative optional params')
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

$.specOutput = function(msg){
  $('#log').append(msg + '<br/>')
}
$($.runSpecs);