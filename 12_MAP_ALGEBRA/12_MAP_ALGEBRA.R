library(terra)
library(sf)
library(classInt)
library(tmap)
library(stars)

# Set working directory
workspace <- "C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/RASTER"

# Load rasters
nir <- rast(file.path(workspace, "LC09_20240831_B5.tif"))
red <- rast(file.path(workspace, "LC09_20240831_B4.tif"))
dem <- rast(file.path(workspace, "DTM.tif"))

# Load shapefile
clip_shape <- st_read(file.path(workspace, "QUITO.shp"))

# Reproject rasters to EPSG:4326 if needed
target_crs <- "EPSG:4326"

if (!crs(nir) == target_crs) nir <- project(nir, target_crs)
if (!crs(red) == target_crs) red <- project(red, target_crs)
if (!crs(dem) == target_crs) dem <- project(dem, target_crs)

# Clip rasters
nir_c <- crop(nir, vect(clip_shape)) |> mask(vect(clip_shape))
red_c <- crop(red, vect(clip_shape)) |> mask(vect(clip_shape))
dem_c <- crop(dem, vect(clip_shape)) |> mask(vect(clip_shape))

# Calculate NDVI
ndvi <- (nir_c - red_c) / (nir_c + red_c)

# Calculate slope (in percent)
slope <- terrain(dem_c, v = "slope", unit = "degrees")
slope_percent <- tan(slope * pi / 180) * 100

# Resample slope to match NDVI (so they can be added)
slope_resampled <- resample(slope_percent, ndvi)

# Combine with weights
combined <- 0.6 * ndvi + 0.4 * slope_resampled

# Reclassify using Natural Breaks (Fisher-Jenks)
vals <- values(combined, na.rm = TRUE)
fisher <- classIntervals(vals, n = 5, style = "fisher")
classified <- classify(combined, fisher$brks, include.lowest = TRUE)

# Assign category labels
categories <- c("Very Low", "Low", "Medium", "High", "Very High")
classified <- as.factor(classified)
levels(classified) <- data.frame(ID = 1:5, Category = categories)

# Reproject and resample to EPSG:32717 with 30m resolution
classified_utm <- st_warp(
  src = st_as_stars(classified),
  crs = 32717,
  cellsize = 30,
  method = "near"  # preserve class values
)

# Create coordinate grid (graticule) in EPSG:32717
tm_shape(classified_utm) +
  tm_raster(title = "Susceptibility", palette = "-RdYlGn", labels = categories) +
  tm_grid(
    crs = "EPSG:32717",
    n.x = 6,
    n.y = 6,
    xlabels = TRUE,
    ylabels = TRUE,
    labels.inside.frame = FALSE,
    col = "black",
    alpha = 0.4,
    labels.size = 0.8
  ) +
  tm_layout(
    main.title = "Landslide Susceptibility",
    legend.outside = TRUE,
    legend.outside.position = "right",
    frame = FALSE
  ) +
  tm_xlab("Easting (m, UTM Zone 17S)") +
  tm_ylab("Northing (m)")

# Export to GeoTIFF
output_path <- file.path(workspace, "landslide_30m.tif")
write_stars(classified_utm, output_path, overwrite = TRUE)