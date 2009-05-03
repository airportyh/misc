(function(){
    include 'addMethodsTo.as';
    addMethodsTo(Number, {
        minutes: function(){
            return this * 60;
        },
        ago: function(){
            return new Date(new Date().getTime() - this);
        }
    });
})();