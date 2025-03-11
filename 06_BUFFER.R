library(sf, dplyr, ggplot2)
setwd("C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS")
data <- read.csv("POINTS.csv")
data$X <- as.numeric(data$X)
data$Y <- as.numeric(data$Y)
points <- st_as_sf(data, coords = c("X", "Y"), crs = 32717)
points_A <- points %>% filter(Type %in% c("A", "C")) # Filter by the 'Type' attribute where Type is "A"
buffer_A <- st_buffer(points_A, dist = 2000)  # Set the buffer distance as needed
st_write(buffer_A, "buffer_A.shp", delete_layer = TRUE)

ggplot() +
  geom_sf(data = points, color = "red", size = 3) +  # Plot the points
  geom_sf(data = buffer_A, fill = "lightblue", alpha = 0.5) +  # Plot the buffer with transparency
  theme_minimal() +
  labs(title = "Points and Buffer Shapefiles",
       x = "Longitude", 
       y = "Latitude") 