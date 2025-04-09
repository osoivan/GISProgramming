import arcpy, os

# Set the workspace (path to the root directory containing your shapefiles)
arcpy.env.workspace = r"C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/IGM_50K"

# List all shapefiles called "curva_nivel_l" in the directory and subdirectories
shapefiles = []
for root, dirs, files in os.walk(arcpy.env.workspace):
    for file in files:
        if file.endswith(".shp") and "curva_nivel_l" in file:
            shapefiles.append(os.path.join(root, file))

# Merge all the shapefiles into one (use the "Merge" tool)
merge1 = arcpy.management.Merge(shapefiles, x)

# Read the zona_urbana_a shapefile and select the "QUITO" polygon
zona_urbana_a = "zona_urbana_a/zona_urbana_a.shp" 
query = "nam = 'QUITO'"
quito1 = arcpy.management.SelectLayerByAttribute(zona_urbana_a, "NEW_SELECTION", query)

# Clip the merged shapefile using the "Quito" polygon
clipped_shapefile = "cn_quito.shp"
arcpy.analysis.Clip(merge1, quito1, clipped_shapefile)