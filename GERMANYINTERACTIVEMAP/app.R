# Required libraries
library(shiny)
library(leaflet)
library(leaflet.extras)
library(sf)
library(htmlwidgets)

# UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML(".coordinate-display {
      background: rgba(255,255,255,0.9);
      padding: 6px;
      font-family: monospace;
      font-size: 12px;
    }
    .sidebar-container {
      height: 100vh;
      overflow-y: auto;
      background-color: #f9f9f9;
      padding: 10px;
    }
    .map-container {
      height: 100vh;
    }
    .credit-note {
      margin-top: 20px;
      font-size: 12px;
      color: #555;
    }"))
  ),
  fluidRow(
    column(3, class = "sidebar-container",
           tags$img(src = "https://assets.uni-augsburg.de/media/filer_public_thumbnails/filer_public/ba/bc/babcc777-8903-4ba3-963c-dcc809177c84/uni_aug_logo_basis_pos_bjpg__1080x2000_q85_subject_location-869334_subsampling-2.jpg__1080x2000_q85_subject_location-344%2C59_subsampling-2.jpg", height = "60px"),
           tags$h3(strong("Interactive Map of Germany"), style = "font-size: 22px;"),
           
           tags$p(strong("Credits: Dr. Cesar Ivan Alvarez | "),
                  tags$a(href = "mailto:cesar.alvarez@uni-a.de", "cesar.alvarez@uni-a.de")),
           tags$p("Research Associate at the Chair of Climate Resilience of Cultural Ecosystems"),
           tags$p("Center for Climate Resilience, University of Augsburg"),
           
           numericInput("lat", "Latitude", value = 48.33),
           numericInput("lon", "Longitude", value = 10.89),
           actionButton("go_geo", "Zoom to Lat/Lon"),
           hr(),
           numericInput("utm_x", "UTM Easting (Zone 32N)", value = 640381),
           numericInput("utm_y", "UTM Northing (Zone 32N)", value = 5355235),
           actionButton("go_utm", "Zoom to UTM"),
           hr(),
           actionButton("zoom_germany", "Zoom to Germany", style = "background-color: #0073e6; color: white;"),
           actionButton("clear", "Clear Points", style = "color: red; margin-top: 10px;"),
           
           tags$div(class = "credit-note",
                    HTML(paste0(
                      "<strong>WMS data source:</strong> <a href='https://gdz.bkg.bund.de' target='_blank'>gdz.bkg.bund.de</a><br>",
                      "<small>The Licensee is obliged to provide a clearly visible source reference and change notice.<br>
                      &copy; BKG — <a href='https://www.bkg.bund.de' target='_blank'>BKG</a>, License: 
                      <a href='https://creativecommons.org/licenses/by/4.0/' target='_blank'>CC BY 4.0</a><br>
                      <em>Satellite imagery: &copy; Esri, DigitalGlobe, GeoIQ, Earthstar Geographics, CNES/Airbus DS, 
                      USDA, USGS, AeroGRID, IGN, and the GIS User Community</em></small>"
                    ))
           )
    ),
    column(9, class = "map-container", leafletOutput("map", height = "100%"))
  )
)

