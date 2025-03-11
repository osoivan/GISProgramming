library(sf, dplyr, ggplot2)
setwd("C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS")
shapefiles <- list.files(path = "EURODATA", pattern = "\\.shp$", full.names = TRUE)
clip_polygon <- st_read("GERMANY/Germany_boundary.shp")
clip_crs <- st_crs(clip_polygon)

# Create a new folder for the output shapefiles (if it doesn't already exist)
output_folder <- "Germany_clipped"
if (!dir.exists(output_folder)) {
  dir.create(output_folder, recursive = TRUE)
}

clipped_shapefiles <- lapply(shapefiles, function(shp) {
  shp_data <- st_read(shp)
  shp_data_reprojected <- st_transform(shp_data, crs = clip_crs)   # Reproject the shapefile to the same CRS as the clip polygon
  clipped <- st_intersection(shp_data_reprojected, clip_polygon)   # Clip the reprojected shapefile using the clip_polygon
  
  # Export the clipped shapefile to the output folder with original name + "_Germany" suffix
  output_shapefile <- file.path(output_folder, paste0(tools::file_path_sans_ext(basename(shp)), "_Germany.shp"))
  
  # Check if the file already exists and create a unique filename if necessary
  if (file.exists(output_shapefile)) {
    counter <- 1
    while (file.exists(output_shapefile)) {
      output_shapefile <- file.path(output_folder, paste0(tools::file_path_sans_ext(basename(shp)), "_Germany_", counter, ".shp"))
      counter <- counter + 1
    }
  }
  
  st_write(clipped, output_shapefile)   # Export the clipped shapefile
  return(clipped) # Return the clipped shapefile
})

combined_clipped <- bind_rows(clipped_shapefiles) # Combine the clipped shapefiles into one large dataset using dplyr::bind_rows

ggplot() + geom_sf(data = combined_clipped, fill = "lightblue", color = "black") +  # Plot the clipped shapefiles
  theme_minimal() + labs(title = "Clipped Shapefiles", x = "Longitude", y = "Latitude") + theme(legend.position = "none")