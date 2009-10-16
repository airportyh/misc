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
    
    [Event(name="mapevent_mapready", type="com.google.maps.MapEvent")]
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
        
        function setupMapEventListeners(){
            addEventListener(MouseEvent.MOUSE_MOVE, onMapMouseMove)
        }
        
        function mapCoordinates(e:MouseEvent):Point{
            return map.globalToLocal(new Point(e.stageX, e.stageY))
        }
        
        // =========== mimic Map's interface ======================
        
        public function set key(key:String):void{
            map.key = key
        }
        public function set client(client:String):void{
            map.client = client
        }
        
        public function setCenter(c:LatLng):void{
            map.setCenter(c)
        }
        public function setZoom(z:Number):void{
            map.setZoom(z)
        }
        
        public override function addEventListener(
            type:String, 
            listener:Function, 
            useCapture:Boolean = false, 
            priority:int = 0, 
            useWeakReference:Boolean = false):void{
            if (type == 'maptypechanged' ||
                type.match(/^mapevent_.*/))
                map.addEventListener(type, listener,
                    useCapture, priority, useWeakReference)
            else
                super.addEventListener(type, listener,
                    useCapture, priority, useWeakReference)
        }
        
        // =========== util functions ====================
        
        var draggedMarker:Marker
        public function addPolyline(points:Array):void{
            var polyline:Polyline = new Polyline(points)
            polyline.addEventListener(MapMouseEvent.MOUSE_UP, onPolylineMouseUp)
            polyline.addEventListener(MapMouseEvent.ROLL_OVER, onPolylineRollOver)
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
        
        function onPolylineRollOver(e:MapMouseEvent):void{
            trace('polyline rolled over')
        }
        
        function onMarkerMouseDown(e:MapMouseEvent):void{
            draggedMarker = e.feature as Marker
        }
        
        function onMarkerMouseUp(e:MapMouseEvent):void{
            if (draggedMarker === e.feature){
                trace('unset draggedMarker')
                draggedMarker = null
                overlayPane.clearDot()
            }
        }
        
        function onMapMouseMove(e:MouseEvent){
            //trace('onMapMouseMove()')
            if (draggedMarker){
                var point:Point = mapCoordinates(e)
                overlayPane.setDot(point)
            }
        }

    }
}

import com.google.maps.Map
import com.google.maps.MapEvent
import com.google.maps.controls.*
import com.google.maps.LatLng
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
    var dot:Sprite
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
		if (dot) addChild(dot)
    }
    
    public function setDot(pos:Point){
        var color = 0xff766a
        dot = new Sprite()
        var g:Graphics = dot.graphics
        g.lineStyle(1, 0x000000, 0.5, false, 'normal', 'rounded')
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