# Server
server <- function(input, output, session) {
  base_map <- leaflet() %>%
    addTiles(group = "Base Map") %>%
    addProviderTiles(providers$Esri.WorldImagery, group = "Satellite") %>% addTiles(group = "Base Map") %>%
    addWMSTiles("https://sgx.geodatenzentrum.de/wms_dtk100", layers = "dtk100", options = WMSTileOptions(format = "image/png", transparent = TRUE), group = "DTK100") %>% hideGroup("DTK100") %>%
    addWMSTiles("https://sgx.geodatenzentrum.de/wms_dtk250", layers = "dtk250", options = WMSTileOptions(format = "image/png", transparent = TRUE), group = "DTK250") %>% hideGroup("DTK250") %>%
    addWMSTiles("https://sgx.geodatenzentrum.de/wms_dtk500", layers = "dtk500", options = WMSTileOptions(format = "image/png", transparent = TRUE), group = "DTK500") %>% hideGroup("DTK500") %>%
    addWMSTiles("https://sgx.geodatenzentrum.de/wms_dtk1000", layers = "dtk1000", options = WMSTileOptions(format = "image/png", transparent = TRUE), group = "DTK1000") %>% hideGroup("DTK1000") %>%
    addMiniMap(toggleDisplay = TRUE, zoomLevelFixed = 3, position = "bottomright") %>%
    addMeasure(position = "topleft", primaryLengthUnit = "kilometers", secondaryLengthUnit = "meters", activeColor = "red", completedColor = "green") %>%
    addSearchOSM(options = searchOptions(zoom = 10, autoCollapse = TRUE, textPlaceholder = "Search for a German city...")) %>%
    addLayersControl(baseGroups = c("Base Map", "Satellite"), overlayGroups = c("DTK100", "DTK250", "DTK500", "DTK1000", "Buffers"), options = layersControlOptions(collapsed = FALSE)) %>%
    setView(lng = 10, lat = 51, zoom = 6) %>%
    addLegend(position = "bottomright", colors = c("red", "green", "#8da0cb"), labels = c("500 m", "1000 m", "5000 m"), title = "Buffer Radius (m)") %>%
    onRender("function(el, x) {
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
            'UTM: ' + utmX + ' E, ' + utmY + ' N';
        });
      }.bind(this);
    }")
  
  output$map <- renderLeaflet({ base_map })
  
  proxy <- leafletProxy("map")
  
  observeEvent(input$go_geo, {
    point <- st_point(c(input$lon, input$lat))
    point_sf <- st_sfc(point, crs = 4326)
    point_utm <- st_transform(point_sf, 3857)
    
    buffer_500  <- st_transform(st_buffer(point_utm, dist = 500), 4326)
    buffer_1000 <- st_transform(st_buffer(point_utm, dist = 1000), 4326)
    buffer_5000 <- st_transform(st_buffer(point_utm, dist = 5000), 4326)
    
    proxy %>%
      addPolygons(data = buffer_500, color = "red", weight = 2, fillOpacity = 0.3, group = "Buffers") %>%
      addPolygons(data = buffer_1000, color = "green", weight = 2, fillOpacity = 0.3, group = "Buffers") %>%
      addPolygons(data = buffer_5000, color = "#8da0cb", weight = 2, fillOpacity = 0.3, group = "Buffers") %>%
      addMarkers(lng = input$lon, lat = input$lat,
                 popup = paste0("Lat: ", input$lat, "<br>Lon: ", input$lon)) %>%
      setView(lng = input$lon, lat = input$lat, zoom = 10)
  })
  
  observeEvent(input$go_utm, {
    try({
      coords <- data.frame(Easting = as.numeric(input$utm_x), Northing = as.numeric(input$utm_y))
      pt_sf <- st_as_sf(coords, coords = c("Easting", "Northing"), crs = 32632)
      pt_ll <- st_transform(pt_sf, 4326)
      lng <- st_coordinates(pt_ll)[1, 1]
      lat <- st_coordinates(pt_ll)[1, 2]
      
      point <- st_point(c(lng, lat))
      point_sf <- st_sfc(point, crs = 4326)
      point_utm <- st_transform(point_sf, 3857)
      
      buffer_500  <- st_transform(st_buffer(point_utm, dist = 500), 4326)
      buffer_1000 <- st_transform(st_buffer(point_utm, dist = 1000), 4326)
      buffer_5000 <- st_transform(st_buffer(point_utm, dist = 5000), 4326)
      
      proxy %>%
        addPolygons(data = buffer_500, color = "red", weight = 2, fillOpacity = 0.3, group = "Buffers") %>%
        addPolygons(data = buffer_1000, color = "green", weight = 2, fillOpacity = 0.3, group = "Buffers") %>%
        addPolygons(data = buffer_5000, color = "#8da0cb", weight = 2, fillOpacity = 0.3, group = "Buffers") %>%
        addMarkers(lng = lng, lat = lat,
                   popup = paste0("UTM: ", input$utm_x, " E, ", input$utm_y, " N")) %>%
        setView(lng = lng, lat = lat, zoom = 10)
    }, silent = TRUE)
  })
  
  observeEvent(input$zoom_germany, {
    proxy %>% setView(lng = 10, lat = 51, zoom = 6)
  })
  
  observeEvent(input$clear, {
    proxy %>% clearMarkers() %>% clearGroup("Buffers")
  })
}

# Run app
shinyApp(ui, server)

