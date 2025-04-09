# Import the arcpy library
import arcpy

# Define the path to the raster TIFF file
raster_path = r"C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/BermejoBS09_Ortomosaico.tif"

# Set the current ArcGIS Pro project and map
aprx = arcpy.mp.ArcGISProject("CURRENT")  # Use the currently open project
map_obj = aprx.activeMap  # Get the active map

# Directly add the raster to the map without creating an intermediate layer
map_obj.addDataFromPath(raster_path)

# Save the changes to the project
aprx.save()

print("Raster loaded and added to the map successfully.")
