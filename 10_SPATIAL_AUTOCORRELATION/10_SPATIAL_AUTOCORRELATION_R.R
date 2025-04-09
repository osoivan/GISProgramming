library(sf)
library(spdep)
library(tmap)

# Exersice Available at https://rpubs.com/quarcs-lab/spatial-autocorrelation
# Load the shapefile
s <- readRDS(url("https://github.com/mgimond/Data/raw/gh-pages/Exercises/nhme.rds"))
names(s)
st_crs(s)

# Transform coordinate System to EPSG:4326
s <- st_transform(s, crs = 4326)
st_crs(s)

#Basic statistics
hist(s$Income, main=NULL)
boxplot(s$Income, horizontal = TRUE)

#Mapping the data
tm_shape(s) + tm_fill(col="Income", style="quantile", n=8, palette="Greens") +
  tm_legend(outside=TRUE)

#Moran Analysis
#Construct neighbours list from polygon list
nb <- poly2nb(s, queen=TRUE) #queen true at least one point shared boundary is required
nb
nb[1]

#Check the neighbours in a map
s_centroids <- st_centroid(s) #Generate the centroid of the polygon
coords <- st_coordinates(s_centroids)
plot(st_geometry(s), border="gray")
plot(nb, coords, add=TRUE, col='red')

#Spatial weights for neighbours lists - Define weight matrix
lw <- nb2listw(nb, style="W", zero.policy=TRUE) #W = row-standardized weights, meaning each region’s neighbor weights sum to 1.
lw
lw$weights[1]

#The correlation score is between -1 and 1. Much like a correlation coefficient, 1 determines perfect positive spatial autocorrelation 
#(so our data is clustered), 0 identifies the data is randomly distributed and -1 represents negative spatial autocorrelation 
#(so dissimilar values are next to each other).
globalMoran <- moran.test(s$Income, lw)
globalMoran

#The Moran scatterplot is an illustration of the relationship between the values of the chosen attribute at each location and 
#the average value of the same attribute at neighboring locations.
moran <- moran.plot(s$Income, listw = lw)

#Local Moran
local <- localmoran(x = s$Income, listw = lw)
moran.map <- cbind(s, local)

#Significance map
tm_shape(moran.map) +
  tm_fill(col = "Ii",
          style = "quantile",
          title = "local moran statistic", palette="YlGnBu") 


#LISA map
quadrant <- vector(mode="numeric",length=nrow(local))

# centers the variable of interest around its mean
m.qualification <- s$Income - mean(s$Income)     

# centers the local Moran's around the mean
m.local <- local[,1] - mean(local[,1])    

# significance threshold
signif <- 0.1 

# builds a data quadrant
quadrant[m.qualification >0 & m.local>0] <- 4  
quadrant[m.qualification <0 & m.local<0] <- 1      
quadrant[m.qualification <0 & m.local>0] <- 2
quadrant[m.qualification >0 & m.local<0] <- 3
quadrant[local[,5]>signif] <- 0   

# Define breaks and colors for Moran’s I quadrants
brks <- c(0,1,2,3,4)
colors <- c("white","blue",rgb(0,0,1,alpha=0.4),rgb(1,0,0,alpha=0.4),"red")

# Ensure we plot only based on 'Income' Local Moran’s results
plot(st_geometry(s), border="lightgray", col=colors[findInterval(quadrant, brks, all.inside=TRUE)])

# Add legend
legend("bottomleft", legend = c("Insignificant", "Low-Low", "Low-High", "High-Low", "High-High"),
       fill=colors, bty="n")


# Getis-Ord Gi Clusters
local_g <- as.numeric(localG(s$Income, lw))  # Ensure it's a numeric vector
s$gstat <- local_g

# Mapping Clusters
tm_shape(s) + 
  tm_fill("gstat", 
          palette = "RdBu",
          style = "pretty") +
  tm_borders(alpha=.4)

# Mapping by significance
s$gclass <- cut(local_g,
                breaks = c(-Inf, -1.96, -1.65, 1.65, 1.96, Inf),
                labels = c("Coldspot (p<0.05)", "Coldspot (p<0.10)", 
                           "Not significant", "Hotspot (p<0.10)", "Hotspot (p<0.05)"))

tm_shape(s) + 
  tm_fill("gclass", 
          palette = "bu_rd",
          style = "pretty") +
  tm_borders(alpha=.4)