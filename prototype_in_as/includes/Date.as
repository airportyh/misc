(function(){
    include 'addMethodsTo.as';
    addMethodsTo(Date, {
        format: function(){
            return this.toString();
        }
    });
})();