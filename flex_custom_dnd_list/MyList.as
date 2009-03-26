package{
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import mx.events.DragEvent;
    import mx.controls.List;
    import mx.core.mx_internal;
    import mx.managers.DragManager;
    import mx.effects.Glow;
    use namespace mx_internal;

    public class MyList extends List{


        
        override protected function dragEnterHandler(event:DragEvent):void{
            _dragOverHandler(event);
        }
        
        override protected function dragOverHandler(event:DragEvent):void{
            _dragOverHandler(event);
        }
        
        override protected function dragDropHandler(event:DragEvent):void{
            var item = findItemForDragEvent(event);
            var uid:String = itemToUID(item.data);
            if (item){
                var orgColor = getStyle('rollOverColor');
                setStyle("rollOverColor", '#FFFEA2')
                drawItem(item, isItemSelected(item.data), false, uid == caretUID);
                setStyle('rollOverColor', orgColor);
                /*var ef:Glow = new Glow(item);
                ef.color = 0xFFFEAB;
                ef.play();*/
            }
        }
        
        public function findItemForDragEvent(event:DragEvent):Object{
            var item;
            var lastItem;
            var pt:Point = new Point(event.localX, event.localY);
            pt = DisplayObject(event.target).localToGlobal(pt);
            pt = listContent.globalToLocal(pt);
            var rc:int = listItems.length;
            for (var i:int = 0; i < rc; i++)
            {
                if (listItems[i][0])
                    lastItem = listItems[i][0];

                if (rowInfo[i].y <= pt.y && pt.y < rowInfo[i].y + rowInfo[i].height)
                {
                    item = listItems[i][0];
                    break;
                }
            }
            return item;
        }
        
        protected function _dragOverHandler(event:DragEvent):void{
            var item = findItemForDragEvent(event);
            if (item){
                DragManager.acceptDragDrop(this);
                DragManager.showFeedback(event.ctrlKey ? DragManager.COPY : DragManager.MOVE);
                showDropFeedback(event);
            }else{
                DragManager.showFeedback(DragManager.NONE);
            }
        }
        
        override public function showDropFeedback(event:DragEvent):void{
            var item = findItemForDragEvent(event);
            var uid:String = itemToUID(item.data);
            if (item){
                drawItem(item, isItemSelected(item.data), true, uid == caretUID);
            }
        }
    }
}