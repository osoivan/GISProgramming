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



# Extract coordinates and ensure the polygon is closed
coords <- st_coordinates(points_sf)
coords <- rbind(coords, coords[1, ])  # Add the first point to the end to close the polygon

# Create a valid polygon geometry
polygon_geom <- st_polygon(list(coords))

# Convert the geometry to an sf object
polygon_sf <- st_sf(geometry = st_sfc(polygon_geom), crs = crs_epsg)

# Plot the points and the polygon using ggplot2
ggplot() +
  geom_sf(data = polygon_sf, fill = "green", color = "black", alpha = 0.5) +
  geom_sf(data = points_sf, color = "blue", size = 4) +
  theme_minimal() +
  labs(title = "Closed Polygon Created from Points", x = "Easting", y = "Northing")