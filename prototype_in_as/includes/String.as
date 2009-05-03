(function(){
    include 'addMethodsTo.as';
    addMethodsTo(String, {
        strip: function(){
            return this.replace(/^\s+/, '').replace(/\s+$/, '');
        },
        csv2Array: function(){
            return this.split(',').collect(function(s){ return s.strip(); });
        }
    });
})();