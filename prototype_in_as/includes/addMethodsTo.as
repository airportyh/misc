function addMethodsTo(cls:Class, methods){
    for (var name:String in methods){
        cls.prototype[name] = methods[name];
        cls.prototype.setPropertyIsEnumerable(name, false);
    }
}