$(function(){
  var headerHidden = false;
  var mapInitialized = false;
  var mapShow = false;
  var mapContainer = $("#mapContainer");
  var list = $("#list");
  var mapToggle = $(".mapToggle");
  var search = $("#search");

  function toggleMap (){
    if (mapShow) {
      mapToggle.html("Map View");
      // animate
      mapContainer.fadeIn(500, function() { list.fadeOut(500) });
    } else{
      mapToggle.html("List View");
      // animate
      list.fadeOut(500, function() { mapContainer.fadeIn(500, initPoints) });
    }
    mapShow = !mapShow;
  }

  function initPoints(){
    // initialize the map if it wasn't already on
    if (!mapInitialized && mapContainer.data('latitude') && mapContainer.data('longitude')) {
      initMap(mapContainer.data('latitude'), mapContainer.data('longitude'));

      // get a list of points from the server based on the searched location
      $.get( '/restrooms' + window.location.search , {}, function( data ) {
        for(var i = 0; i < data.length; i++){
        // for each point in the data, put a point on the map
        setPoint(data[i], i + 1);
        }
      }, 'json');
      mapInitialized = true;
    }
  }


  if (mapContainer.length > 0 && list.length > 0 && mapToggle.length > 0) {
    if (!mapContainer.data('latitude') || !mapContainer.data('longitude')) {
      // catch bad URL
      searchLocation(search.val());
    }
    // get default height for animation later
    mapHeight = mapContainer.height();
    listHeight = list.height();

    // hide the map
    mapContainer.fadeOut(0);

    // toggle which display is open
    mapToggle.click(toggleMap);
  }
});
