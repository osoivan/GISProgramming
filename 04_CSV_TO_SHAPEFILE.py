import arcpy, os
csv_path = r"C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/POINTS.csv"

# Define the output shapefile path
output_folder = r"C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS"
output_shapefile = os.path.join(output_folder, "points_data.shp")

# Define the coordinate fields and spatial reference (e.g., WGS 84 with EPSG 4326)
x_field = "X"  # Replace with the actual column name for longitude
y_field = "Y"    # Replace with the actual column name for latitude
spatial_ref = arcpy.SpatialReference(32717)  # WGS 84

# Convert the CSV to a shapefile
arcpy.management.XYTableToPoint(csv_path, output_shapefile,x_field,y_field,
    coordinate_system=spatial_ref)
print(f"Shapefile created at: {output_shapefile}")

# Load the new shapefile into the ArcGIS Pro map
aprx = arcpy.mp.ArcGISProject("CURRENT")  # Use the currently open project
map_obj = aprx.activeMap  # Get the active map
aprx.save() # Save changes to the ArcGIS Pro project
print("Shapefile loaded and added to the map successfully.")
