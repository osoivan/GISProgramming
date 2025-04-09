# Install if not already installed:
# install.packages(c("shiny", "leaflet", "leaflet.extras", "sf", "dplyr"))

library(shiny)
library(leaflet)
library(sf)
library(dplyr)

# Load initial point data
data <- read.csv("C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/POINTS.csv")
data$X_UTM <- as.numeric(data$X_UTM)
data$Y_UTM <- as.numeric(data$Y_UTM)

# Convert to sf and transform to WGS84
points_utm <- st_as_sf(data, coords = c("X_UTM", "Y_UTM"), crs = 32717)
points_wgs84 <- st_transform(points_utm, crs = 4326)
coords <- st_coordinates(points_wgs84)
points_df <- cbind(data.frame(Point = data$Point, Type = data$Type), coords)

# Load urban zone shapefile and filter for QUITO
zona_urbana <- st_read("C:/Users/alvarece/Desktop/MODELAMIENTO Y PROGRAMACION GIS/PRACTICAS/DATOS/IGM_50K/zona_urbana_a/zona_urbana_a.shp")
zona_urbana_wgs84 <- st_transform(zona_urbana, crs = 4326)
zona_urbana_wgs84 <- zona_urbana_wgs84 %>% filter(nam == "QUITO")

# Function to assign color by Type
getColor <- function(type) {
  ifelse(type == "A", "blue",
         ifelse(type == "B", "green", "red"))
}

# === USER INTERFACE ===
ui <- fluidPage(
  titlePanel("Add new points with attributes"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("point_name", "Point name:", ""),
      selectInput("point_type", "Type:", choices = c("A", "B", "C")),
      actionButton("add_point", "Add point"),
      verbatimTextOutput("click_info")
    ),
    
    mainPanel(
      leafletOutput("map", height = 600)
    )
  )
)

# === SERVER LOGIC ===
server <- function(input, output, session) {
  
  # Reactive to store all points (initial + new)
  puntos <- reactiveVal(points_df)
  
  # Reactive to store clicked coordinates
  coords_click <- reactiveVal(NULL)
  
  # Initial map rendering
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles(group = "Base Map") %>%
      
      # Urban polygon layer
      addPolygons(data = zona_urbana_wgs84,
                  fillColor = "lightgray",
                  color = "gray",
                  weight = 1,
                  fillOpacity = 0.4,
                  popup = "Urban area",
                  group = "Urban Area") %>%
      
      # Initial point layer
      addCircleMarkers(
        data = puntos(),
        lng = ~X,
        lat = ~Y,
        color = ~getColor(Type),
        radius = 6,
        popup = ~paste0("<strong>", Point, "</strong><br>Type: ", Type),
        group = "Points"
      ) %>%
      
      # Measurement tool
      addMeasure(
        primaryLengthUnit = "meters",
        primaryAreaUnit = "sqmeters",
        activeColor = "#3D535D",
        completedColor = "#7D4479"
      ) %>%
      
      # Legend
      addLegend("bottomright",
                colors = c("blue", "green", "red"),
                labels = c("A", "B", "C"),
                title = "Type",
                opacity = 1) %>%
      
      # Layer control
      addLayersControl(
        baseGroups = c("Base Map"),
        overlayGroups = c("Points", "Urban Area"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  # Store coordinates when map is clicked
  observeEvent(input$map_click, {
    coords_click(c(input$map_click$lng, input$map_click$lat))
    output$click_info <- renderPrint({
      paste("Lon:", round(input$map_click$lng, 5), 
            "Lat:", round(input$map_click$lat, 5))
    })
  })
  
  # Add new point to map and reactive data
  observeEvent(input$add_point, {
    req(coords_click())
    req(input$point_name, input$point_type)
    
    new_point <- data.frame(
      Point = input$point_name,
      Type = input$point_type,
      X = coords_click()[1],
      Y = coords_click()[2]
    )
    
    puntos(rbind(puntos(), new_point))
    
    # Update point layer on map
    leafletProxy("map") %>%
      clearGroup("Points") %>%
      addCircleMarkers(
        data = puntos(),
        lng = ~X,
        lat = ~Y,
        color = ~getColor(Type),
        radius = 6,
        popup = ~paste0("<strong>", Point, "</strong><br>Type: ", Type),
        group = "Points"
      )
  })
}

# === RUN THE APP ===
shinyApp(ui, server)
