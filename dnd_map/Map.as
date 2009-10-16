package{
    
    import mx.containers.Canvas
    import flash.geom.Point
    import flash.events.MouseEvent
    import com.google.maps.interfaces.IOverlay
    import com.google.maps.interfaces.IControl
    import com.google.maps.LatLng
    import com.google.maps.MapMouseEvent
    import com.google.maps.overlays.Marker
    import com.google.maps.overlays.Polyline
    public class Map extends Canvas{
        public var map:OurMap
        var overlayPane:OverlayPane

        public function Map(){
            map = new OurMap()
            overlayPane = new OverlayPane()
            addChild(map)
            addChild(overlayPane)
            setChildIndex(overlayPane, 1)
            setChildIndex(map, 0)
            setupMapEventListeners()
        }
        
        public function set key(key:String):void{
            map.key = key
        }
        public function set client(client:String):void{
            map.client = client
        }
        
        function setupMapEventListeners(){
            addEventListener(MouseEvent.MOUSE_UP, onMapMouseUp)
            addEventListener(MouseEvent.MOUSE_MOVE, onMapMouseMove)
            map.addEventListener(MouseEvent.MOUSE_DOWN, onMapMouseDown)
        }
        
        function mapCoordinates(e:MouseEvent):Point{
            return map.globalToLocal(new Point(e.stageX, e.stageY))
        }
        
        // =========== util functions ====================
        
        var draggedMarker:Marker
        public function addPolyline(points:Array):void{
            var polyline:Polyline = new Polyline(points)
            polyline.addEventListener(MapMouseEvent.MOUSE_UP, onPolylineMouseUp)
            map.addOverlay(polyline)
        }
        
        
        
        public function addMarker(point:LatLng):void{
            var marker:Marker = new Marker(point)
            marker.addEventListener(MapMouseEvent.MOUSE_DOWN, onMarkerMouseDown)
            marker.addEventListener(MapMouseEvent.MOUSE_UP, onMarkerMouseUp)
            map.addOverlay(marker)
        }
        
        // =========== Drag & Drap Machinery =============
        
        function onPolylineMouseUp(e:MapMouseEvent):void{
            trace('polyline moused up') // this never happens if you drop a marker onto a polyline
        }
        
        function onMarkerMouseDown(e:MapMouseEvent):void{
            draggedMarker = e.feature as Marker
        }
        
        function onMarkerMouseUp(e:MapMouseEvent):void{
            if (draggedMarker === e.feature){
                trace('unset draggedMarker')
                draggedMarker = null
            }
        }
        
        function onMapMouseUp(e:MouseEvent){
            //trace('onMapMouseUp()')
            /*
            map.dispatchEvent(new MouseEvent(
                e.type, 
                e.bubbles,
                e.cancelable,
                e.localX,
                e.localY,
                null,
                e.ctrlKey,
                e.altKey,
                e.shiftKey,
                e.buttonDown,
                e.delta))
            */
        }
        
        function onMapMouseMove(e:MouseEvent){
            //trace('onMapMouseMove()')
            if (draggedMarker){
                draggedMarker.setLatLng(map.fromViewportToLatLng(mapCoordinates(e)))
            }
        }
        
        function onMapMouseDown(e:MouseEvent){
        }
        
        

    }
}

import com.google.maps.Map
import com.google.maps.MapEvent
import com.google.maps.controls.*
class OurMap extends com.google.maps.Map{
    public function OurMap(){
        sensor = "false"
        addEventListener(MapEvent.MAP_READY, onReady)
        percentWidth = 100
        percentHeight = 100
    }
    function onReady(e){
        setCenter(new LatLng(36.1741, -97.0422))
        setZoom(4)
        enableContinuousZoom()
        enableControlByKeyboard()
        enableScrollWheelZoom()
        addControl(new PositionControl())
        addControl(new ZoomControl())
    }
}

import mx.core.UIComponent;
import flash.display.Sprite;
import flash.geom.Point
import flash.display.Graphics
class OverlayPane extends UIComponent{
    var rectangle:Sprite
    var dot:Sprite
    var bentSegment:Sprite
    public function OverlayPane(){
        percentWidth = 100
        percentHeight = 100
    }
    
    function removeAllChildren(){
    	for (var i:int = numChildren - 1; i >= 0; i--) {
			removeChildAt(0)
		}
    }
    
    override protected function updateDisplayList(
        unscaledWidth:Number, 
        unscaledHeight:Number):void {
        removeAllChildren()
		if (rectangle) addChild(rectangle)
		if (dot) addChild(dot)
		if (bentSegment) addChild(bentSegment)
    }
    
    public function setDot(pos:Point){
        var color = 0x1fb000
        dot = new Sprite()
        var g:Graphics = dot.graphics
        g.lineStyle(1, color, 0.5, false, 'normal', 'rounded')
        g.drawCircle(pos.x, pos.y, 5)
        g.beginFill(color, 0.8)
        g.drawCircle(pos.x, pos.y, 5)
        invalidateDisplayList() 
    }
    public function clearDot(){
        dot = null
        invalidateDisplayList()
    }
    
}



