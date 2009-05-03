(function(){
    include 'addMethodsTo.as';
    addMethodsTo(Number, {
        minutes: function(){
            return this * 60 * 1000;
        },
        ago: function(){
            return new Date(new Date().getTime() - this);
        }
    });
})();