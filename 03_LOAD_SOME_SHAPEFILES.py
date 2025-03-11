# Import the arcpy library
import arcpy
import os

# Define the folder containing shapefiles (including subfolders)
folder_path = r"C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/IGM_1G"

# Set the current ArcGIS Pro project and map
aprx = arcpy.mp.ArcGISProject("CURRENT")  # Use the currently open project
map_obj = aprx.activeMap  # Get the active map

# Iterate through all files in the directory and subdirectories
for root, dirs, files in os.walk(folder_path):
    for file in files:
        # Check if the file is a shapefile
        if file.lower().endswith(".shp"):
            shapefile_path = os.path.join(root, file)
            print(f"Loading shapefile: {shapefile_path}")
            
            # Add the shapefile directly to the map
            map_obj.addDataFromPath(shapefile_path)

# Save changes to the ArcGIS Pro project
aprx.save()

print("All shapefiles loaded successfully.")