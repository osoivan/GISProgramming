import arcpy

arcpy.env.workspace = r"C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/ZonificacionAguacateMAGAP"

input_shapefile = "Zonificación_agroecologica_aguacate_litoral_2013.shp"
output_shapefile = "Aguacate4326.shp"

# Define the spatial reference for EPSG:4326 (WGS 84)
output_spatial_ref = arcpy.SpatialReference(4326)

# Reproject the shapefile from EPSG:32717 to EPSG:4326 using arcpy
arcpy.management.Project(input_shapefile, output_shapefile, output_spatial_ref)

# Print the CRS info
spatial_ref = arcpy.Describe(output_shapefile).spatialReference
print(f"CRS: {spatial_ref.name} - EPSG: {spatial_ref.factoryCode}")
