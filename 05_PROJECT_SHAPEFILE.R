library(sf, ggplot2)

setwd("C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/ZonificacionAguacateMAGAP")
shapefile <- st_read("Zonificación_agroecologica_aguacate_litoral_2013.shp")
shapefile_reprojected <- st_transform(shapefile, crs = 4326) # Reproject the shapefile

# Create the plot
ggplot(data = shapefile_reprojected) +  geom_sf() +  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = "gray", size = 0.5),  # Major grid lines
    panel.grid.minor = element_line(color = "lightgray", size = 0.5),  # Minor grid lines
    panel.background = element_rect(fill = "white")  # Background color
  ) +  labs(x = "Longitude", y = "Latitude") +  coord_sf()  # Coordinate system for the map

crs_info <- st_crs(shapefile_reprojected)
print(paste("CRS:", crs_info$epsg, "-", crs_info$proj4string))
st_write(shapefile_reprojected, "Aguacate4326.shp", delete_layer = TRUE)