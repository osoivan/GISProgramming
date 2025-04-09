import arcpy
import pandas as pd
import os

# Get current ArcGIS Pro project and default GDB
project = arcpy.mp.ArcGISProject("CURRENT")
default_gdb = project.defaultGeodatabase
map_obj = project.listMaps()[0]  # Use the first map in the project

# Set environment
arcpy.env.workspace = default_gdb
arcpy.env.overwriteOutput = True

print(f"✅ Using default GDB: {default_gdb}")

# File paths
excel_path = r"C:\Users\alvarece\Desktop\MODELAMIENTO Y PROGRAMACION GIS\PRACTICAS\DATOS\pm25germany\Airbase_station_coordinates.xlsx"
csv_path = r"C:\Users\alvarece\Desktop\MODELAMIENTO Y PROGRAMACION GIS\PRACTICAS\DATOS\pm25germany\stations_2025-03-23-2025-03-23.csv"

# Step 1: Load and prepare data
aircoordinates = pd.read_excel(excel_path, skiprows=4, usecols=["station_european_code", "station_longitude_deg", "station_latitude_deg"])
aircoordinates = aircoordinates.drop_duplicates(subset="station_european_code")

airquality = pd.read_csv(csv_path, sep=";", encoding="utf-8")
airstations = pd.merge(airquality, aircoordinates, how="left", left_on="Station code", right_on="station_european_code")
airstations["Measure value"] = pd.to_numeric(airstations["Measure value"], errors="coerce")
airstations = airstations.dropna(subset=["Measure value", "station_longitude_deg", "station_latitude_deg"])

# Step 2: Save merged CSV temporarily
temp_csv = os.path.join(arcpy.env.scratchFolder, "airstations_clean.csv")
airstations.to_csv(temp_csv, index=False)

# Step 3: Create feature class from CSV
point_fc = os.path.join(default_gdb, "airstations_points")
arcpy.management.XYTableToPoint(
    in_table=temp_csv,
    out_feature_class=point_fc,
    x_field="station_longitude_deg",
    y_field="station_latitude_deg",
    coordinate_system=arcpy.SpatialReference(4326)
)

# Step 4: IDW interpolation
idw_raster = os.path.join(default_gdb, "idw_pm25")
arcpy.sa.Idw(
    in_point_features=point_fc,
    z_field="Measure value",
    cell_size=0.01,
    power=2
).save(idw_raster)

map_obj.addDataFromPath(idw_raster)
