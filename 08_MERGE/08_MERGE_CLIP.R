library(sf, dplyr, ggplot2)
setwd("C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/IGM_50K")

# List all the shapefiles called "curva_nivel_l" in the directory
shapefiles <- list.files(pattern = "curva_nivel_l.*\\.shp$", recursive = TRUE, full.names = TRUE)

# Read and merge all the shapefiles into a single object
curva_nivel_l_list <- lapply(shapefiles, st_read)  # Read each shapefile
merged_curva_nivel_l <- do.call(rbind, curva_nivel_l_list)  # Merge all shapefiles
zona_urbana_a <- st_read("zona_urbana_a/zona_urbana_a.shp")
quito_polygon <- zona_urbana_a %>% filter(nam == "QUITO")

# Clip the merged curva_nivel_l shapefile using the Quito polygon
clipped_curva_nivel_l <- st_intersection(merged_curva_nivel_l, quito_polygon)
st_write(clipped_curva_nivel_l, "cn_quito.shp", delete_layer = TRUE) # Save the clipped shapefile

ggplot() +   geom_sf(data = quito_polygon, fill = "red", color = "black", alpha = 0.5) +  
  geom_sf(data = clipped_curva_nivel_l, fill = "lightblue", color = "blue") +  theme_minimal() +
  labs(title = "Hypsometric curves in Quito", x = "Longitude", y = "Latitude") + theme(legend.position = "none")
