(function(){
  function jRadio(name){
    this.elements = $('input[type=radio][name=' + name + ']');
    this.lastVal = jRadio.prototype.val.apply(this);
  }
  jRadio.prototype.change = function(callback){
    var self = this;
    this.elements.click(function(){
      var val = self.val();
      if (val != self.lastVal){
        self.lastVal = val;
        callback(self);
      }
    })
  }
  jRadio.prototype.val = function(val){
    if (val === undefined){
      return this.elements.filter(function(){ return this.checked; }).val();
    }else{
      if (this.lastVal == val) return;
      this.lastVal = val;
      this.elements.filter(function(){ return $(this).val() == val; }).attr('checked', true);
      return this;
    }
  }

  $.radio = function(name){
    return new jRadio(name);
  }    
})();