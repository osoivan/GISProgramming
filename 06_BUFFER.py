import arcpy

# Set the workspace (path to the directory with your CSV and output shapefiles)
arcpy.env.workspace = r"C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS"

# Input CSV and output shapefiles
csv_file = "POINTS.csv"  # CSV file with the points
output_shapefile = "points.shp"
buffer_shapefile = "buffer_A_C.shp"  # Output buffer shapefile

# Define the fields in the CSV that contain the X (Longitude) and Y (Latitude) coordinates
arcpy.management.XYTableToPoint(csv_file, output_shapefile, "X", "Y", "", 32717)

expression = "Type IN ('A', 'C')" # Create a query to select Type = "A" or "C"
arcpy.management.MakeFeatureLayer(output_shapefile, "points_lyr")  # Make a feature layer from the points shapefile
arcpy.management.SelectLayerByAttribute("points_lyr", "NEW_SELECTION", expression)
arcpy.analysis.Buffer("points_lyr", buffer_shapefile, "500 METERS") # Create a buffer around the selected points (500 meters)