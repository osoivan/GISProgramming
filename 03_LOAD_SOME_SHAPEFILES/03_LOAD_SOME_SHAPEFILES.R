# Load required libraries
if (!requireNamespace("sf", quietly = TRUE)) install.packages("sf")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")

library(sf)
library(ggplot2)

# Define the path to the folder containing shapefiles
folder_path <- "C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/IGM_1G"

# List all shapefiles in the folder (and subfolders)
shapefile_paths <- list.files(
  path = folder_path, 
  pattern = "\\.shp$", 
  recursive = TRUE, 
  full.names = TRUE
)

# Check if any shapefiles were found
if (length(shapefile_paths) == 0) {
  stop("No shapefiles found in the specified directory.")
}

# Load all shapefiles and extract only geometry
shapefiles_list <- lapply(shapefile_paths, function(path) {
  tryCatch({
    shp <- st_read(path, quiet = TRUE)
    st_geometry(shp)  # Extract only the geometry
  }, error = function(e) {
    message(paste("Error reading file:", path, "-", e$message))
    return(NULL)
  })
})

# Remove NULL elements from the list (failed shapefile loads)
shapefiles_list <- shapefiles_list[!sapply(shapefiles_list, is.null)]

# Combine only geometries into a single spatial dataframe
if (length(shapefiles_list) > 0) {
  combined_geometries <- do.call(c, shapefiles_list)
  
  # Create a simple sf object with only geometry
  combined_shapefiles <- st_as_sf(combined_geometries)
  
  # Plot all shapefiles on a single map using ggplot2
  ggplot() +
    geom_sf(data = combined_shapefiles, fill = "blue", color = "black", alpha = 0.5) +
    theme_minimal() +
    labs(title = "Map with the loaded shapefiles", x = "Longitude", y = "Latitude")
  
} else {
  message("No valid shapefiles to plot.")
}
