# Load required libraries
if (!requireNamespace("sf", quietly = TRUE)) install.packages("sf")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")

library(sf)
library(ggplot2)

# Define the path to the CSV file
csv_path <- "C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/POINTS.csv"

# Load the CSV file into a data frame
points_data <- read.csv(csv_path)

# Inspect the data
head(points_data)

# Define the coordinate reference system (EPSG 32717 - WGS 84 / UTM zone 17S)
crs_epsg <- 32717

# Convert the data frame to an sf object (point geometry)
points_sf <- st_as_sf(points_data, coords = c("X", "Y"), crs = crs_epsg)

# Define the path to save the shapefile
output_shapefile <- "C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/points_data.shp"

# Save the sf object as a shapefile
st_write(points_sf, output_shapefile, delete_layer = TRUE)

print(paste("Shapefile created at:", output_shapefile))

# Plot the points using ggplot2
ggplot() +
  geom_sf(data = points_sf, color = "red", size = 5) +
  theme_minimal() +
  labs(title = "Points from CSV as Shapefile", x = "Easting", y = "Northing")
