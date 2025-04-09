import arcpy, os

#Aqui deberá el usuario cambiar sus datos
arcpy.env.workspace = r"C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS"
name_folder = "EURODATA" #Nombre de la carpeta donde se encuentran los datos de entrada
folder_clip = "GERMANY"
name_clip = "Germany_boundary.shp"
folder_exit = "Germany_clipped_ARCGIS"

##################No tocar el resto de código##################################################
input_folder = os.path.join(arcpy.env.workspace, name_folder)
clip_polygon = os.path.join(arcpy.env.workspace, folder_clip, name_clip)

clip_crs = arcpy.Describe(clip_polygon).spatialReference # Get the CRS of the clip polygon

# Set the output folder to save the clipped shapefiles
output_folder = os.path.join(arcpy.env.workspace, folder_exit)  
if not os.path.exists(output_folder):
    os.makedirs(output_folder)

shapefiles = [] # List all shapefiles in the folder (including subfolders)
for root, dirs, files in os.walk(input_folder):
    for file in files:
        if file.endswith(".shp"):
            shapefiles.append(os.path.join(root, file))

print(shapefiles)

for shp in shapefiles:
    try:
        shp_crs = arcpy.Describe(shp).spatialReference     # Get the CRS of the current shapefile
       
        if shp_crs.name != clip_crs.name: # Reproject the shapefile if necessary
            reprojected_shp = os.path.join(output_folder, f"reprojected_{os.path.basename(shp)}")
            arcpy.management.Project(shp, reprojected_shp, clip_crs)
            shp = reprojected_shp  # Update shapefile path to the reprojected version
        
        clipped_shp = os.path.join(output_folder, f"clipped_{os.path.basename(shp)}") # Clip the reprojected shapefile with the clipping polygon
        arcpy.analysis.Clip(shp, clip_polygon, clipped_shp)
        print(f"Clipped shapefile saved as: {clipped_shp}")
    
    except Exception as e:
        print(f"Error processing {shp}: {e}")