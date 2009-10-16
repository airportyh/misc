import com.google.maps.MapEvent
import com.google.maps.LatLng
function setupLandmarks(){
    var richmond:LatLng = new LatLng(37.50, -77.33)
    var newYork:LatLng = new LatLng(40.77, -73.98)
    var atlanta:LatLng = new LatLng(33.65, -84.42)
    var sanJose:LatLng = new LatLng(37.37, -121.92)
    map.addPolyline([richmond, newYork, atlanta])
    map.addMarker(sanJose)
    
}
function initApp(){
    map.map.addEventListener(MapEvent.MAP_READY, function(e){
        setupLandmarks()
    })
}