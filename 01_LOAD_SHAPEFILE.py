# Import the arcpy library
import arcpy

# Define the path to the shapefile (correcting the syntax error)
shapefile_path = r"C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/01_CARGA_SHAPEFILES/DATOS/MOROCCO_BOUNDARIES.shp"

# Load the shapefile into a feature class (feature layer)
shapefile_fc = arcpy.management.MakeFeatureLayer(shapefile_path, "shapefile_layer")

# Print information about the shapefile
desc = arcpy.Describe(shapefile_fc)
print(f"Feature Type: {desc.shapeType}")
print(f"Spatial Reference: {desc.spatialReference.name}")

# List the fields in the shapefile
fields = [field.name for field in arcpy.ListFields(shapefile_fc)]
print("Fields in the shapefile:", fields)