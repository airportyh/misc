package{
    import flash.events.*;
    import mx.events.*;
    class Page extends EventDispatcher{
        public var number:int;
        public var size:int;
        public var total:int;
        public function Page(number:int, size:int, total:int){
            this.number = number;
            this.size = size;
            this.total = total;
        }
        [Bindable]
        public function get from():int{
            return number * size + 1;
        }
        [Bindable]
        public function get to():int{
            return (number + 1) * size;
        }
        [Bindable]
        public function get hasNext():Boolean{
            return to < total;
        }
        [Bindable]
        public function get hasPrev():Boolean{
            return number > 0;
        }
        
        private function fireChanges(){
            
            var toFire = ['from', 'to', 'hasNext', 'hasPrev'];
            for (var i = 0; i < toFire.length; i++)
                this.dispatchEvent(new PropertyChangeEvent(
                    "propertyChange", true, true, 
                    PropertyChangeEventKind.UPDATE,
                    toFire[i], null, null, this));
        }
        
        public function next(){
            number++;
            fireChanges();
        }
        
        public function prev(){
            number--;
            fireChanges();
        }
        
        
    }

}