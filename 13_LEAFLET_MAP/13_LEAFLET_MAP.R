# Cargar librerías
library(leaflet)
library(sf)

# Establecer directorio de trabajo
setwd("C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS")

# Leer los datos de puntos
data <- read.csv("POINTS.csv")
data$X_UTM <- as.numeric(data$X_UTM)
data$Y_UTM <- as.numeric(data$Y_UTM)

# Crear objeto sf en CRS UTM zona 17S
points_utm <- st_as_sf(data, coords = c("X_UTM", "Y_UTM"), crs = 32717)
points_wgs84 <- st_transform(points_utm, crs = 4326)
coords <- st_coordinates(points_wgs84)

# Asignar colores por tipo
points_wgs84$color <- ifelse(points_wgs84$Type == "A", "blue",
                             ifelse(points_wgs84$Type == "B", "green", "red"))

# Leer shapefile de zona urbana y transformar CRS
zona_urbana <- st_read("IGM_50K/zona_urbana_a/zona_urbana_a.shp")
zona_urbana_wgs84 <- st_transform(zona_urbana, crs = 4326)
zona_urbana_wgs84 <- zona_urbana_wgs84 %>% filter(nam == "QUITO")

# Crear el mapa leaflet con capas separadas
m <- leaflet() %>%
  addTiles(group = "Base") %>%
  
  # Capa de puntos
  addCircleMarkers(data = points_wgs84,
                   radius = 6,
                   color = ~color,
                   stroke = TRUE,
                   fillOpacity = 0.8,
                   popup = paste(
                     "<strong>Point:</strong>", points_wgs84$Point,
                     "<br><strong>Type:</strong>", points_wgs84$Type,
                     "<br><strong>Lon:</strong>", round(coords[,1], 5),
                     "<br><strong>Lat:</strong>", round(coords[,2], 5)
                   ),
                   clusterOptions = markerClusterOptions(),
                   group = "Puntos") %>%
  
  # Capa de zona urbana
  addPolygons(data = zona_urbana_wgs84,
              color = "gray", 
              fillColor = "lightgray", 
              weight = 2,
              fillOpacity = 0.4,
              popup = "Zona urbana",
              group = "Zona urbana") %>%
  
  # Medidor de distancias
  addMeasure(primaryLengthUnit = "meters", primaryAreaUnit = "") %>%
  
  # Leyenda de tipos
  addLegend("bottomright", 
            colors = c("blue", "green", "red"), 
            labels = c("A", "B", "C"), 
            title = "Tipo") %>%
  
  # Control de capas
  addLayersControl(
    baseGroups = c("Base"),
    overlayGroups = c("Puntos", "Zona urbana"),
    options = layersControlOptions(collapsed = FALSE)
  )

# Mostrar mapa
m

