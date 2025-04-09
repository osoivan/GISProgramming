import arcpy
from arcpy.sa import *
import os

# Activate the Spatial Analyst extension
arcpy.CheckOutExtension("Spatial")
arcpy.env.overwriteOutput = True

# Base directory (input rasters and output location)
workspace = r"C:\Users\alvarece\Desktop\MODELAMIENTO Y PROGRAMACION GIS\PRACTICAS\DATOS\RASTER"
arcpy.env.workspace = workspace

# Input rasters and shapefile
raster1 = os.path.join(workspace, "LC09_20240831_B5.tif")  # NIR band
raster2 = os.path.join(workspace, "LC09_20240831_B4.tif")  # Red band
raster3 = os.path.join(workspace, "DTM.tif")               # DEM
clip_shp = os.path.join(workspace, "QUITO.shp")            # Clip area shapefile

# Function to reproject raster to EPSG:4326 if needed
def reproject_if_needed(raster_path, name_in_memory):
    desc = arcpy.Describe(raster_path)
    sr = desc.spatialReference
    if sr.factoryCode != 4326:
        print(f"Reprojecting {os.path.basename(raster_path)} from EPSG:{sr.factoryCode} to EPSG:4326")
        return arcpy.management.ProjectRaster(raster_path, f"in_memory/{name_in_memory}", arcpy.SpatialReference(4326))
    else:
        print(f"{os.path.basename(raster_path)} is already in EPSG:4326")
        return raster_path

# Reproject rasters conditionally
r1_proj = reproject_if_needed(raster1, "r1_proj")
r2_proj = reproject_if_needed(raster2, "r2_proj")
r3_proj = reproject_if_needed(raster3, "r3_proj")

# Clip rasters to shapefile
clip_r1 = arcpy.management.Clip(r1_proj, "#", "in_memory/r1_clip", clip_shp, "0", "ClippingGeometry", "MAINTAIN_EXTENT")
clip_r2 = arcpy.management.Clip(r2_proj, "#", "in_memory/r2_clip", clip_shp, "0", "ClippingGeometry", "MAINTAIN_EXTENT")
clip_r3 = arcpy.management.Clip(r3_proj, "#", "in_memory/r3_clip", clip_shp, "0", "ClippingGeometry", "MAINTAIN_EXTENT")

# Calculate NDVI: (NIR - Red) / (NIR + Red)
ndvi = (Raster(clip_r1) - Raster(clip_r2)) / (Raster(clip_r1) + Raster(clip_r2))

# Calculate slope (in percent) from DEM
slope = Slope(Raster(clip_r3), output_measurement="PERCENT_RISE")

# Add NDVI and slope
sum_raster = 0.6*ndvi + 0.4*slope

# Classify the result into 5 classes using Natural Breaks (Jenks)
classified = Slice(sum_raster, 5, "NATURAL_BREAKS")

# Save final classified raster
classified_path = os.path.join(workspace, "final_classified.tif")
classified.save(classified_path)

print("✅ Process completed successfully!")
print("📁 Classified raster saved at:", classified_path)
