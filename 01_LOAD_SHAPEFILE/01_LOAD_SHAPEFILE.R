# Check if the sf package is installed, and install it only if it's missing
if (!requireNamespace("sf", quietly = TRUE)) {
  install.packages("sf")
}

# Load the sf library
library(sf)

# Define the path to your shapefile
shapefile_path <- "C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/01_CARGA_SHAPEFILES/DATOS/MOROCCO_BOUNDARIES.shp"

# Read the shapefile
shapefile_data <- st_read(shapefile_path)

# Print summary
print(shapefile_data)

# Plot the shapefile
plot(shapefile_data$geometry)

# Get CRS (Coordinate Reference System)
crs_info <- st_crs(shapefile_data)
print(paste("CRS:", crs_info$epsg, "-", crs_info$proj4string))

# Get field names (attribute columns)
fields <- colnames(shapefile_data)
print("Fields in the shapefile:")
print(fields)
