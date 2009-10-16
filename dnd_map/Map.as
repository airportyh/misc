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
    import com.google.maps.Map
    import com.google.maps.MapEvent
    import com.google.maps.controls.*
    public class Map extends com.google.maps.Map{

        public function Map(){
            sensor = "false"
            setupMapEventListeners()
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
        
        function setupMapEventListeners(){
            addEventListener(MapEvent.MAP_READY, onReady)
            addEventListener(MouseEvent.MOUSE_UP, onMapMouseUp)
            addEventListener(MouseEvent.MOUSE_MOVE, onMapMouseMove)
            addEventListener(MouseEvent.MOUSE_DOWN, onMapMouseDown)
        }
        
        function mapCoordinates(e:MouseEvent):Point{
            return globalToLocal(new Point(e.stageX, e.stageY))
        }
        
        // =========== util functions ====================
        
        var draggedMarker:Marker
        public function addPolyline(points:Array):void{
            var polyline:Polyline = new Polyline(points)
            polyline.addEventListener(MapMouseEvent.MOUSE_UP, onPolylineMouseUp)
            addOverlay(polyline)
        }
        
        
        
        public function addMarker(point:LatLng):void{
            var marker:Marker = new Marker(point)
            marker.addEventListener(MapMouseEvent.MOUSE_DOWN, onMarkerMouseDown)
            marker.addEventListener(MapMouseEvent.MOUSE_UP, onMarkerMouseUp)
            addOverlay(marker)
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
        }
        
        function onMapMouseMove(e:MouseEvent){
            //trace('onMapMouseMove()')
            if (draggedMarker){
                draggedMarker.setLatLng(fromViewportToLatLng(mapCoordinates(e)))
            }
        }
        
        function onMapMouseDown(e:MouseEvent){
        }
        
        

    }
}

