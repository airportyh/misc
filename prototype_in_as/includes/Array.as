(function(){
    include 'addMethodsTo.as';
    addMethodsTo(Array, {
        collect: function(f){
            var ret = [];
            for each(var it in this) ret.push(f(it));
            return ret;
        }
    });
})();