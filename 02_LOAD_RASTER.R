# Install the terra package if not already installed
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}

# Load the terra library
library(terra)

# Define the path to the RGB raster TIFF file
raster_path <- "C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/BermejoBS09_Ortomosaico.tif"

# Load the raster as a multi-band raster
rgb_raster <- rast(raster_path)

# Check the raster properties
print(rgb_raster)

# Plot the RGB raster using the first three bands as Red, Green, Blue
plotRGB(rgb_raster, r = 1, g = 2, b = 3, stretch = "lin")
