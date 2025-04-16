# Install required packages if needed
install.packages("leaflet")
install.packages("leaflet.extras")
install.packages("htmlwidgets")

library(leaflet)
library(leaflet.extras)
library(htmlwidgets)

# Base map setup
m <- leaflet() %>%
  addTiles(group = "Base Map") %>%
  
  # DTK WMS layers (hidden by default)
  addWMSTiles("https://sgx.geodatenzentrum.de/wms_dtk100", layers = "dtk100",
              options = WMSTileOptions(format = "image/png", transparent = TRUE),
              group = "DTK100") %>% hideGroup("DTK100") %>%
  
  addWMSTiles("https://sgx.geodatenzentrum.de/wms_dtk250", layers = "dtk250",
              options = WMSTileOptions(format = "image/png", transparent = TRUE),
              group = "DTK250") %>% hideGroup("DTK250") %>%
  
  addWMSTiles("https://sgx.geodatenzentrum.de/wms_dtk500", layers = "dtk500",
              options = WMSTileOptions(format = "image/png", transparent = TRUE),
              group = "DTK500") %>% hideGroup("DTK500") %>%
  
  addWMSTiles("https://sgx.geodatenzentrum.de/wms_dtk1000", layers = "dtk1000",
              options = WMSTileOptions(format = "image/png", transparent = TRUE),
              group = "DTK1000") %>% hideGroup("DTK1000") %>%
  
  # Search
  addSearchOSM(
    options = searchOptions(
      zoom = 10,
      autoCollapse = TRUE,
      textPlaceholder = "Search for a German city..."
    )
  ) %>%
  
  # Ruler
  addMeasure(
    position = "topleft",
    primaryLengthUnit = "kilometers",
    secondaryLengthUnit = "meters",
    activeColor = "red",
    completedColor = "green"
  ) %>%
  
  # Mini map
  addMiniMap(
    toggleDisplay = TRUE,
    zoomLevelFixed = 3,
    position = "bottomright"
  ) %>%
  
  # Layer control
  addLayersControl(
    baseGroups = c("Base Map"),
    overlayGroups = c("DTK100", "DTK250", "DTK500", "DTK1000"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  
  # Initial view
  setView(lng = 10, lat = 51, zoom = 6)

# Add working coordinate display (Lat, Lon, UTM)
onRender(m, htmlwidgets::JS("
  function(el, x) {
    // Load proj4
    var script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/proj4js/2.6.2/proj4.js';
    document.head.appendChild(script);

    script.onload = function() {
      var map = this;

      var wgs84 = 'EPSG:4326';
      var utm32 = '+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs';

      var coords = L.control({position: 'bottomleft'});
      coords.onAdd = function(map) {
        var div = L.DomUtil.create('div', 'coordinate-display');
        div.style.background = 'rgba(255,255,255,0.9)';
        div.style.padding = '6px';
        div.style.font = '12px monospace';
        div.innerHTML = 'Lat: ---<br>Lon: ---<br>UTM: ---';
        return div;
      };
      coords.addTo(this);

      this.on('mousemove', function(e) {
        var lat = e.latlng.lat;
        var lon = e.latlng.lng;
        var utm = proj4(wgs84, utm32, [lon, lat]);
        var utmX = utm[0].toFixed(0);
        var utmY = utm[1].toFixed(0);

        document.querySelector('.coordinate-display').innerHTML =
          'Lat: ' + lat.toFixed(5) + '<br>' +
          'Lon: ' + lon.toFixed(5) + '<br>' +
          'UTM: ' + utmX + 'm E, ' + utmY + ' m N';
      });
    }.bind(this);
  }
"))

