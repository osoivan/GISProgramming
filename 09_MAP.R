library(sf)
library(dplyr)
library(ggplot2)
library(ggspatial)
setwd("C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS")

# Define the function to read, transform, and assign color to shapefiles based on user input
rtc <- function(shapefile_path) {
  shapefile <- st_read(shapefile_path)  # Read the shapefile
  transformed_shapefile <- st_transform(shapefile, crs = 4326)   # Transform to EPSG:4326 (WGS 84)
  return(transformed_shapefile)
}

roads <- rtc("Germany_clipped/RailrdL_Germany.shp")
boundaries <- rtc("GERMANY/Germany_boundary.shp")
rivers <- rtc("Germany_clipped/MajorRivers_Germany.shp")
airports <- rtc("Germany_clipped/Airports_Germany.shp")

ggplot() +
  geom_sf(data = boundaries, aes(fill = "Boundaries"), size = 1, color = "gray", alpha = 0.5) +  
  geom_sf(data = roads, aes(fill = "Roads"), size = 1, color = "red") + 
  geom_sf(data = rivers, aes(fill = "Rivers"), size = 1, color = "blue") +  
  geom_sf(data = airports, aes(fill = "Airports"), shape = 23, size = 3, color = "yellow") +  
  # Manually define the fill colors and create a legend
  scale_fill_manual(
    name = "Legend",  # Legend title
    values = c("Boundaries" = "gray", "Roads" = "red", "Rivers" = "blue", "Airports" = "yellow"),  # Map colors to labels
    guide = guide_legend(override.aes = list(shape = 22, size = 5))  # Customize legend appearance
  ) +
  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "gray", size = 0.5),  # Major grid lines
    panel.grid.minor = element_line(color = "lightgray", size = 0.5),  # Minor grid lines
    panel.background = element_rect(fill = "white")  # Background color
  ) +
  # Add a North Arrow
  annotation_north_arrow(location = "tl", width = unit(0.4, "in"), height = unit(0.4, "in")) +
  # Add a scale bar
  annotation_scale(location = "br", width_hint = 0.2) +
  labs(
    title = "Map of Germany",
    x = "Longitude", 
    y = "Latitude"
  ) + coord_sf()  # Use coordinate system for the map