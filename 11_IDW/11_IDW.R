#install.packages(c("gstat", "sp", "sf", "raster", "tmap"))  # Ejecutar solo una vez
#https://www.umweltbundesamt.de/en/data/air/air-data/stations/eJzrXpScv9ByUXHyQsNFKYmrjAyMTHUNjHWNjBeVZC4yNFqUl7pgUXHJgiUpiW5FcFlDMyA_JB9ZdXLihEW5VWyLcpObFucklpx28FwVWJ17-uzinLz00w7KFw8wMDAwAgAKASor

library(readxl)
library(dplyr)
library(gstat)
library(sp)
library(sf)
library(raster)
library(tmap)

excel_file <- "C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/pm25germany/Airbase_station_coordinates.xlsx"

# Read the file from the fifth row and mainting the unique interested columns
data <- read_excel(excel_file, skip = 4) %>%
  dplyr::select(station_european_code, station_longitude_deg, station_latitude_deg)

# Erase duplicates 
aircoordinates <- data %>% distinct(station_european_code, .keep_all = TRUE)

csv_path <- "C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/pm25germany/stations_2025-03-23-2025-03-23.csv"
airquality <- read.csv(csv_path, sep =";") # Load the CSV file into a data frame

# Join both tables and omit NA
airstations <- left_join(airquality, aircoordinates, by = c("Station.code" = "station_european_code"))
airstations$Measure.value <- as.numeric(airstations$Measure.value)
airstations <- na.omit(airstations)

# Convert airstations to SpatialPointsDataFrame
coordinates(airstations) <- ~station_longitude_deg + station_latitude_deg
proj4string(airstations) <- CRS("+init=epsg:4326")

# Create interpolation grid
grd <- spsample(airstations, type = "regular", n = 5000)
gridded(grd) <- TRUE
proj4string(grd) <- CRS("+init=epsg:4326")

# Perform IDW
idw_result <- idw(formula = Measure.value ~ 1, 
                  locations = airstations, 
                  newdata = grd, 
                  idp = 2.0)

# Convert to raster for plotting
idw_raster <- raster(idw_result)

limite <- st_read("C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/GERMANY/Germany_boundary.shp")
limite <- st_transform(limite, crs = 4326)

# Static
tmap_mode("plot")

# Build the map
tm_shape(idw_raster) +
  tm_raster(
    col = "var1.pred",
    col_alpha = 0.6,
    col.scale = tm_scale_continuous(values = "YlOrRd"),
    col.legend = tm_legend(title = "PM2.5 µg/m³")
  ) +
  
  tm_shape(st_as_sf(airstations)) +
  tm_dots(
    col = "blue",
    size = 0.3,
    fill_alpha = 0.8
  ) +
  tm_text("Station.code", size = 0.5, col = "black", just = "left", xmod = 0.5) +
  
  tm_shape(limite) +
  tm_borders(col = "black", lwd = 2) +
  
  tm_title("PM2.5 Interpolation Map") +
  tm_compass(position = c("left", "top")) +
  tm_scalebar(position = c("right", "bottom"))




# Interactive Map
tmap_mode("view")
tm_shape(idw_raster, group = "PM2.5 IDW Raster") +
  tm_raster(
    col = "var1.pred",
    col_alpha = 0.6,
    col.scale = tm_scale_continuous(values = "YlOrRd"),
    col.legend = tm_legend(title = "PM2.5 µg/m³")
  ) +
  
  tm_shape(airstations, group = "Stations") +
  tm_dots(
    col = "blue",
    size = 0.3,
    fill_alpha = 0.8,
    popup.vars = c("Station.code", "Measure.value")
  ) +
  
  tm_shape(limite, group = "Boundary") +
  tm_borders(col = "black", lwd = 2) +
  
  tm_title("PM2.5 Interpolation Interactive Map") +
  tm_compass(position = c("left", "top")) +
  tm_scalebar(position = c("right", "bottom"))