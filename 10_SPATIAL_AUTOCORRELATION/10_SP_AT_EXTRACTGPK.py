import arcpy

# Path to the .gpk file
gpk_path = r"C:\Users\alvarece\Desktop\MODELAMIENTO Y PROGRAMACION GIS\PRACTICAS\DATOS\911hotspot\911HotSpots.gpk"

# Directory where the package will be extracted
output_folder = r"C:\Users\alvarece\Desktop\MODELAMIENTO Y PROGRAMACION GIS\PRACTICAS\DATOS\911hotspot"

# Extract the GPK file
arcpy.ExtractPackage_management(gpk_path, output_folder)

print("Geoprocessing package extracted successfully.")
